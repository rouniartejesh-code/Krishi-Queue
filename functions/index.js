'use strict';
const {onRequest} = require('firebase-functions/v2/https');
const {defineJsonSecret} = require('firebase-functions/params');
const {initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore, Timestamp} = require('firebase-admin/firestore');
const {createHash} = require('node:crypto');
const service = require('./service');
initializeApp();
const credentials = defineJsonSecret('KRISHI_SERVICES');

// Transactional limits apply across instances. Only a hashed account identifier
// and counters are stored, never question text, identity records or translations.
async function reserveQuota(uid) {
  const db = getFirestore();
  const today = new Date().toISOString().slice(0, 10);
  const userKey = createHash('sha256').update(uid).digest('hex');
  const perUser = db.collection('_serviceQuota').doc(`${today}_${userKey}`);
  const global = db.collection('_serviceQuota').doc(`${today}_total`);
  await db.runTransaction(async transaction => {
    const [user, total] = await transaction.getAll(perUser, global);
    if ((user.data()?.count ?? 0) >= 30 || (total.data()?.count ?? 0) >= 500) throw new service.ServiceError(429, 'Daily online-help limit reached.');
    const expiresAt = Timestamp.fromMillis(Date.now() + 2 * 86400000);
    transaction.set(perUser, {count: (user.data()?.count ?? 0) + 1, expiresAt});
    transaction.set(global, {count: (total.data()?.count ?? 0) + 1, expiresAt});
  });
}

exports.krishiApi = onRequest({region: 'asia-south1', memory: '256MiB', timeoutSeconds: 30, maxInstances: 2, concurrency: 10, secrets: [credentials], cors: false}, async (request, response) => {
  response.set('Cache-Control', 'no-store');
  const secrets = credentials.value();
  const origin = request.get('origin');
  const allowed = Array.isArray(secrets.allowedOrigins) ? secrets.allowedOrigins : [];
  if (origin && !allowed.includes(origin)) return response.status(403).json({error: 'Origin not allowed.'});
  if (origin) {
    response.set('Access-Control-Allow-Origin', origin);
    response.set('Vary', 'Origin');
    response.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
    response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  }
  if (request.method === 'OPTIONS') return response.status(204).send('');
  if (request.method !== 'POST') return response.status(405).json({error: 'POST required.'});
  if (!request.is('application/json') || (request.rawBody?.length ?? 0) > 10000) return response.status(400).json({error: 'Invalid request.'});
  try {
    const match = /^Bearer ([^\s]+)$/.exec(request.get('authorization') ?? '');
    if (!match) throw new service.ServiceError(401, 'Sign in required.');
    let user;
    try { user = await getAuth().verifyIdToken(match[1], true); } catch { throw new service.ServiceError(401, 'Sign in again.'); }
    if (user.firebase?.sign_in_provider === 'anonymous') throw new service.ServiceError(401, 'Verified sign-in required.');
    const route = request.path.replace(/^\/+|\/+$/g, '');
    const input = service.validateRequest(route, request.body);
    await reserveQuota(user.uid);
    const result = route === 'translate' ? await service.translate(input, secrets)
      : route === 'assistant' ? await service.assistant(input, secrets)
      : route === 'market' ? await service.market(secrets) : await service.news(secrets);
    return response.status(200).json(result);
  } catch (error) {
    // Never return provider payloads, credentials or personal request content.
    return response.status(error instanceof service.ServiceError ? error.status : 503).json({error: error instanceof service.ServiceError ? error.message : 'Online help is temporarily unavailable.'});
  }
});
