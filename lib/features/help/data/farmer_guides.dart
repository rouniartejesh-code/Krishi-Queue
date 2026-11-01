/// Short editorial guidance bundled with the app, available without internet.
/// Rules, procurement rates and dates belong to the official seasonal order;
/// this guide deliberately does not hard-code eligibility or entitlements.
class FarmerGuide {
  final String id;
  final String title;
  final String titleHindi;
  final String summary;
  final String summaryHindi;
  final List<String> steps;
  final List<String> stepsHindi;

  const FarmerGuide({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.summary,
    required this.summaryHindi,
    required this.steps,
    required this.stepsHindi,
  });

  bool matches(String query) {
    final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final content =
        '$title $titleHindi $summary $summaryHindi '
                '${steps.join(' ')} ${stepsHindi.join(' ')}'
            .toLowerCase();
    return words.every(content.contains);
  }
}

const farmerGuides = <FarmerGuide>[
  FarmerGuide(
    id: 'before-visit',
    title: 'Before you leave for the centre',
    titleHindi: 'केंद्र जाने से पहले',
    summary: 'Confirm your official token, documents and centre opening before paying for transport.',
    summaryHindi: 'गाड़ी का खर्च करने से पहले सरकारी टोकन, कागज़ और केंद्र खुलने की पुष्टि करें।',
    steps: [
      'Check your registration and official token with your society or the official Token Tuhar service. A plan saved in Krishi Queue does not reserve a slot.',
      'Ask the centre to confirm the delivery date, time, accepted crop and quantity. Ask about rain, storage space and any delay before loading.',
      'Keep your official token or paper receipt, farmer registration details and the documents the centre has asked for. Confirm the current document list locally.',
      'Keep produce covered and ask the centre about current moisture and quality requirements. Do not rely on a sample price or estimate in an app.',
      'Write down your centre contact and transport charge. If your phone is shared, keep a paper copy of the token and receipts.',
    ],
    stepsHindi: [
      'अपनी समिति या सरकारी Token Tuhar सेवा से पंजीयन और सरकारी टोकन जाँचें। Krishi Queue में सहेजी योजना से समय आरक्षित नहीं होता।',
      'केंद्र से तारीख, समय, फसल और मात्रा की पुष्टि करें। माल लादने से पहले बारिश, भंडारण और देरी के बारे में पूछें।',
      'सरकारी टोकन या पर्ची, किसान पंजीयन जानकारी और केंद्र के बताए कागज़ साथ रखें। अभी कौन से कागज़ चाहिए, यह समिति से पूछें।',
      'उपज को ढककर रखें। नमी और गुणवत्ता के मौजूदा नियम केंद्र से पूछें। ऐप के नमूना भाव या अनुमान पर भरोसा करके न निकलें।',
      'केंद्र का संपर्क और गाड़ी का किराया लिख लें। साझा फोन हो तो टोकन और रसीद की कागज़ी प्रति भी रखें।',
    ],
  ),
  FarmerGuide(
    id: 'weighing',
    title: 'At the weighing and quality check',
    titleHindi: 'तौल और गुणवत्ता जाँच के समय',
    summary: 'Check the figures and keep the receipt before leaving.',
    summaryHindi: 'आँकड़े जाँचें और जाने से पहले रसीद लें।',
    steps: [
      'Ask staff where to wait safely. Follow the centre’s announced order; a sample queue in this app is not a gate pass.',
      'Check gross weight, empty vehicle or bag weight (tare), and net weight. One quintal is 100 kilograms.',
      'Ask staff to explain the quality result and any rejection or deduction. Request the reason in writing and ask about the review process.',
      'Check the farmer name, crop, quantity, date and rate on the purchase receipt. Ask staff to correct mistakes before you leave.',
      'Keep the original receipt safe. Never pay an unofficial fee to move ahead in the queue.',
    ],
    stepsHindi: [
      'सुरक्षित प्रतीक्षा की जगह कर्मचारियों से पूछें। केंद्र का बताया क्रम मानें; इस ऐप की नमूना कतार प्रवेश पर्ची नहीं है।',
      'कुल वजन, खाली गाड़ी या बोरी का वजन (टैयर) और शुद्ध वजन जाँचें। एक क्विंटल में 100 किलोग्राम होते हैं।',
      'गुणवत्ता का नतीजा और कटौती या अस्वीकृति का कारण पूछें। लिखित कारण और दोबारा जाँच की प्रक्रिया माँगें।',
      'खरीदी रसीद में किसान का नाम, फसल, मात्रा, तारीख और दर जाँचें। गलती हो तो जाने से पहले सुधार करवाएँ।',
      'मूल रसीद सुरक्षित रखें। कतार में आगे जाने के लिए अनधिकृत शुल्क न दें।',
    ],
  ),
  FarmerGuide(
    id: 'payment',
    title: 'Payment delayed or amount looks wrong',
    titleHindi: 'भुगतान रुका है या रकम गलत है',
    summary:
        'Use the purchase receipt and bank statement to trace the payment.',
    summaryHindi: 'खरीदी रसीद और बैंक खाते के विवरण से भुगतान जाँचें।',
    steps: [
      'A bill or “transfer started” message does not confirm that money reached your account. Check your bank passbook, statement or official bank service.',
      'Compare the purchased quantity and approved rate with the receipt. Market reference prices are not guaranteed procurement prices.',
      'Contact the purchasing society with the purchase date and receipt number. Ask for the official payment status, transfer reference and next follow-up date.',
      'If a transfer failed, ask the society and bank what must be corrected. Do not publish your bank account, Aadhaar or OTP in chat.',
      'Record whom you spoke to, the date and any complaint reference. Keep following up through the official channel; this app cannot release payments.',
    ],
    stepsHindi: [
      'बिल बनने या “भुगतान भेजा गया” लिखने से खाते में पैसा आने की पुष्टि नहीं होती। पासबुक, बैंक विवरण या बैंक की सरकारी सेवा से जाँचें।',
      'खरीदी मात्रा और स्वीकृत दर को रसीद से मिलाएँ। मंडी का भाव सरकारी खरीदी की गारंटी वाली दर नहीं है।',
      'खरीदी तारीख और रसीद नंबर के साथ समिति से संपर्क करें। भुगतान की सरकारी स्थिति, ट्रांसफर संदर्भ और अगली पूछताछ की तारीख लें।',
      'ट्रांसफर विफल हो तो समिति और बैंक से सुधार पूछें। बैंक खाता, आधार या OTP चैट में न भेजें।',
      'किससे बात हुई, तारीख और शिकायत नंबर लिखें। सरकारी माध्यम से पूछताछ करते रहें; यह ऐप भुगतान जारी नहीं कर सकता।',
    ],
  ),
  FarmerGuide(
    id: 'registration',
    title: 'Registration and government verification',
    titleHindi: 'पंजीयन और सरकारी सत्यापन',
    summary: 'App sign-in and procurement eligibility are different checks.',
    summaryHindi: 'ऐप में लॉगिन और सरकारी खरीदी की पात्रता अलग जाँच हैं।',
    steps: [
      'Signing in with Google or a mobile OTP only gives access to your app account. It does not verify land records or eligibility to sell to government.',
      'Use your registered society or the official state service to check farmer registration, land and bank information for the current season.',
      'If details are wrong, ask the authorised office about correction and the documents needed. Keep an acknowledgement of your request.',
      'Krishi Queue does not issue a government certificate or confirm government tokens. Never treat a practice token as official.',
      'Season dates, quantity limits, prices and assistance can change. Confirm the current order with your society before making a decision.',
    ],
    stepsHindi: [
      'Google या मोबाइल OTP से लॉगिन केवल ऐप खाते में प्रवेश देता है। इससे जमीन के रिकॉर्ड या सरकारी खरीदी की पात्रता प्रमाणित नहीं होती।',
      'मौजूदा मौसम के लिए किसान पंजीयन, जमीन और बैंक जानकारी अपनी पंजीकृत समिति या राज्य की सरकारी सेवा से जाँचें।',
      'जानकारी गलत हो तो अधिकृत कार्यालय से सुधार और ज़रूरी कागज़ पूछें। आवेदन की पावती रखें।',
      'Krishi Queue सरकारी प्रमाणपत्र जारी नहीं करता और सरकारी टोकन की पुष्टि नहीं करता। अभ्यास टोकन को सरकारी न मानें।',
      'तारीख, मात्रा सीमा, दर और सहायता बदल सकती हैं। निर्णय लेने से पहले समिति से मौजूदा आदेश की पुष्टि करें।',
    ],
  ),
  FarmerGuide(
    id: 'weak-network',
    title: 'Weak network or no personal smartphone',
    titleHindi: 'कमज़ोर नेटवर्क या अपना स्मार्टफोन नहीं है',
    summary: 'Prepare offline and use a trusted helper without giving away your account.',
    summaryHindi:
        'बिना इंटरनेट तैयारी करें और खाते की सुरक्षा रखते हुए मदद लें।',
    steps: [
      'The help guide is stored inside this app. A saved visit plan can be read offline on this device; it is not a submitted booking.',
      'Keep low-data mode on. Load prices or news only when needed and check the date on saved information.',
      'Before travelling, confirm the centre by a voice call or at your society. A phone call needs mobile signal but does not need mobile internet.',
      'Ask a trusted family member or authorised centre helper for assistance. Enter any OTP yourself and ask for a paper acknowledgement.',
      'On a shared phone, sign out after use and clear your saved plan if you do not want the next person to see it. Clearing the app does not cancel an official token.',
    ],
    stepsHindi: [
      'यह मदद गाइड ऐप में ही है। सहेजी यात्रा योजना इस फोन पर बिना इंटरनेट पढ़ सकते हैं; यह जमा की गई बुकिंग नहीं है।',
      'कम डेटा मोड चालू रखें। ज़रूरत पर ही भाव या समाचार लोड करें और सहेजी जानकारी की तारीख देखें।',
      'निकलने से पहले फोन करके या समिति जाकर केंद्र की पुष्टि करें। फोन कॉल के लिए मोबाइल सिग्नल चाहिए, मोबाइल इंटरनेट नहीं।',
      'विश्वसनीय परिवारजन या अधिकृत केंद्र सहायक की मदद लें। OTP खुद डालें और कागज़ी पावती माँगें।',
      'साझा फोन पर काम के बाद लॉगआउट करें। अगला व्यक्ति योजना न देखे तो उसे हटाएँ। ऐप की जानकारी हटाने से सरकारी टोकन रद्द नहीं होता।',
    ],
  ),
  FarmerGuide(
    id: 'complaint',
    title: 'Raise a problem with the centre',
    titleHindi: 'केंद्र से जुड़ी शिकायत कैसे करें',
    summary: 'A clear written record makes follow-up easier.',
    summaryHindi: 'साफ लिखित जानकारी से शिकायत पर पूछताछ आसान होती है।',
    steps: [
      'Write the centre or society name, date, what happened and what correction you need. Keep the relevant token, weighment or purchase receipt.',
      'First ask the centre in-charge or society for a written acknowledgement and the expected response date.',
      'For a Food Department matter in Chhattisgarh, use its official helpline or grievance page. The helpline can direct you to the responsible office.',
      'Save the reference given by the official service. An app note or draft is not a filed complaint.',
      'Do not send OTPs, passwords, full bank details or identity documents to unknown callers. No one needs your UPI PIN to send you money.',
    ],
    stepsHindi: [
      'केंद्र या समिति का नाम, तारीख, क्या हुआ और कौन सा सुधार चाहिए, लिखें। संबंधित टोकन, तौल या खरीदी रसीद रखें।',
      'पहले केंद्र प्रभारी या समिति से लिखित पावती और जवाब की संभावित तारीख लें।',
      'छत्तीसगढ़ खाद्य विभाग के मामले में उसकी सरकारी हेल्पलाइन या शिकायत पृष्ठ का उपयोग करें। हेल्पलाइन संबंधित कार्यालय बता सकती है।',
      'सरकारी सेवा से मिला शिकायत नंबर सुरक्षित रखें। ऐप में लिखा नोट या मसौदा दर्ज शिकायत नहीं है।',
      'अनजान कॉल करने वाले को OTP, पासवर्ड, पूरा बैंक विवरण या पहचान पत्र न भेजें। पैसा भेजने के लिए किसी को आपका UPI PIN नहीं चाहिए।',
    ],
  ),
  FarmerGuide(
    id: 'crop-help',
    title: 'Crop, weather and scheme advice',
    titleHindi: 'फसल, मौसम और योजना की सलाह',
    summary: 'Speak to an agricultural adviser for advice suited to your crop and village.',
    summaryHindi: 'अपनी फसल और गाँव के अनुसार कृषि सलाहकार से सलाह लें।',
    steps: [
      'For crop symptoms, note your crop, village, sowing date and what has changed. Speak to the Kisan Call Centre or your local agricultural adviser.',
      'Ask a qualified adviser before choosing a pesticide, mixture or dose. An app chat cannot reliably diagnose a crop from a short description.',
      'Check the official weather forecast and warnings before spraying, drying grain or arranging transport.',
      'For a scheme, verify eligibility, documents, deadlines and fees with the official portal or office. Never pay a stranger for a guaranteed subsidy.',
      'Keep application acknowledgements and input purchase receipts. They can be useful when asking for support.',
    ],
    stepsHindi: [
      'फसल में समस्या हो तो फसल, गाँव, बुवाई की तारीख और बदलाव लिखें। किसान कॉल सेंटर या स्थानीय कृषि सलाहकार से बात करें।',
      'दवा, मिश्रण या मात्रा चुनने से पहले योग्य सलाहकार से पूछें। थोड़ी जानकारी वाली चैट से फसल का पक्का निदान नहीं हो सकता।',
      'छिड़काव, अनाज सुखाने या गाड़ी तय करने से पहले सरकारी मौसम पूर्वानुमान और चेतावनी देखें।',
      'योजना के लिए पात्रता, कागज़, अंतिम तारीख और शुल्क सरकारी पोर्टल या कार्यालय से जाँचें। पक्की सब्सिडी के नाम पर अनजान व्यक्ति को पैसा न दें।',
      'आवेदन की पावती और कृषि सामग्री की खरीदी रसीद रखें। सहायता माँगने में काम आ सकती हैं।',
    ],
  ),
];

// Official sources checked 31 October 2026. No network is needed to read these
// numbers; opening their source pages does require a connection.
const kisanCallCentreNumber = '18001801551';
const kisanCallCentreSource = 'https://dackkms.gov.in/account/aboutus.aspx';
const foodDepartmentNumber = '18002333663';
const foodComplaintSource =
    'https://fcs.cg.gov.in/citizen/Complain_Registered_New.aspx';
const officialTokenUrl =
    'https://play.google.com/store/apps/details?id=com.nic.kisaan';
const officialFoodUrl = 'https://fcs.cg.gov.in/';
const officialWeatherUrl = 'https://mausam.imd.gov.in/';
const officialAgricultureUrl = 'https://agriwelfare.gov.in/';
