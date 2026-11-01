'use strict';
(() => {
  const $ = id => document.getElementById(id);
  const key = 'krishi-lite-plan-v1';
  const hi = Object.fromEntries([...document.querySelectorAll('[data-t]')].map(el => [el.dataset.t, el.textContent]));
  const en = {
    title: 'From farm to centre, prepared.', intro: 'A light version for slow connections. Prepare your visit and get help without signing in.', full: 'Open the full app',
    warning: 'This is not a government service. Saving a plan does not book a token or slot. Confirm with your registered society before travelling.',
    offline: 'After the first visit, this light page will try to save itself for offline use.', plan: 'My visit preparation',
    local: 'Saved only in this browser, separately from the full app. Do not enter bank details, Aadhaar, PINs or OTPs.',
    centre: 'Registered society / centre', village: 'Village / district (optional)', crop: 'Crop', quantity: 'Quantity (quintals; 1 quintal = 100 kg)', date: 'Planned date (not a reservation)',
    registration: 'Registration and eligibility checked with my society', token: 'Official token, centre and date confirmed', documents: 'Documents requested by my society are ready',
    quality: 'Moisture, quality and packaging requirements checked', transport: 'Transport cost and arrival time agreed', receipts: 'I will keep weighing, quality and purchase receipts',
    save: 'Save in this browser', print: 'Print / save as PDF', clear: 'Delete plan', help: 'Useful help',
    helpTokenTitle: 'Token or registration', helpToken: 'Ask your registered society and the Chhattisgarh Food Department about current rules. Krishi Queue cannot verify or book a government token.', food: 'Chhattisgarh Food Department',
    helpPaymentTitle: 'Payment has not arrived', helpPayment: 'Keep the purchase slip, weighing receipt, date and reference. Ask your society for the payment status and bank reference, then check with your bank. Keep the complaint number and date. Never give an OTP or UPI PIN to receive money.',
    helpQualityTitle: 'Questions about weighing or quality', helpQuality: 'Ask for weight, deductions and grade in writing. Keep wet or damaged grain separate. Ask your society about moisture limits, retesting and appeals. This app cannot guarantee acceptance or a purchase price.',
    helpCropTitle: 'Crop disease or farming advice', helpCrop: 'Speak to an agriculture expert or Kisan Call Centre with your crop, symptoms, crop age and village details. Do not choose a pesticide or dose based only on a chat answer.',
    helpFraudTitle: 'Shared phones and fraud', helpFraud: 'Do not enter Aadhaar, bank numbers, OTPs or PINs here. Do not pay a private account for a guaranteed payment or token. Delete your plan when finished on a shared phone.',
    callKisan: 'Kisan Call Centre: 1800-180-1551', hours: 'Daily, 6 am–10 pm; farming advice', callFood: 'Chhattisgarh Food Department: 1800-233-3663', source: 'Official call-centre information',
    chat: 'Offline helper', chatIntro: 'Ask about tokens, preparation, payment, weighing or safety. Answers use saved guidance; this is not live AI or an official status check.', question: 'Your question', ask: 'Get help',
    footer: 'Free preparation and information. Centre availability, prices and eligibility need official confirmation. No advertising or tracking scripts.', back: 'Back to start'
  };
  let hindi = true, corrupt = false, dirty = false, offlineReady = false;
  const say = (english, hindiText) => hindi ? hindiText : english;
  const fields = ['centre', 'village', 'crop', 'quantity', 'date'];
  const checks = ['registration', 'token', 'documents', 'quality', 'transport', 'receipts'];
  const form = $('plan-form');
  const state = message => { $('save-state').textContent = message; };
  function language(value) {
    hindi = value;
    document.documentElement.lang = hindi ? 'hi' : 'en';
    document.querySelectorAll('[data-t]').forEach(el => { el.textContent = (hindi ? hi : en)[el.dataset.t] || hi[el.dataset.t]; });
    $('language').textContent = hindi ? 'English' : 'हिन्दी';
    if (offlineReady) $('offline-state').textContent = say('Light page saved for offline use. Official links and calls still need a connection.', 'हल्का पेज ऑफलाइन उपयोग के लिए सहेज लिया। आधिकारिक लिंक और कॉल के लिए कनेक्शन चाहिए।');
    $('answer').hidden = true;
    try { localStorage.setItem('krishi-lite-hindi', String(value)); } catch (_) { /* Help still works. */ }
  }
  try {
    hindi = localStorage.getItem('krishi-lite-hindi') !== 'false';
    const saved = localStorage.getItem(key);
    if (saved) {
      try {
        const plan = JSON.parse(saved);
        if (plan.version !== 1 || !plan.fields || !plan.checks) throw Error();
        fields.forEach(name => { if (typeof plan.fields[name] !== 'string') throw Error(); });
        fields.forEach(name => { form.elements[name].value = plan.fields[name]; });
        checks.forEach(name => { form.elements[name].checked = plan.checks[name] === true; });
        state(say('Saved plan loaded. It is not a government booking.', 'सहेजी तैयारी खुल गई। यह सरकारी बुकिंग नहीं है।'));
      } catch (_) { corrupt = true; state(say('Saved notes could not be read. They have not been overwritten.', 'सहेजे नोट खुल नहीं सके। उन्हें बदला नहीं गया है।')); }
    }
  } catch (_) { state(say('Storage unavailable. Keep a paper copy.', 'सहेजना उपलब्ध नहीं है। कागज़ की कॉपी रखें।')); }
  language(hindi);
  $('language').addEventListener('click', () => language(!hindi));
  form.addEventListener('input', () => { dirty = true; });
  form.addEventListener('submit', event => {
    event.preventDefault();
    if (!form.reportValidity()) return;
    if (corrupt) { state(say('Unreadable notes are preserved. Delete them before saving a replacement.', 'पुराने नोट सुरक्षित रखे हैं। नई तैयारी सहेजने से पहले उन्हें हटाएँ।')); return; }
    const quantity = Number(form.elements.quantity.value);
    if (!Number.isFinite(quantity) || quantity <= 0 || quantity > 10000 || !form.elements.centre.value.trim() || !form.elements.crop.value.trim()) { state(say('Enter a centre, crop and valid quantity.', 'केंद्र, फसल और सही मात्रा लिखें।')); return; }
    const plan = {version: 1, savedAt: new Date().toISOString(), fields: {}, checks: {}};
    fields.forEach(name => { plan.fields[name] = form.elements[name].value.trim(); });
    checks.forEach(name => { plan.checks[name] = form.elements[name].checked; });
    try { localStorage.setItem(key, JSON.stringify(plan)); dirty = false; state(say('Saved in this browser. No slot has been booked.', 'इस ब्राउज़र में सहेज लिया। कोई स्लॉट बुक नहीं हुआ।')); }
    catch (_) { state(say('Could not save. Keep this page open and print or write down your plan.', 'सहेज नहीं सके। पेज खुला रखें और प्रिंट करें या कागज़ पर लिख लें।')); }
  });
  $('print').addEventListener('click', () => window.print());
  $('clear').addEventListener('click', () => {
    if (!window.confirm(say('Delete this browser’s personal plan? This cannot cancel an official token.', 'इस ब्राउज़र की तैयारी हटाएँ? इससे आधिकारिक टोकन रद्द नहीं होगा।'))) return;
    try { localStorage.removeItem(key); form.reset(); corrupt = false; dirty = false; state(say('Personal plan deleted.', 'तैयारी हटा दी गई।')); }
    catch (_) { state(say('Could not delete. Try again.', 'हटा नहीं सके। फिर कोशिश करें।')); }
  });
  window.addEventListener('beforeunload', event => { if (dirty) { event.preventDefault(); event.returnValue = ''; } });
  $('chat-form').addEventListener('submit', event => {
    event.preventDefault();
    const query = $('question').value.trim().toLowerCase();
    if (!query) return;
    let topic;
    if (/payment|bank|money|paisa|bhugtan|भुगतान|बैंक|पैसा/.test(query)) topic = 'helpPayment';
    else if (/quality|weight|weigh|moisture|taul|nami|तौल|नमी|गुणवत्ता/.test(query)) topic = 'helpQuality';
    else if (/disease|pesticide|spray|fertiliz|बीमारी|दवा|कीट|खाद/.test(query)) topic = 'helpCrop';
    else if (/fraud|otp|pin|scam|आधार|धोखा|पिन/.test(query)) topic = 'helpFraud';
    else if (/token|slot|register|booking|टोकन|स्लॉट|पंजीकरण/.test(query)) topic = 'helpToken';
    const words = hindi ? hi : en;
    $('answer').textContent = topic ? words[topic] : /prepare|checklist|document|तैयारी|दस्तावेज/.test(query) ? checks.map(name => words[name]).join('। ') : say('Ask about preparation, tokens, payment, weighing or safety. For current prices or crop advice, contact your society or call 1800-180-1551.', 'तैयारी, टोकन, भुगतान, तौल या सुरक्षा पर पूछें। वर्तमान भाव या खेती की सलाह के लिए समिति से पूछें या 1800-180-1551 पर कॉल करें।');
    $('answer').hidden = false;
  });
  if ('serviceWorker' in navigator && window.isSecureContext) {
    navigator.serviceWorker.register('lite-sw.js').then(() => navigator.serviceWorker.ready).then(() => { offlineReady = true; language(hindi); })
      .catch(() => { $('offline-state').textContent = say('Offline page saving unavailable. Keep a paper copy.', 'पेज ऑफलाइन सहेज नहीं सके। कागज़ की कॉपी रखें।'); });
  }
})();
