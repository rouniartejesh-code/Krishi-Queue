/// Reviewed, bundled answers: this helper never invents live procurement data.
class OfflineAssistant {
  static String answer(String question, {required bool hindi}) {
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);
    String text(String en, String hi) => hindi ? hi : en;
    if (has(['otp', 'fraud', 'scam', 'pin', 'ठगी', 'धोख', 'ओटीपी'])) {
      return text(
        'Never share an OTP, UPI PIN, bank password or Aadhaar copy in chat. Receiving a payment does not require a UPI PIN. Use only the official department or bank contact. If money has been taken, contact your bank immediately and use the government cybercrime portal: cybercrime.gov.in.',
        'चैट में OTP, UPI PIN, बैंक पासवर्ड या आधार की कॉपी न भेजें। पैसे पाने के लिए UPI PIN नहीं लगता। विभाग या बैंक के आधिकारिक संपर्क से ही मदद लें। पैसे कटे हों तो तुरंत बैंक से संपर्क करें और सरकारी साइबर अपराध पोर्टल cybercrime.gov.in पर शिकायत करें।',
      );
    }
    if (has([
      'pesticid',
      'dose',
      'disease',
      'spray',
      'बीमार',
      'कीटनाशक',
      'दवा',
      'कीड़ा',
    ])) {
      return text(
        'A crop problem needs a local assessment. Note the crop, age, symptoms and how much area is affected, then contact your Krishi Vigyan Kendra or agriculture officer. Do not mix chemicals or choose a dose from chat. Follow the approved product label and expert guidance.',
        'फसल की समस्या के लिए स्थानीय जाँच जरूरी है। फसल, उम्र, लक्षण और प्रभावित क्षेत्र लिख लें। अपने कृषि विज्ञान केंद्र या कृषि अधिकारी से सलाह लें। चैट के आधार पर दवा की मात्रा तय न करें और रसायन न मिलाएँ। अधिकृत लेबल और विशेषज्ञ की सलाह मानें।',
      );
    }
    if (has([
      'payment',
      'bank',
      'paid',
      'money',
      'भुगतान',
      'पैसा',
      'पैसे',
      'बैंक',
    ])) {
      return text(
        'Keep the official weighing slip, purchase receipt and payment reference. Ask the procurement society which stage is pending; check your bank statement separately. This app cannot confirm a government transfer. A bill or “transfer started” message is not proof that money reached your bank. Never pay an agent to release your payment.',
        'आधिकारिक तौल पर्ची, खरीदी रसीद और भुगतान संदर्भ संभालें। समिति से पूछें कि भुगतान किस चरण में रुका है और बैंक विवरण अलग से जाँचें। यह ऐप सरकारी भुगतान की पुष्टि नहीं कर सकता। बिल बनना या ट्रांसफर शुरू होना, खाते में पैसा आने का प्रमाण नहीं है। भुगतान दिलाने के लिए किसी एजेंट को पैसे न दें।',
      );
    }
    if (has(['token', 'queue', 'eta', 'टोकन', 'कतार', 'बारी'])) {
      return text(
        'Only the authorised procurement system or your society can confirm your token and turn. Practice tokens and waiting times in this app are examples. Before hiring transport, confirm your date, centre, quantity and whether the centre is accepting arrivals. Keep a paper or downloaded copy of the official token.',
        'आपका टोकन और बारी केवल अधिकृत खरीदी व्यवस्था या समिति पुष्टि कर सकती है। इस ऐप के अभ्यास टोकन और प्रतीक्षा समय उदाहरण हैं। गाड़ी तय करने से पहले तारीख, केंद्र, मात्रा और केंद्र पर खरीदी चालू होने की पुष्टि करें। आधिकारिक टोकन की कागज़ी या डाउनलोड की हुई कॉपी रखें।',
      );
    }
    if (has([
      'price',
      'market',
      'mandi',
      'msp',
      'rate',
      'भाव',
      'मंडी',
      'कीमत',
      'दाम',
    ])) {
      return text(
        'Open Market prices for dated Chhattisgarh mandi reports. Check the market, crop, grade and observation date. A mandi modal price is a reported trading price, not a guaranteed procurement rate. Old saved reports may differ from today. Confirm the current season’s rate and eligibility with your society before selling.',
        'तारीख सहित छत्तीसगढ़ मंडी भाव के लिए “मंडी भाव” खोलें। मंडी, फसल, ग्रेड और रिपोर्ट की तारीख देखें। मंडी का प्रचलित भाव सरकारी खरीदी दर या गारंटी नहीं है। पुरानी सहेजी रिपोर्ट आज से अलग हो सकती है। बेचने से पहले चालू सीजन की दर और पात्रता समिति से पुष्टि करें।',
      );
    }
    if (has([
      'complaint',
      'grievance',
      'reject',
      'quality',
      'weigh',
      'शिकायत',
      'तौल',
      'गुणवत्ता',
      'नमी',
    ])) {
      return text(
        'Ask for a written reason and a dated receipt for a rejection, weight difference or payment delay. Keep the token, receipts and the officer’s name; request a complaint reference from the authorised society or district food office. This chat does not file complaints. Do not leave original documents with an unauthorised agent.',
        'अस्वीकृति, वजन में अंतर या भुगतान में देरी का लिखित कारण और तारीख वाली रसीद माँगें। टोकन, रसीदें और अधिकारी का नाम रखें। अधिकृत समिति या जिला खाद्य कार्यालय से शिकायत क्रमांक लें। यह चैट शिकायत दर्ज नहीं करती। अनधिकृत एजेंट के पास मूल दस्तावेज न छोड़ें।',
      );
    }
    if (has([
      'scheme',
      'kisan',
      'insurance',
      'योजना',
      'बीमा',
      'किसान सम्मान',
    ])) {
      return text(
        'Use official sources for eligibility and application status: pmkisan.gov.in (PM-KISAN), pmfby.gov.in (crop insurance), and khadya.cg.nic.in (Chhattisgarh food/procurement information). Rules and dates change by season. Ask your CSC or agriculture office to help and keep the application receipt. This app cannot approve benefits.',
        'पात्रता और आवेदन की स्थिति आधिकारिक स्रोत से देखें: pmkisan.gov.in (पीएम-किसान), pmfby.gov.in (फसल बीमा), khadya.cg.nic.in (छत्तीसगढ़ खाद्य/खरीदी जानकारी)। नियम और तारीखें सीजन के साथ बदलते हैं। CSC या कृषि कार्यालय से मदद लें और आवेदन की रसीद रखें। यह ऐप लाभ मंजूर नहीं कर सकता।',
      );
    }
    if (has(['offline', 'internet', 'network', '2g', 'नेट', 'ऑफलाइन'])) {
      return text(
        'This basic helper and saved visit plans work without internet after the app is installed. Save your checklist before travelling. Online prices, news, sign-in and BHASHINI need a connection. A saved plan is not a reserved slot. Ask your society or CSC for an official token if you cannot connect.',
        'ऐप इंस्टॉल होने के बाद यह सामान्य मदद और सहेजी यात्रा योजना बिना इंटरनेट चलती है। निकलने से पहले तैयारी सूची सहेज लें। नए भाव, समाचार, साइन-इन और BHASHINI के लिए इंटरनेट चाहिए। सहेजी योजना आरक्षित स्लॉट नहीं है। इंटरनेट न चले तो समिति या CSC से आधिकारिक टोकन में मदद लें।',
      );
    }
    if (has([
      'book',
      'slot',
      'prepare',
      'document',
      'visit',
      'cancel',
      'तैयार',
      'दस्तावेज',
      'बुक',
      'स्लॉट',
      'रद्द',
    ])) {
      return text(
        'Prepare your visit: confirm registration and land/crop details with your society; get an official date/token; check the required documents, grain condition and bags; confirm the centre is open before transport. Use the visit planner to save a checklist on this phone. For a change or cancellation, contact the official token system or society.',
        'यात्रा की तैयारी: समिति से पंजीकरण और जमीन/फसल विवरण की पुष्टि करें; आधिकारिक तारीख/टोकन लें; जरूरी दस्तावेज, अनाज की स्थिति और बोरे जाँचें; गाड़ी भेजने से पहले केंद्र खुला होने की पुष्टि करें। इस फोन पर सूची रखने के लिए यात्रा योजना बनाएँ। तारीख बदलने या रद्द करने के लिए आधिकारिक टोकन व्यवस्था या समिति से संपर्क करें।',
      );
    }
    return text(
      'I can help offline with visit preparation, official tokens, payment delays, mandi prices, schemes, crop-advice contacts and safe app use. Tell me what you need. I do not book slots, verify government eligibility or diagnose crop diseases.',
      'मैं यात्रा की तैयारी, आधिकारिक टोकन, भुगतान में देरी, मंडी भाव, योजनाओं, कृषि सलाह के संपर्क और सुरक्षित ऐप उपयोग में ऑफलाइन मदद कर सकता हूँ। अपनी जरूरत लिखें। मैं स्लॉट बुक नहीं करता, सरकारी पात्रता सत्यापित नहीं करता और फसल रोग का निदान नहीं करता।',
    );
  }
}
