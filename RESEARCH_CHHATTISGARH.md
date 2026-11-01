# Krishi Queue: Chhattisgarh farmer and procurement research

Research date: 31 October 2026. Scope: Chhattisgarh first, especially paddy procurement; Indian comparisons where informative. Prepared from public government material, research papers, service documentation, company disclosures, local reporting, and inspection of this repository.

Implementation note, 1 November 2026: repository observations below describe the pre-change baseline. Section 18 and [implementation status](docs/IMPLEMENTATION_STATUS.md) distinguish subsequent app improvements from services that still require official access or provider configuration.

## The short version

**The farmer problem:** it can take repeated attempts, travel and waiting to sell a crop. A token is helpful, but farmers still need the centre to be ready, the crop to be accepted and weighed correctly, and the money to arrive.

**The key fact:** Chhattisgarh already has the government’s Token Tuhar app, and the state has planned a new agriculture platform with mobile procurement tokens. Krishi Queue should not compete by offering another unverified booking screen.

**The better opportunity:** help farmers and procurement centres handle the trouble around the official booking. Tell farmers whether a visit is ready to happen, help them correct a blocked record, give them understandable proof of the sale, and track unresolved payment or weighing problems. Make that help available on weak connections, shared phones and through a local human.

**The first version:** pilot one small service at two or three willing centres. Start with a readiness checklist, a clearly marked update from the centre, an offline-viewable token, a sale receipt and a case number for problems. Keep official booking in the official channel. Don't claim to have secured a place unless the responsible system confirms it.

**Why this might work as a startup:** the customer who benefits most—the farmer—may have little ability or reason to pay for another app. A cooperative, farmer group, procurement operator, government partner or funded pilot may pay if the service measurably saves time, staff work or money and improves accountability. The main startup risk is securing that partner and earning the right to use reliable operational data. Build a small proof of value before a large product or sales team.

**How to judge the pilot:** compare results with the existing process. Measure wasted trips, waiting time, problems resolved, payment-record accuracy and staff effort. Make sure less waiting did not come from excluding farmers who need assistance. If a willing partner and access to trustworthy updates cannot be secured, change the product into a smaller farmer assistance and receipt service, or reconsider the idea.

The rest of this report gives evidence, solutions and implementation detail. Terms used below: **token** means the official appointment/reference that permits a farmer to bring produce for procurement; **PACS/society** means the local cooperative procurement organisation; **FPO** means a farmer producer organisation; **MSP** means the government's minimum support price. A token is not itself a completed sale, accepted quantity or paid amount.

This is desk research, not interviews, a representative farmer survey, a security audit of other apps, or a live test of government services. Recommendations and pilot targets below are proposals. Downloads, registrations, transactions, active use, satisfaction, and causal income gains are different measures. No source reviewed establishes all six for the same Chhattisgarh service.

**1. The product decision: focus on a farmer completing a sale with fewer avoidable costs.** Krishi Queue has a plausible purpose, but its most defensible opportunity is coordinating the journey from procurement readiness to receipt and verified payment. A booking interface alone overlaps directly with existing state systems. Its usefulness depends on whether centre staff can act on its information and whether farmers receive an authoritative, dependable next step.

The initial promise should be: “Know whether you can sell, when to arrive, what is blocking your delivery, and what happened to your grain and payment.” Validate that promise in one district, one procurement season, and a small number of cooperating centres before extending it across crops or states.

Three conditions determine viability: a centre partner that will maintain operational information; permission to work alongside the official process; and measured reductions in wasted visits, waiting, disputes, or staff effort. If these conditions are absent, a smaller assistance and receipt-tracking tool is more credible than a purported live procurement platform.

**2. Chhattisgarh already has a substantial digital procurement system.** NIC describes computerised paddy procurement dating to 2007, integration with storage and milling operations, and electronic payments. Its October 2025 account says 64% of farmers actively used the token app, but does not clearly identify the measurement season or methodology. This is implementation-agency reporting, not independent proof of satisfaction. [NIC, Chhattisgarh digital governance](https://informatics.nic.in/files/websites/october-2025/chhattisgarh.php)

The Token Tuhar Play listing describes farmer-selected procurement dates plus land, bank, token and purchase information, and displays 1M+ downloads. That confirms meaningful distribution, not one million active farmers or successful bookings. [Official app listing](https://play.google.com/store/apps/details?hl=en-US&id=com.nic.kisaan)

A March 2026 Assembly proceeding reports procurement from 25.24 lakh farmers and approximately 141 lakh tonnes during 2025–26. Those are procurement participation figures, not app-use figures. [Chhattisgarh Assembly, 10 March 2026](https://www.cgvidhansabha.gov.in/hindi_new/satra/sixth_assembly/eighth/proc10032026.pdf)

The biggest competitive development is the April 2026 UPAHAR request for proposals. It explicitly includes mobile procurement tokens with date, time, centre and allowable quantity, plus central-system synchronisation. This establishes planned overlapping scope; it does not establish delivery, launch, vendor selection, usable public APIs, or current performance. [UPAHAR RFP, pages 35–36](https://revenue.cg.nic.in/NoticeforInvitingTender%28NIT%29ANDRFPunderUPAHAR.pdf)

Therefore, ask the state/NIC/implementation partner what remains unresolved before building another official-token workflow. Do not assume that a publicly visible portal grants integration access, or that an independently generated QR code will be accepted at a government centre.

**3. Seasonal policy must be treated as changing data.** The following distinctions matter directly to product requirements.

| Evidence date | What the source establishes | Product implication |
|---|---|---|
| 12 November 2025 | The state described limited booking hours, a seven-procurement-day horizon, a 70% app/30% society allocation of daily capacity, and an 80% small/marginal share within the app allocation. | Model capacity in the units used by the scheme; store policy version and effective dates. |
| 15 December 2025 | The state described 24-hour token access and a 20-day advance horizon. It also listed AgriStack-registration exemptions for specified categories including sharecroppers and forest-rights title holders. | Rules changed within one season. A missing Farmer ID must route to the applicable assisted process, not automatically become a permanent rejection. |
| 27 October 2026 | Cabinet announced procurement from 15 November 2026, ₹3,100/qtl and a 21-qtl/acre ceiling, recognised previously registered farmers with AgriStack IDs, and changed paddy input assistance from a per-quintal to a per-acre basis. | Separate announced policy from calculated entitlement, and verify implementing orders before calculating payouts. |

Sources: [November 2025 token rules](https://jansampark.cg.gov.in/dprnewsportal/NewsPopup.aspx?param=EA2jPtYbdDs%3D&type=TQwAi5bC7eg%3D), [December 2025 changes and exemptions](https://jansampark.cg.gov.in/dprnewsportal/NewsPopup.aspx?param=QfQfW4CXbTE%3D&type=TQwAi5bC7eg%3D), [official 2026 cabinet decisions](https://dprcg.gov.in/pages/1768982672/decisions-of-the-council-of-ministers-2026).

The national 2026–27 paddy MSP is ₹2,441/qtl for common and ₹2,461/qtl for Grade A. These are distinct from Chhattisgarh's announced ₹3,100 figure and from local mandi prices. The app should show the source, season, crop grade, eligibility basis, and separate state assistance. [Department of Food and Public Distribution MSP table](https://dfpd.gov.in/msp-for-wheat-and-rice/en)

October 30 reporting gives a 15 November 2026–15 January 2027 procurement window, November 2–5 trials and November 10 token availability. Treat these as reported upcoming arrangements; confirm the signed operational circular and district instructions before enabling bookings. The forthcoming season's actual performance cannot yet be evaluated. [Navbharat Times, 30 October 2026](https://navbharattimes.indiatimes.com/state/chhattisgarh/raipur/paddy-procurement-in-chhattisgarh-360-new-centers-farmers-to-receive-online-tokens-starting-november-10/articleshow/135369049.cms)

Do not carry historical quotas, exemptions, payment promises, registration deadlines or token validity into a new season without verification. The November 2025 source illustrates capacity shares with quintals; calling the percentages simply a share of farmer counts could misimplement them.

**4. Existing services are used, but evidence of use varies considerably.** This comparison distinguishes direct procurement systems from adjacent agricultural services.

| Service | Main job | Evidence of use or availability | What Krishi Queue should learn |
|---|---|---|---|
| Token Tuhar, Chhattisgarh | Official paddy token scheduling and farmer/procurement information | NIC's 64% use statement and Play's 1M+ download band, with the limitations above | Obtain official workflow compatibility. A second token is not a sufficient advantage. |
| MP eUparjan | Registration, procurement, transport/storage and payment systems | NIC's November 2025 profile reports 2024 paddy purchases from over 7.7 lakh farmers; this is a transaction measure, not mobile MAU | Procurement requires connected operational systems. [NIC MP profile](https://cdnbbsr.s3waas.gov.in/s3df4fe8a8bcd5c95cdb640aa9793bb32b/uploads/2025/12/2025121585.pdf) |
| Odisha P-PAS | Farmer registration, tokens, procurement and payment visibility | Current government portals expose token and farmer-payment enquiry; a 2026 parliamentary reply describes operational use. Independent active-app figures were not located | Learn from receipts and status enquiry; don't infer trouble-free operation. [Odisha portal](https://www.foododisha.in/TransparencyPortal.asp), [Parliamentary reply](https://sansad.in/getFile/annex/270/AU3848_VubwdT.pdf?source=pqars) |
| e-NAM | Agricultural market trading, bidding, quality and payments | Government reports 1.89 crore registered farmers as of June 2026. Separate March reporting gives cumulative trading value of ₹4.82 lakh crore through February 2026 | Registration is not independent farmer use; recorded trade is not automatically remote national competition. [July 2026 reply](https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2290633&lang=2&reg=48), [March 2026 reply](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2241414&lang=2&reg=3) |
| Crop Doctor, IGKV–NIC | Crop advice, diagnosis and related services, with local institutional relevance | IGKV displays 7,60,289 registered farmers and approximately 3 lakh downloads, without a clear common reporting period or active-use denominator | Explore expert referral before recreating crop diagnosis. These two metrics should not be treated as interchangeable. [IGKV service](https://www.igkv.ac.in/cropDoctorWeb/crophomepage.aspx), [NIC description](https://informatics.nic.in/files/websites/july-2025/crop-doctor.php) |
| Meghdoot / IMD advisories | Weather-based agricultural advice | Ministry reply records 4,16,056 registered Meghdoot users by 28 November 2025; this excludes reach through other channels | Bring timely district alerts into a concrete task such as drying, covering grain or travel planning. [Ministry reply](https://www.moes.gov.in/sites/default/files/1306English.pdf) |
| Kisan e-Mitra | Scheme-related conversational assistance | A November 2025 PIB brief reports 95 lakh queries from 53 lakh farmers as of July 15, 2025; neither count proves answer accuracy or income impact | Narrow, accountable assistance can have reach. Avoid an unrestricted chatbot. [PIB brief](https://static.pib.gov.in/WriteReadData/specificdocs/documents/2025/nov/doc20251120700401.pdf) |
| Bharat-VISTAAR | Voice-led agricultural information across channels | Government confirms phase 1 launched February 17, 2026, initially Hindi/English. This source establishes availability, not sustained usage | Broad agricultural AI is already a public initiative; focus on verified local transactions. [Official launch/status reply](https://www.pib.gov.in/PressReleasePage.aspx?PRID=2239788&lang=1&reg=1) |
| DeHaat | Inputs, advice, physical centres, services and market linkage | Company website claims 3 million+ farmers and 14,000+ centres; definitions and audited active-user counts are not supplied there | Physical help and fulfilment are part of the product. [Company website](https://dehaat.in/?tab=1) |
| AgroStar | Advice, inputs, retail access and market linkages | Company currently claims 12M+ farmer reach and 10,000+ stores; not the same as app MAU or unique annual buyers | Learn from phone/local-store/app combinations. Avoid copying marketing reach as verified adoption. [Company disclosures](https://corporate.agrostar.in/) |
| Plantix | Crop-problem diagnosis | Its media page claims 134,000 daily active users, but has no clear measurement date or India-only denominator | A specific, immediate task can motivate use; do not turn this global company claim into Chhattisgarh evidence. [Company media page](https://www.plantix.net/en/press-media/) |
| AGMARKNET / data.gov.in | Market-price information | Official dataset provides daily market/commodity/variety data. It does not itself guarantee a buyer or a farmer's realised price | Localise, timestamp and distinguish a historical observation from an executable offer. [Official dataset](https://data.gov.in/resource/variety-wise-daily-market-prices-data-commodity) |

An additional caution on e-NAM: the July 2026 government reply reports only ₹14.28 crore of interstate trade during 2025–26, alongside a rise in average bids per lot from 2.1 to 2.8 since 2016–17. These show different dimensions of use. They support neither “nobody uses e-NAM” nor “every registered farmer can easily sell anywhere in India.” Do not divide differently dated cumulative figures to manufacture an exact national-market share. [Government reply](https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2290633&lang=2&reg=48)

**5. Why use does not necessarily remove the problem.** Several mechanisms can coexist: a useful app, widespread use, technical failures, administrative exclusion and scarce physical capacity.

Local reporting from Durg on December 3, 2025 describes repeated attempts to obtain tokens, limited smartphone access and difficulty obtaining offline tokens. These are reported experiences at particular locations, not prevalence estimates for the state. [Durg field report](https://english.dainikjagranmpcg.com/states/chhattisgarh/disorder-at-paddy-procurement-centers-in-durg-leaves-farmers-frustrated/article-9401)

A December 8, 2025 report from Mungeli describes repeated server failures and long queues; a November 2024 Dhamtari report records technical complaints and an official response expanding offline allocation. The older ratio should not be used as today's rule. Together they justify investigating availability and fallbacks, rather than declaring a single statewide failure rate. [Mungeli reporting](https://lalluram.com/server-crash-at-paddy-procurement-centers-leads-to-long-queues-of-farmers-payments-through-micro-atm-are-negligible/), [Dhamtari reporting](https://www.amarujala.com/chhattisgarh/dhamtari/farmers-are-facing-problems-in-cutting-tokens-in-tuhar-hath-app-unable-to-send-paddy-in-dhamtari-2024-11-25)

A 2026 study using 390 respondents in one Tamil Nadu district identifies cash needs, digital literacy, technical difficulties and infrastructure constraints around e-NAM. It is useful mechanism evidence, not a representative Chhattisgarh survey or proof of causation. [Indian Journal of Extension Education](https://epubs.icar.org.in/index.php/IJEE/article/view/178205)

A Punjab study highlights farmers' reliance on commission agents and concern about losing their assistance. A product replacing a channel may also remove credit, transport coordination or trusted help unless those services are replaced. This is a design inference from that study, not an endorsement of every intermediary practice. [Journal of Farm Sciences, 2024](https://journaloffarmsciences.in/index.php/JFM/article/view/507)

| Failure mechanism to investigate | Why another screen is insufficient | Useful response |
|---|---|---|
| No available capacity | A faster app cannot add storage, staff, sacks or trucks | Show the actual blocker and responsible operator; recalculate arrivals when capacity changes |
| OTP, connectivity or backend failure | Repeated attempts can consume a short booking window | Saved progress, clear outage status, rate-limited retries and an authorised assisted route |
| Eligibility/land/crop mismatch | A valid login does not establish procurement eligibility | Specific reason, evidence checklist and a tracked correction case |
| Shared phone or limited literacy | The account holder may not be the person operating the phone | Consented helper access, local-language audio and paper/SMS continuity |
| Farmer cannot wait for cash | Better price information does not pay today's obligations | Honest payment timing, failure resolution and referral to appropriate formal support |
| Quality or quantity disagreement | A status saying “passed” is not evidence | Recorded measurements, receipt, explanation and retest/appeal workflow |
| Staff duplicate work | Unmaintained queues rapidly become misleading | Minimise entry and connect to the existing source of record |
| No complaint owner | A help button can merely create another queue | Named responsible team, due date, escalation and resolution evidence |
| Seasonal need | Low daily use after harvest can be normal | Measure sale completion and return next season, not addictive engagement |

MoSPI's 2025 survey reports that 83.3% of rural households had internet available within the household and 82.1% had at least one smartphone, compared with 86.3% and 85.5% respectively nationwide. About 53% of rural households relied on a smartphone as their only phone; 12.3% had a non-smartphone. Among rural people aged 15 and over, reported internet use in the preceding three months was 72.1% for men and 57.6% for women, and personal phone ownership was 80.7% for men and 48.4% for women. The usage measure counts access from any place, device and purpose; household internet access does not guarantee working signal at the farm or procurement centre. These are national survey estimates, not Chhattisgarh farmer-specific rates. They show why “someone in the household has internet” is inadequate as an accessibility requirement. [MoSPI 2025 telecom survey](https://mospi.gov.in/sites/default/files/press_release/Final_press%20release_CMS_T.pdf)

**6. The broader farmer problem is economic, physical and institutional as well as digital.** The table below is a planning framework, not a claim that each issue affects every Chhattisgarh farmer equally. A 240-farmer Chhattisgarh plains study identified input and peak-labour costs and marketing constraints; it is from 2019 and needs local revalidation. [Original study](https://www.phytojournal.com/archives/2019.v8.i6.10173/constraints-of-paddy-grower-farmers-a-study-with-special-reference-to-chhattisgarh-state)

| Stage | Problem to investigate | Practical help | Boundary of Krishi Queue |
|---|---|---|---|
| Crop choice | Uncertain margins, water availability and buyer demand | Local crop budgets and extension/FPO consultation | Do not promise that changing crops is profitable because a subsidy exists |
| Finance | Upfront costs and urgency to repay | Explain expected cashflow and refer to verified services | No unsolicited lending, opaque credit scores or sale of financial data |
| Inputs | Cost, quality and unsuitable advice | Soil-test/expert referral, transparent comparisons, group purchasing where feasible | Avoid advice driven by commissions on input sales |
| Cultivation | Weather, pests and water stress | Current IMD/IGKV advice linked to crop stage | Agricultural recommendations require expert validation |
| Labour/machinery | Seasonal shortages and scheduling conflicts | Local hiring coordination through verified providers | Availability and fulfilment must be confirmed |
| Harvest | Harvest timing, moisture and damage | Readiness checklist and access to testing/drying | A phone photograph does not measure procurement-grade moisture |
| Registration | Record errors and unclear exceptions | Assisted checklist, correction ownership and status | Only the authority can approve eligibility |
| Transport | Costly trips, delays and small loads | Arrival confirmation and optional pooled transport | Preserve individual ownership, lot identity and receipts |
| Storage | Rain exposure, pests and lack of capacity | Availability referral and centre stock visibility | Software does not create safe storage |
| Sale | Weak bargaining, deductions and few buyers | Comparable offers, measurement evidence and net-return comparison | A published market rate is not a firm offer |
| Payment | Delays, failed transfers and unclear benefit components | Verified reconciliation and grievance support | Displaying “paid” cannot substitute for bank confirmation |
| Inclusion | Difficult access for women, tenants, remote and tribal households | Assisted participation designed with those groups | Verify category-specific rules, language needs and actual access |

NABARD's 2021–22 survey, released in 2024, reported average rural household monthly income of ₹12,698. It includes agricultural and non-agricultural households and is neither current Chhattisgarh farmer income nor farm profit. Use it as context for cost sensitivity, not a pricing assumption. [NABARD findings](https://www.pib.gov.in/PressNoteDetails.aspx?ModuleId=3&NoteId=153270&lang=1&reg=3)

The national NABCONS 2020–22 study estimates paddy harvest/post-harvest loss at 4.77%, comprising 4.16% in farm operations and 0.61% at market stages. This is not a Chhattisgarh queue-loss estimate; Krishi Queue can only affect some causes and must measure its own contribution. [MoFPI publication of study results](https://www.pib.gov.in/Pressreleaseshare.aspx?PRID=2151371&lang=2&reg=48)

Women agri-entrepreneurs interviewed in CRISP/IRRI research reported digital skill, financial, security and family-support constraints. Include women as primary decision-makers and direct research participants, not merely as users represented by a male household member. [CRISP/IRRI research summary](https://www.crispindia.org/digital-innovations-supporting-women-agri-entrepreneurs-in-india-mapping-good-practices/)

**7. Evidence supports useful digital services, not guaranteed benefits from adding information.** A randomised Maharashtra evaluation of Reuters Market Light across 100 villages found no statistically significant average gains in prices or crop value added from the tested SMS service. It is an older, specific intervention, not proof that all digital information fails. [Fafchamps and Minten, 2012](https://openknowledge.worldbank.org/server/api/core/bitstreams/8c37abc7-12bc-5f9b-b24b-ed217ea7221c/content)

A 2026 study with 1,006 farmers found SMS reminders increased adoption of an agricultural app. Its instrumental-variable analysis associated induced engagement with better output prices and lower input spending. This is promising, but effect estimates depend on the study design and assumptions; do not promise the same outcome in Chhattisgarh. [International Potato Center research summary](https://cipotato.org/publication/impact-of-text-messages-on-farmers-adoption-of-agriculture-app-and-its-effect-on-farm-level-outcomes/)

Randomised evidence on facilitated local videos in Bihar supports improved practices, productivity and profits when digital content supplements organised extension. The useful lesson is to combine understandable guidance with trusted local support and an action farmers can actually take. [J-PAL evidence review, July 2025](https://www.povertyactionlab.org/case-study/video-based-support-small-scale-farmers-around-world)

For Krishi Queue, test whether an alert avoids a wasted trip, a receipt resolves a disagreement, or an escalation fixes a failed payment. Page views, chatbot messages and app downloads cannot answer those questions.

**8. Proposed product: an assisted procurement service with a reliable operations dashboard.** The farmer app is one access channel. A centre desk, printed receipt, SMS and authorised helper should reach the same record. These are design recommendations, not features verified as absent from every existing system.

The farmer's home screen should answer four questions: What is my next action? Is my visit confirmed? What has been accepted? What money is confirmed or unresolved? An example, using fictional data, would be: “Your delivery is scheduled for tomorrow. The centre is currently operating. Bring your token and the listed documents. Last confirmed by the centre at 4:10 PM.” If the source is stale or unavailable, say so and provide contact/assistance instead of inventing a live status.

| Priority | Capability | Minimum useful behaviour | Who must participate |
|---|---|---|---|
| P0 | Official-process compatibility | Record authoritative token/reference, its issuer and last verification; label independently recorded references as unverified | Society/centre and system owner |
| P0 | Readiness and correction | Explain missing or mismatched items; create a case with an owner and next action | Registration/support staff |
| P0 | Live centre operations | Open/paused/closed state, reason, last update, remaining operational capacity, expected recovery | Centre manager/operator |
| P0 | Arrival and stage tracking | Distinguish appointment, arrival, verification, quality, weighing, acceptance and unloading | Staff at actual workstations |
| P0 | Assistance without personal smartphone ownership | Consented helper access, printed token/receipt and communication preferences | Society desk, FPO/SHG or other approved helper |
| P0 | Evidence of sale | Lot, accepted quantity, measurements, rate source, deductions and receipt | Weighing/quality and procurement staff |
| P0 | Payment clarity | Separate pending approval, submitted, bank-confirmed, failed and reversed; track each benefit component | Payment authority or verified reconciliation staff |
| P0 | Exception resolution | Named owner, reference number, due date, action history and reopening | Responsible centre/district team |
| P1 | Transport coordination | Optional driver/provider booking; farmer can use own arrangements | Local transport providers |
| P1 | Harvest/weather readiness | Current local alert with source and practical action | IMD/IGKV/extension source |
| P1 | Nearby net-return comparison | Correct crop/variety/grade/date, transport and handling costs, payment timing | Market-data source plus actual buyer verification |
| P2 | Broader agronomy and finance links | Curated handoff to existing expert services | Expert and institutional partners |

**Scheduling needs capacity and fairness, not only a position counter.** A centre may be limited by verification throughput, weighing lanes, unloading labour, available bags, safe storage or outbound lifting. Capture the binding constraint before changing arrivals. For example, if grain is not being lifted and the yard is full, sending more farmers to an apparently free weighing lane will worsen the backlog.

Use quantities and expected service effort rather than assuming every vehicle is equivalent. Maintain separate appointment and stage queues. Publish who may reorder a queue, acceptable reasons, and an audit trail. An override should remain visible to supervisors, without exposing farmer identity to other users.

Define the estimate: time until gate entry, until weighing, or until departure. At first, use observed recent service times, quantity bands, available lanes, pauses and a range rather than a precise minute. Backtest predictions before calling them reliable. “Three lots ahead; likely 40–70 minutes; updated at 11:20” is an illustrative presentation, not a measured performance claim.

A full waitlist with a fair, published allocation process may be better than repeated refreshes at a slot-release time. Any change to government priority/quota rules needs authority approval. An independently implemented app must not silently override official entitlement or issue a second competing queue.

**Exceptions are normal workflow states.** Include no-show, late arrival, centre cancellation, rain interruption, unavailable equipment, biometric failure, changed phone, record correction, quality retest, partial acceptance, rejected quantity, remaining entitlement and payment failure. Keep a reason and responsible actor for each. Do not punish a farmer for a delay caused by the centre; implement the authority's actual rescheduling rule.

**Receipts should make disagreement resolvable.** Store declared quantity, gross/tare/net weight, accepted quantity, test result and method, crop grade, authorised deductions, unit, procurement rate source and who recorded them. Explain them in plain Hindi. Record a retest request and its result. A receipt acknowledged by a farmer is not proof that every deduction was lawful or agreed without pressure.

The app should distinguish the farmer delivering to a centre from a transporter moving purchased grain to storage or a mill. These are different jobs with different authority, documents and tracking requirements. Continuous location tracking should not be the default for every farmer.

**9. Keep accessibility and trust inside the core workflow.** Start with Hindi and test Chhattisgarhi wording/audio locally. In tribal areas, discover the actual preferred language instead of assuming Hindi covers everyone. Human-recorded instructions for common tasks can be cheaper and more predictable than generative voice services. Use large tap targets, readable numbers, explicit units, visible back/retry actions and text alongside colour/icons.

Assume internet may be intermittent, costly or absent at the point of use. Allow browsing and data entry offline, save changes in an encrypted local outbox, show their pending/unconfirmed status, and reconcile them safely after reconnection. Show when each saved record was last verified. Do not promise an appointment or use an offline screen as proof that a central capacity reservation succeeded. Prevent double submissions with idempotent request IDs, display conflicts to the user, and make the server's confirmed result clear. Keep the last official token, receipt, centre location and help number available for offline viewing. Design small payloads that work over slow mobile data; avoid relying on maps, video, large images, continuous polling or a persistent connection for essential tasks.

Support shared devices deliberately. A helper's phone number is not the farmer's permanent identity. Give helpers limited, revocable access and log who acted. Hide personal details after use, offer a PIN-protected farmer session, and make logout clear. Consent should be understandable and specific; do not require access to contacts or continuous location to display a token.

Cache the last verified token, receipt and update time for viewing without connectivity. A request entered offline must remain pending until capacity is confirmed centrally. If a partner requires offline allocation, design bounded, pre-authorised quotas and reconciliation with them; merely saving a booking on a phone cannot prevent overselling.

Offer several ways into the service: lightweight Android app, a low-data mobile web view where feasible, ordinary SMS for short reminders, printed tokens/receipts and an assisted counter at a partner farmers' society/FPO/SHG or village service point. Evaluate an interactive voice response line only after discovering which people cannot use reading-based messages and who will maintain it. Basic SMS may confirm a previously issued appointment or provide a callback number; do not rely on SMS as an authenticated way to change land, bank or entitlement records. None of these routes is a substitute for authority rules or an operational back office. Budget for staff training, print stock, support and outage procedures: a staffed help route that stops working on a busy procurement day makes the digital exclusion worse.

Keep instructions short and task-based: “Your visit is confirmed for Tuesday; show reference 1234 at gate 2” rather than a paragraph of terminology. Test whether farmers can identify the correct reference, understand quintal versus kilogram and distinguish “request sent” from “token issued”. Test with older adults, women who may share a device, farmers with low literacy, remote villages and users with visual/motor limitations. Measure completion and error rates separately by assisted and self-service route. Do not collect more demographic or disability information than necessary and consented to for evaluating access.

Avoid forcing repeated OTP verification during ordinary use. For real account changes, use an appropriate secure recovery process. Staff need individual accounts and centre-scoped permissions. Show partial account details only where necessary; keep personal data out of public queue displays and QR payloads.

India's DPDP framework has phased commencement following the 2025 notifications. Confirm the applicable provisions and government contract terms for the launch date. Independently of the timeline, minimise collection, restrict access, explain purposes, secure storage/transit, define retention and support correction. This is a product requirement, not a finding that the existing prototype violates a particular provision. [MeitY 2025–26 annual report](https://www.meity.gov.in/static/uploads/2026/04/46face7d48c8f6a97030f713ad5fdab4.pdf)

**10. AI should explain verified information and hand off unresolved cases.** Your current read-only support scope is sensible. Preserve it. A useful assistant could explain a receipt, read the latest token status aloud, describe a verified rule with its date, or guide someone through the next correction step.

Status and financial numbers should come from deterministic backend queries. Use approved, dated documents for explanations; include the source and admit when information is missing. Do not let a language model decide crop quality, eligibility, queue priority, payment completion or a farmer's creditworthiness. Do not interpret a generated answer as evidence that an official action occurred.

Send only the minimum required context to external AI services. An ordinary queue question does not need a full payment reference or identity record. Apply quotas and keep essential workflows available when the provider is slow or unavailable. Use curated answers for common issues before paying for a model call. Validate Hindi/Chhattisgarhi comprehension with users rather than claiming support from a prompt alone.

General disease diagnosis, input recommendations and government-scheme advice already have specialised providers. Referral to Crop Doctor, IGKV/KVK experts or official services can provide more value initially than another broad chatbot. Public availability does not imply an unrestricted API, free commercial reuse or a partnership.

**11. What the repository currently supports, and what must change.** These are code-inspection findings. The app and tests were not executed for this research. Existing feature separation, shared booking flow, status histories, Firebase role-claim check and distinction between market-reference and procurement rates are useful foundations.

| Current implementation | Why it limits a real pilot | Recommended change |
|---|---|---|
| `BookingRepositoryImpl` holds one in-memory booking | New bookings replace the current record; there is no shared, persistent multi-farmer system | Durable bookings, deliveries and history scoped to farmer, centre and season |
| `booking_screen.dart` contains demo centres, distances, load and slot availability | A farmer could mistake demonstration values for operational facts | Authoritative configuration and measured availability; explicit simulation mode |
| New bookings use a demo farmer ID and initial queue position 6 | Not linked to actual authenticated ownership or competing arrivals | Server-assigned identifiers, ownership checks and transactional allocation |
| `QueueState`/`QueueEngine` use position × average time plus buffer | No actual workload, lanes or equipment pauses; estimate meaning is ambiguous | Define the queue stage and measure the work ahead; calibrated time ranges |
| Farmer-facing screens can advance queue/procurement demo states | Real users must not grant themselves verification or payment | Restrict mutation to authorised backend operations; keep demo controls in demo mode |
| `ProcurementEngine` synthesises weight, grade A, bills and payment references | Demonstrates the happy path but cannot substantiate an actual sale | Recorded measurements, authorised approvals and verified payment events |
| Staff workflow requires assigned/arrived driver | Could exclude self-arranged transport; this is an unvalidated business rule | Make transport optional unless the specific workflow requires assignment |
| A linear procurement enum bundles operations and payment | Cannot represent partial acceptance, retest or failed/reversed payment cleanly | Separate delivery, quality, acceptance, invoice and payment state |
| Quantity is an integer number of quintals and dates include display strings | Real weighment and reconciliation require precise units and timestamps | Defined fixed precision for weights/money, typed dates and explicit units |
| Market API reads the first 100 records without location-specific selection | No assurance of useful Chhattisgarh coverage or complete relevant results | Local filters, pagination where needed, data validation and freshness display |
| Keys for third-party services are client build values | Distributed clients cannot keep provider credentials secret | Protected backend calls, caching, cost controls and minimal AI context |
| Most UI text is English; chat language support is prompt-based | Main journeys remain inaccessible for many target users | Real localisation and field-tested audio/assisted operation |
| Tests focus on booking validation/transitions/repository and login rendering | They do not demonstrate concurrency, reconciliation or offline safety | Test oversubscription, duplicate retries, access boundaries, partial delivery and payment failures |

Relevant files: [app composition](C:/Users/Justy/Documents/Krishi-Queue/lib/main.dart), [booking repository](C:/Users/Justy/Documents/Krishi-Queue/lib/features/booking/data/booking_repository_impl.dart), [booking UI](C:/Users/Justy/Documents/Krishi-Queue/lib/features/booking/presentation/booking_screen.dart), [queue logic](C:/Users/Justy/Documents/Krishi-Queue/lib/features/queue/domain/queue_engine.dart), [procurement logic](C:/Users/Justy/Documents/Krishi-Queue/lib/features/procurement/domain/procurement_engine.dart), [staff workflow](C:/Users/Justy/Documents/Krishi-Queue/lib/features/staff/presentation/staff_workflow_screen.dart), [market API](C:/Users/Justy/Documents/Krishi-Queue/lib/features/market/data/market_price_repository.dart), [AI context](C:/Users/Justy/Documents/Krishi-Queue/lib/features/ai_chat/presentation/ai_chat_screen.dart).

Do not replace Flutter or introduce microservices solely because the state RFP uses them. For a small independent pilot, a well-structured backend with a transactional datastore, explicit permissions, audit events and reliable backups is simpler. Existing Firebase Authentication can remain; choose data hosting after confirming partner requirements, access needs and costs. This report does not assume a free production tier will cover the system.

The minimum durable records are farmer/authorised helper, centre, season-policy version, entitlement/reference, appointment, delivery lot, measurements, acceptance/receipt, payment component, grievance and audit event. One farmer may have several deliveries; one delivery may have partial acceptance; a payment can have several components. Preserve external official IDs separately from internal IDs.

Critical invariants: capacity cannot be double booked; a retry cannot create a second purchase; sold quantity cannot silently exceed verified remaining entitlement; only authorised users can change operational state; stale updates cannot overwrite newer measurements; a payment cannot become confirmed merely because a button was pressed. Store both event time and server receipt time where offline events occur.

**12. Integration should have an explicit fallback plan.** I did not verify a publicly available production API that permits Krishi Queue to issue Chhattisgarh tokens or retrieve personal procurement/payment records.

| Integration | First practical route | What must be verified |
|---|---|---|
| Official tokens/registration | Approved API if provided; otherwise authorised staff-assisted reference capture | Permission, identity matching, data freshness and what constitutes verification |
| Centre operations | Named operator records a small set of real events | Who updates it, workload, offline handling and accountability |
| Weighing/quality | Signed/manual measurement entry with evidence before hardware integration | Equipment calibration, record authority and correction process |
| Payment | Approved status feed or authorised reconciliation of official records | Exact definition of submitted, credited, failed and reversed |
| Market information | Existing government dataset filtered to relevant markets | Units, variety, observation date, pagination and licence/API conditions |
| Weather | Current IMD district/region advisory or approved feed | Validity, location and reuse/access terms |
| AI and voice | Curated help, device accessibility and minimal optional model calls | Language quality, privacy, failure behaviour and actual cost |

IMD already exposes regional advisories and a government service describes district/date/language selection. Prefer verified alerts and links over unvalidated weather predictions. [IMD advisory service](https://imdagrimet.gov.in/AGStateAasBulletinView.php), [Government service description](https://services.india.gov.in/service/detail/check-weather-forecast-summary-of-agricultural-meteorology-division-1)

A public bulletin or dashboard is not a complete operational API. Avoid dependence on brittle authenticated scraping. If a pilot uses staff-entered information, state that clearly, show its age and measure entry burden. If staff cannot maintain it accurately, live ETA must be suspended rather than shown with false certainty.

**13. There are three credible delivery models.** Choose one before expanding implementation.

| Model | Value | Main dependency | Recommendation |
|---|---|---|---|
| Centre/PACS operations companion | Reduces crowding, repeated enquiries and unresolved transactions | A cooperative centre and agreement on authoritative records | Strongest initial test |
| Farmer assistance service with FPO/SHG/local support | Helps with documents, official-token navigation, receipts and complaints | A trusted assistance network | Useful fallback when deep integration is unavailable |
| Independent private/FPO procurement workflow | Scheduling and receipts for consenting private buyers and suppliers | Real purchasing partner, clear terms and applicable market requirements | Possible separate product; do not imply government MSP authority |

Direct government-system replacement requires procurement access and institutional commitments. A broad farmer marketplace requires buyer liquidity, transport, quality resolution and settlement capability. Neither should be assumed to emerge from a successful mobile demo.

Keep the core farmer service free during validation. A centre, cooperative, FPO, implementing partner or funded pilot could pay for verified operational value; these are hypotheses to test with actual buyers, not secured revenue. Never charge for queue priority or create incentives to exaggerate deductions. If a procurement agency pays, farmers still need accessible receipts and an independent escalation route.

An indicative unit-economics worksheet should include hosting, authentication, SMS/voice, printing, support, travel, training, equipment, maintenance and partner administration. Measure cost per completed transaction and per resolved case. Free/open-source software lowers licensing expense; it does not eliminate staffing, connectivity or messaging costs. Do not add a paid map, voice provider or model until a cheaper practical alternative has been tested.

**Why this could be a startup—and what makes the case difficult.** India's paddy procurement is a large, recurring operation, and the farmer's problems recur every season. If one centre trusts the service and it reduces avoidable visits or staff reconciliation, the same approach may be reusable at other centres. Rural access can create a practical service advantage: the startup that combines usable offline records with local help might solve more than another app download. These are reasons to test the opportunity, not proof of market size or future revenue.

The end farmer should be treated as the primary beneficiary. A farmer with a basic/shared phone, weak signal or seasonal income is unlikely to be a durable source of recurring subscription revenue. Keep the essential service free during initial validation. Test payment with the institution that receives measurable operating value: a cooperative, FPO, procurement operator, state programme, or a responsible implementation partner. The right payer remains unknown until interviews and a pilot validate budgets, buying authority and procurement timelines.

This is likely a partner-led business, which has real costs and trade-offs. Government contracts can take time; private access to system records may not be available; different states may have different policies and workflows. A local service team, training, printing, phone support and maintaining accurate centre updates could cost more than the software. Revenue should come from transparent software and operational support, implementation or clearly scoped service contracts—not sale of farmer data, paid queue priority, undisclosed commissions, or deductions from a farmer's sale.

The startup thesis is strongest if a small pilot demonstrates all four of these:

1. Farmers complete more of the official sales journey with fewer wasted trips or lower out-of-pocket cost.
2. Centre staff save enough time or reduce errors enough that an accountable institution will pay to keep the service running.
3. Assisted and offline routes cost less to operate per completed case over time as local staff gain proficiency, without leaving unconnected farmers behind.
4. A second centre can use the service with modest configuration and training, while preserving local policy, trusted relationships and government system authority.

If the service needs expensive manual support for every delivery, depends on unavailable token/payment data, or institutions will not fund it, it may remain valuable as a public-interest or NGO/CSR-backed service but weak as a self-sustaining venture. That is a useful early conclusion, not a reason to dress weak demand up as app traction. Count paying institutions and successful cases, not registered accounts.

**Can the developer earn from this? There are two different answers.** If “we” means you are hired to build the product, you can earn a developer's agreed salary or contract fee once an employer/customer pays you for work. That income does not depend on the app succeeding with farmers. If you own the venture, you might earn salary from a funded operating company or receive profit later if revenue exceeds all expenses. Owning an app or getting downloads does not itself create income. A founder can go months or longer without salary while selling, supporting a pilot and paying operating costs. Do not treat grants, investment or signed letters of intent as customer revenue.

| Revenue path | What the customer pays for | Likely fit / dependency | Assessment |
|---|---|---|---|
| Paid discovery, design and implementation contract | Mapping one procurement workflow, configuring software, training staff and setting up agreed reports | A centre/network/operator commissioning a pilot; written scope and milestone acceptance | Clearest first way for a developer to get paid for building work; distinct from startup recurring revenue |
| Annual per-centre software and support fee | Staff dashboard, approved workflow records, issue tracking, training, backups and support | A cooperative/FPO/operator budget plus authority to keep the records | Best recurring-revenue hypothesis to test; pilot must prove continuing value and renewal intent |
| Implementation and data-integration fee | Approved connection to existing systems, import, configuration and reconciliation | Authorised system owner, documented APIs, security review and acceptance | Potentially valuable paid work; never assume an API exists or promise access before it is granted |
| Seasonal operations support | A staffed helpdesk, print/SMS route, field training, incident handling and after-season reporting | A public/partner programme budgets for people as well as software | Can fund real assisted access; labour-heavy, so report cost per completed case and service hours |
| FPO/private-buyer subscription | Orders, collection scheduling, weights, receipts and settlements for an actual private buyer | A committed buyer/supplier who chooses the workflow and pays | More independent of government procurement, but requires a new product scope and must not imply MSP access |
| CSR, research, development or philanthropic pilot funding | A defined inclusion, digitisation, evaluation or infrastructure-outcomes pilot | Funder and implementing partner agree on measured outcomes | Can fund early validation and independent evaluation; restricted/temporary funding is not proof of repeat demand |
| Per-transaction or percentage fee | A charge per booked or completed sale | Clear authority, contract and farmer-centred justification | Higher risk: can make people pay to access an entitlement, reward volume over quality, or resemble a deduction; do not use without explicit legal/contract review and farmer validation |
| Farmer subscription, ad sales, selling farmer data or lending commission | Direct charges, targeting or third-party access | Access to vulnerable, high-sensitivity records | Avoid. It undermines trust and creates incentives against the farmer's interests |

A sensible first sales offer is not “we built an app.” Offer a bounded operational pilot: setup for an agreed number of centres, staff training, assisted access for a defined period, a service desk/receipt workflow and a report comparing baseline outcomes. Agree in writing who supplies source data, who is allowed to correct it, what counts as an official confirmation, how outages are handled, what is excluded and how farmer complaints are escalated. Name the data controller/owner in the contract rather than quietly assuming the startup owns official farmer information.

Do not promise national rollout, income gains or guaranteed shorter queues in a sales pitch before measurement. Offer a low-cost or subsidised discovery phase only when the budget, deadline, success metrics, data access and next purchasing decision are explicit. Free pilots with no named budget owner and no decision date can consume months of engineering time without demonstrating a business.

**Check whether centre software can sustain the company before hiring or scaling.** Set monthly or annual prices with buyers after confirming budgets, alternatives and support needs; this report cannot substantiate a per-centre rupee rate. Use a conservative spreadsheet:

`Annual recurring revenue = paying centres × contracted annual fee per centre.`

`Annual centre contribution = annual fee − direct centre costs (training, field support, SMS, printing, travel and required infrastructure).`

`Break-even paying centres = annual fixed company costs ÷ positive contribution per centre.`

Fixed company costs include founder/developer salaries, sales, security, insurance, compliance and central operations. One-time setup revenue may cover deployment but must not be confused with renewals. If the centre contribution is zero or negative after realistic support costs, a higher scale can increase losses. Recalculate using actual paid invoices and real pilot support hours after each season.

Track these sales and operating measures together: centres contacted, accountable decision-makers met, written pilot proposals, paid pilots, contract-to-live time, contract value actually paid, renewal/expansion decisions, support cost per centre, cost per completed sale and contribution after direct support. For the farmer, also track time/travel savings, successful completion, dispute resolution, assisted-route success and access failures. A product can have paying customers and still fail farmers; a helpful pilot can benefit farmers but lack a payer. The venture needs both to become a sustainable business.

**Protect the farmer when the buyer is also the authority.** A government body or procurement operator may purchase the service and control the records. Make the interface show the record source and latest update, keep an auditable change history, and provide an escalation channel outside the person whose actions are disputed. Never let an agency or centre use the dashboard to penalise a farmer for a network outage or unresolved official-system failure. A paid customer is not permission to make farmer access contingent on using the startup's app.

**A practical go/no-go order for the founders.** First, find the person who owns the unresolved workflow and can authorise the pilot. Second, confirm a lawful, technically workable data path. Third, observe farmer journeys and document baseline cost and time. Fourth, sell or secure a funded pilot with an identified budget owner, finite scope and decision date. Fifth, build only the P0 features that the partner can maintain. Sixth, measure outcomes and full delivery costs. Ask the same partner for a paid season-two contract, and ask a second centre whether the same core workflow fits. If nobody will pay after seeing measured operating benefit, do not add features on the assumption that download growth will solve sales.

**14. A field pilot should validate the problem before expanding the app.** The following is a proposed sequence, not a delivery guarantee. Starting on October 31, with the next season approaching, prioritise observation and a tightly scoped assisted trial over a rushed statewide transactional launch.

**First 2 weeks: map the real process.** Recruit 2–3 cooperating centres with contrasting volume/connectivity, through the relevant authority. Interview approximately 30–40 farmers across 4–6 villages, 6–8 centre workers, transporters, an FPO/SHG representative, a registration official and someone responsible for payment reconciliation. These are purposive discovery samples, not statistically representative statewide surveys. Include people who failed to book, sold elsewhere, need help with a phone, are older, are women, are tenants or hold forest-rights titles where applicable. Don't recruit only satisfied app users at a functioning centre.

Ask participants to reconstruct their last sale: number of trips, actual waits, travel expense, documents, who used the phone, token attempts, quality deductions, amount received and timing. With consent, inspect receipts and timelines. Ask what the intermediary or society did that was useful. Avoid leading with “Would you use my app?” A specific avoided cost is better evidence than polite enthusiasm.

Observe opening, peak arrivals and closing at each centre. Record where the line actually stops, whether work occurs in parallel, which staff maintain official records and what triggers a pause. Ask what caused the last failed transfer and who could resolve it. Confirm policy for partial deliveries, exceptions and remaining quantity. Identify an authorised owner for each data field.

**Next 2–4 weeks: shadow the workflow.** Record operational events without changing official queue order or entitlement. Compare proposed estimates with observed times, test Hindi wording and a paper/SMS fallback, and reconcile recorded receipts with official records. Run a manual assistance desk if authorised; a shared structured register may test the process before software changes are justified. Proceed only if operators can maintain accurate records without unacceptable duplicate work.

**Next 4–8 weeks: a bounded live pilot.** Enable the selected P0 features for an agreed cohort, for example 200–500 participating farmers if season timing and capacity permit. This is an operational test size, not a power calculation. Maintain the existing official route for everyone. Use matched comparison days/centres or a phased rollout; if feasible, have an independent evaluator design randomisation without withholding entitled services. Record weather, quantities and staffing so improvements are not wrongly attributed to software.

| Outcome | Measurement | Proposed initial decision threshold |
|---|---|---|
| Waiting | Median and 90th percentile arrival-to-departure time; also pre-visit token delay | Aim for at least 25% median reduction with no deterioration in long waits |
| Wasted visits | Farmer-reported visits that failed, corroborated where possible | Clear reduction versus baseline; report causes |
| Farmer costs | Transport, loading, repeat visits and evidenced losses, kept separate | Positive net saving after any new costs; no invented rupee impact |
| Reliability | Duplicate reservations, lost events, incorrect receipts | No unresolved critical integrity failures before expanding |
| ETA | Actual start falling within published interval; interval width | Calibrate a predeclared target, e.g. 80% coverage, with an interval narrow enough to help |
| Payment truthfulness | Displayed confirmation versus authoritative reconciliation | No unverified “paid” status |
| Inclusion | Completion/failure rates by assisted vs self-service and relevant groups | No unexplained worsening for assisted or underserved users |
| Staff effort | Time per transaction plus reconciliation/support effort | At least no increase unless a measured farmer benefit justifies it |
| Complaints | Resolution time, reopened cases and farmer acknowledgement | Improvement versus baseline; do not count auto-closure as resolution |

Measure both wait reduction and total completion. Shorter queues caused by excluding farmers are not success. Seasonal return, successful assisted completion and farmer recommendation are more relevant than daily active use. Obtain feedback privately enough that farmers can report problems without fearing consequences at the centre.

**15. Test these assumptions before committing to a larger build.** They are the major unresolved business and research questions.

1. Is the dominant local pain token access, waiting after arrival, record mismatch, quality dispute, payment delay or transport cost? What proportion of failed journeys does each explain?
2. What share of app interactions are performed by farmers, relatives, society staff or paid helpers? What fees or dependencies exist?
3. Will an operator maintain centre status throughout the day, including uncomfortable updates such as backlog or closure?
4. Is queue ordering permitted to change, and by whom? Can the centre honour appointment windows?
5. Is current daily capacity limited by quintals, storage, staff, lanes, or outgoing lifting? How often is it changed?
6. What access will NIC, the department or the UPAHAR implementation partner actually provide? What is already planned or delivered?
7. Which 2026–27 registration exceptions and payment calculations are officially operative? What are the correction channels?
8. Who owns a partial sale or payment-failure case after the farmer leaves the centre?
9. Can the farmer use self-arranged transport and still complete every necessary stage?
10. Is there an institution willing and able to pay enough to sustain support, without creating harmful incentives?

Pause expansion if authoritative data is inaccessible, staff maintain two incompatible systems, the app creates false confirmations, or outcome improvement disappears after accounting for staffing/weather. Consider stopping or narrowing the product if the partner's existing system already solves the measured issue adequately.

**16. Improving farmer conditions also requires work outside this app.** The highest-impact companion interventions should be chosen from observed local constraints: functioning moisture meters and calibrated scales; adequate bags, covers and drinking water; working toilets/rest areas; planned labour and weighing shifts; faster grain lifting; secure drying/storage; practical document-correction camps; accountable grievance handling; and reliable payment reconciliation. These are interventions to evaluate, not a claim that every selected centre currently lacks them.

FPOs can help aggregate smaller lots, coordinate transport and strengthen market access. The government reports 10,000 FPOs registered under its central scheme and cumulative turnover above ₹20,340 crore as of the July 2026 reply. Registration alone does not establish that a particular FPO is active or well governed; validate local records and member experience before partnership. [Official FPO and marketing update](https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2290633&lang=2&reg=48)

Beyond paddy, first investigate a specific crop and purchasing channel. Vegetables need time-sensitive dispatch and rejection handling; millets and pulses may require aggregation and identified buyers; forest produce involves different collectors, rights and institutions. Do not copy paddy entitlement rules into these markets. Crop diversification should be evaluated against water, agronomy, labour, buyer demand, expected net margin and downside risk with local experts.

For net-return comparison, use: expected accepted quantity × credible price, minus transport, loading, handling, permitted deductions, storage and other documented selling costs. Display payment timing separately and show ranges when uncertain. For app impact, compare actual costs and outcomes against a credible baseline; avoid double-counting time savings, wage loss and transport charges.

**17. Recommended implementation order.** First obtain a cooperating centre and map its real workflow. Then preserve the Flutter structure while replacing demo data with durable, authorised records; add Hindi and assistance; add centre status, receipts and exception cases; validate stage timing; add payment reconciliation; and only then expand optional AI, market comparison or transport features. The app's competitive advantage would be reliable execution and resolution of local problems, demonstrated with evidence.

At the time of the research, no government integrations, interviews, external outreach, deployments or payment operations were performed. The implementation addendum below records subsequent application work; it does not change the research evidence or establish government approval.

**18. Implementation addendum — 1 November 2026.** The app now provides Hindi/English core screens, guest access, persistent personal visit preparation, checklists, readable offline guidance, an offline support chat, larger text, a low-data default, and clearly separated practice workflows. A separate browser light version avoids downloading Flutter before the user chooses it; its core files total about 23 KB uncompressed and it can reopen offline after successful first caching. Saved plans are personal reminders, not official tokens or pending reservations. Browser light plans and Flutter plans are stored separately.

Google/phone sign-in code and an authenticated server gateway for BHASHINI Hindi/English text translation, optional online assistance, mandi reports and news have been implemented. Provider credentials remain server-side. Online text is sent only after disclosure/consent; offline help does not require these services. Public reports retain their dates and can be read from a saved cache after a failed update. These integrations have automated tests using simulated providers, but live provider credentials and government access are not verified. No cloud deployment has been performed.

This implementation deliberately does not manufacture official verification, centre capacity, bank payments or queue updates. Existing demonstrations remain labelled practice data. Official procurement integration, real SMS/IVR delivery, production voice support, a reviewed Chhattisgarhi translation, staff-supported exceptions and a one-centre field pilot remain distinct work requiring authoritative partners and validation. A service being technically connectable is not evidence that a farmer is eligible or that a government department accepts its records.

The commercial recommendation remains institution-funded service and support with free core farmer access, validated against actual savings and operator willingness to pay. Offline functions incur no per-question provider cost; hosting, SMS, optional models, BHASHINI production access, deployment billing and seasonal support must be priced separately. No revenue, adoption or wait-time reduction is claimed from implementing the interface. See [implementation status](docs/IMPLEMENTATION_STATUS.md), [sign-in setup](docs/AUTH_SETUP.md) and [online-service setup](functions/README.md) for test evidence and remaining launch requirements.
