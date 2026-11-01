# Optional online services

The app's bundled Hindi/English help, visit preparation and saved reports work without this backend. BHASHINI, AI answers, new mandi reports and news need the service below. No cloud resources have been deployed by this change.

## What is implemented

`krishiApi` is a Firebase HTTP function with `/translate`, `/assistant`, `/market` and `/news` POST routes. It verifies a Firebase ID token (including revocation), rejects anonymous accounts, limits request size and personal identifiers, checks web origins, and keeps provider credentials server-side. Requests are limited to 30 per signed-in user per UTC day and 500 globally per UTC day, across function instances, using Firestore transactions. Failed provider calls count against the limits. The conservative limits can be changed in `index.js` after setting a budget.

Only counters and hashed user IDs are stored. Questions, answers, translations, phone numbers and bank information are not written to Firestore or application logs. Provider services receive the submitted text under their own policies; the app asks before sending. The app sends no booking/payment context or conversation history. Logs from your infrastructure/provider should be reviewed separately.

BHASHINI uses the official pipeline-config call followed by pipeline compute. The requested Hindi/English language pair is matched to a returned service ID. The inference credential can only go to the documented `dhruva-api.bhashini.gov.in/services/inference/pipeline` HTTPS endpoint. It is not returned to the client. This implementation provides text translation; speech recognition, voice playback and Chhattisgarhi are not claimed or enabled.

## Setup

1. Use Node 22. In `functions`, run `npm ci` after the lockfile is present, then `npm test` and `npm run check`.
2. Use the intended Firebase project, enable the required billing plan for Cloud Functions and create Firestore in a suitable region. Set a budget and billing alerts. Cloud Functions deployment requires the Blaze plan; the app's offline features do not. Provider quotas and prices are separate.
3. Merge the deny rule in `functions/firestore.rules` into existing Firestore rules. An existing broad allow rule can override this deny, so check the whole ruleset. Set a Firestore TTL policy on `_serviceQuota.expiresAt` to clean counters after two days. Until TTL is enabled, old counter documents remain; they contain no raw user ID or question text.
4. Store one JSON secret using `firebase functions:secrets:set KRISHI_SERVICES` through your private terminal. Its fields are listed below. Do not commit the secret or place it in Dart defines, source files or a web bundle. Missing provider fields make that provider unavailable; the other endpoints can still work.
5. Add a `functions` source entry for `functions` to the existing root Firebase configuration if needed. Deploy only after reviewing the target project and costs: `firebase deploy --only functions:krishiApi`. No deployment is performed automatically.
6. Build Flutter with `--dart-define=KRISHI_API_BASE_URL=https://asia-south1-YOUR_PROJECT.cloudfunctions.net/krishiApi`. This URL is public; it is not a secret. Enable a supported Firebase sign-in provider first. Put the exact deployed web origin in `allowedOrigins` (no wildcard). Native apps do not send an Origin header.
7. Verify real sign-in, BHASHINI consent/translation in both directions, revoked-token rejection, offline fallback and rate-limit responses on a staging project. The tests here use mocked provider responses and do not prove that your credentials, billing or provider access are active.

Secret fields:

| Field | Purpose |
| --- | --- |
| `allowedOrigins` | Array of exact web origins, such as your own HTTPS hosting domain |
| `bhashiniUserId` | ULCA account user ID |
| `bhashiniApiKey` | ULCA API key |
| `bhashiniPipelineId` | Your authorised pipeline supporting English/Hindi translation |
| `openRouterKey` | Optional OpenRouter key |
| `openRouterModel` | Explicit model ID you have reviewed, including its price/privacy terms |
| `dataGovApiKey` | data.gov.in key for mandi reports |
| `newsDataApiKey` | Optional NewsData.io key |

No provider key is required for local help. Old Dart define names (`GEMINI_API_KEY`, `OPENROUTER_API_KEY`, `DATA_GOV_IN_API_KEY`, `NEWSDATA_API_KEY`) are no longer used by the service clients. Rotate any provider credentials previously distributed in application builds.

## Data and limitations

- Prices query Chhattisgarh and return at most 100 reported mandi records. This is not a complete statewide market catalogue. Observation dates stay visible; a retrieval today does not mean prices were observed today. Market reports are not MSP or guaranteed procurement prices.
- News is fetched only on request, limited to ten summaries, and images are disabled in low-data mode. The sources are publishers, not government verification. Full articles open externally and use data.
- Public report caches persist across launches; app settings currently clear personal visit plans only. Device/browser app-data controls can remove all local data. There is no automatic repeated fetching or multi-provider fallback that silently spends data.
- Quotas reduce accidental spend; they are not a substitute for abuse monitoring or Firebase App Check. Add and test App Check for your actual app registrations before a large public rollout. Existing quotas still apply if multiple accounts are created.
- Government procurement eligibility, official tokens, booking capacity and bank transfers require a separately authorised government integration. Firebase sign-in and BHASHINI do not provide that authority.
- BHASHINI's published PoC documentation asks production/paid integrators to contact its team for production access and pricing. Do not assume unlimited free production access.

## Official references checked

- [BHASHINI API overview and production-access note](https://bhashini.gitbook.io/bhashini-apis)
- [BHASHINI pipeline config endpoint and headers](https://bhashini.gitbook.io/bhashini-apis/pipeline-config-call)
- [BHASHINI config response model and inference endpoint](https://bhashini.gitbook.io/bhashini-apis/pipeline-config-call/response-payload)
- [BHASHINI compute request](https://bhashini.gitbook.io/bhashini-apis/pipeline-compute-call/request-payload)
- [BHASHINI compute response](https://bhashini.gitbook.io/bhashini-apis/pipeline-compute-call/response-payload)
- [Firebase HTTP functions](https://firebase.google.com/docs/functions/http-events)
- [Firebase secrets](https://firebase.google.com/docs/functions/config-env)
- [Firebase ID-token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
- [Firebase setup and deployment plan](https://firebase.google.com/docs/functions/get-started)
