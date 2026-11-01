'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const {validateRequest, translate, market, assistant} = require('../service');
const response = data => ({ok: true, text: async () => JSON.stringify(data)});
const secret = {bhashiniUserId: 'user', bhashiniApiKey: 'secret', bhashiniPipelineId: 'pipeline'};
const configuration = {pipelineResponseConfig: [{taskType: 'translation', config: [{serviceId: 'english-hindi', language: {sourceLanguage: 'en', targetLanguage: 'hi'}}]}], pipelineInferenceAPIEndPoint: {callbackUrl: 'https://dhruva-api.bhashini.gov.in/services/inference/pipeline', inferenceApiKey: {name: 'Authorization', value: 'server-key'}}};

test('rejects unknown endpoints, unsupported languages and personal identifiers', () => {
  assert.throws(() => validateRequest('delete', {}), {status: 404});
  assert.throws(() => validateRequest('translate', {text: 'hi', source: 'en', target: 'hne'}), {status: 400});
  assert.throws(() => validateRequest('assistant', {message: 'Call 98765 43210'}), {status: 400});
  assert.throws(() => validateRequest('assistant', {message: 'contact me@example.com'}), {status: 400});
  assert.throws(() => validateRequest('assistant', {message: 'x'.repeat(1001)}), {status: 400});
  assert.deepEqual(validateRequest('assistant', {message: '  Payment delayed  ', context: 'ignored bank details'}), {message: 'Payment delayed', language: 'en'});
});

test('translation permits exact public helplines but blocks Hindi private numbers and extended runs', () => {
  const request = text => ({text, source: 'en', target: 'hi'});
  assert.equal(validateRequest('translate', request('Call 1800-180-1551 or 1800-233-3663.')).source, 'en');
  assert.equal(validateRequest('translate', request('१८००-१८०-१५५१ पर संपर्क करें')).target, 'hi');
  assert.throws(() => validateRequest('translate', request('मेरा नंबर ९८७६५ ४३२१० है')), {status: 400});
  assert.throws(() => validateRequest('translate', request('9 1800-180-1551')), {status: 400});
  assert.throws(() => validateRequest('translate', request('1800-180-1551 9')), {status: 400});
  assert.throws(() => validateRequest('assistant', {message: 'आधार १२३४ ५६७८ ९०१२'}), {status: 400});
});

test('BHASHINI resolves the requested language model then computes translation', async () => {
  const calls = [];
  const result = await translate({text: 'Bring the receipt', source: 'en', target: 'hi'}, secret, async (url, options) => {
    calls.push({url, options, body: JSON.parse(options.body)});
    return response(calls.length === 1 ? configuration : {pipelineResponse: [{taskType: 'translation', output: [{target: 'रसीद लाएँ'}]}]});
  });
  assert.equal(result.text, 'रसीद लाएँ');
  assert.equal(calls.length, 2);
  assert.equal(calls[0].options.headers.ulcaApiKey, 'secret');
  assert.equal(calls[1].options.headers.Authorization, 'server-key');
  assert.equal(calls[1].body.pipelineTasks[0].config.serviceId, 'english-hindi');
  assert.equal(calls[1].body.inputData.input[0].source, 'Bring the receipt');
  assert.equal(calls[0].options.redirect, 'error');
});

test('does not send inference credentials to an unexpected callback host', async () => {
  let requests = 0;
  const config = structuredClone(configuration);
  config.pipelineInferenceAPIEndPoint.callbackUrl = 'https://attacker.example/services/inference/pipeline';
  await assert.rejects(() => translate({text: 'hello', source: 'en', target: 'hi'}, secret, async () => {requests++; return response(config);}), {status: 503});
  assert.equal(requests, 1);
});

test('does not guess a missing translation model or successful response', async () => {
  const config = structuredClone(configuration);
  config.pipelineResponseConfig[0].config[0].language.targetLanguage = 'bn';
  await assert.rejects(() => translate({text: 'hello', source: 'en', target: 'hi'}, secret, async () => response(config)), {status: 503});
  await assert.rejects(() => translate({text: 'hello', source: 'en', target: 'hi'}, {}, async () => {throw Error('must not call');}), {status: 503});
});

test('market request is state-filtered and removes provider metadata', async () => {
  const result = await market({dataGovApiKey: 'private'}, async url => {
    assert.equal(new URL(url).searchParams.get('filters[state]'), 'Chhattisgarh');
    return response({records: [{state: 'Chhattisgarh', commodity: 'Paddy', secret: 'removed'}, {state: 'Punjab', commodity: 'Wheat'}]});
  });
  assert.equal(result.records.length, 1);
  assert.equal(result.records[0].secret, undefined);
});

test('online assistant sends no history or booking context and limits output', async () => {
  await assistant({message: 'Prepare my visit', language: 'en', history: 'private'}, {openRouterKey: 'key', openRouterModel: 'chosen-model'}, async (_, options) => {
    const body = JSON.parse(options.body);
    assert.equal(body.messages.length, 2);
    assert.equal(body.messages[1].content, 'Prepare my visit');
    assert.equal(body.max_tokens, 450);
    assert.equal(JSON.stringify(body).includes('private'), false);
    return response({choices: [{message: {content: 'Bring your official receipt.'}}]});
  });
});
