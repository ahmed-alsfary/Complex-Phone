enum AppLang { ar, en, ku }

extension AppLangX on AppLang {
  String get code => switch (this) {
        AppLang.ar => 'ar',
        AppLang.en => 'en',
        AppLang.ku => 'ku',
      };

  String get label => switch (this) {
        AppLang.ar => 'العربية',
        AppLang.en => 'English',
        AppLang.ku => 'کوردی',
      };

  bool get isRtl => this != AppLang.en;

  static AppLang fromCode(String? code) {
    switch ((code ?? 'ar').toLowerCase()) {
      case 'en':
        return AppLang.en;
      case 'ku':
      case 'ckb':
        return AppLang.ku;
      default:
        return AppLang.ar;
    }
  }
}

class S {
  S(this.lang);

  final AppLang lang;

  String get(String key) {
    final map = _tables[lang] ?? _tables[AppLang.ar]!;
    return map[key] ?? _tables[AppLang.ar]![key] ?? key;
  }

  String get appTitle => get('appTitle');
  String get residentServices => get('residentServices');
  String get overview => get('overview');
  String get home => get('home');
  String get myUnit => get('myUnit');
  String get installments => get('installments');
  String get contracts => get('contracts');
  String get profile => get('profile');
  String get notifications => get('notifications');
  String get noNotifications => get('noNotifications');
  String get language => get('language');
  String get theme => get('theme');
  String get lightMode => get('lightMode');
  String get darkMode => get('darkMode');
  String get servicesBills => get('servicesBills');
  String get servicesBillsHint => get('servicesBillsHint');
  String get readings => get('readings');
  String get bills => get('bills');
  String get previousReading => get('previousReading');
  String get currentReading => get('currentReading');
  String get consumption => get('consumption');
  String get amount => get('amount');
  String get paid => get('paid');
  String get unpaid => get('unpaid');
  String get visitorPass => get('visitorPass');
  String get visitorPassHint => get('visitorPassHint');
  String get ads => get('ads');
  String get noAds => get('noAds');
  String get noBills => get('noBills');
  String get refresh => get('refresh');
  String get vehicles => get('vehicles');
  String get addVehicle => get('addVehicle');
  String get editVehicle => get('editVehicle');
  String get noVehicles => get('noVehicles');
  String get plateNumber => get('plateNumber');
  String get vehicleType => get('vehicleType');
  String get manufacturer => get('manufacturer');
  String get manufactureYear => get('manufactureYear');
  String get color => get('color');
  String get notes => get('notes');
  String get save => get('save');
  String get family => get('family');
  String get householdCounts => get('householdCounts');
  String get maleCount => get('maleCount');
  String get femaleCount => get('femaleCount');
  String get updateInfo => get('updateInfo');
  String get familyMembers => get('familyMembers');
  String get addFamilyMember => get('addFamilyMember');
  String get editFamilyMember => get('editFamilyMember');
  String get noFamilyMembers => get('noFamilyMembers');
  String get fullName => get('fullName');
  String get relation => get('relation');
  String get nationalId => get('nationalId');
  String get birthDate => get('birthDate');

  static const _tables = <AppLang, Map<String, String>>{
    AppLang.ar: {
      'appTitle': 'مجمع الزهراء',
      'residentServices': 'خدمات الساكن',
      'overview': 'نظرة سريعة',
      'home': 'الرئيسية',
      'myUnit': 'وحدتي',
      'installments': 'الأقساط',
      'contracts': 'العقود',
      'profile': 'حسابي',
      'notifications': 'الإشعارات',
      'noNotifications': 'لا توجد إشعارات حالياً',
      'language': 'اللغة',
      'theme': 'المظهر',
      'lightMode': 'نهاري',
      'darkMode': 'ليلي',
      'servicesBills': 'الكهرباء والخدمات',
      'servicesBillsHint': 'الفواتير والقراءات',
      'readings': 'القراءات',
      'bills': 'الفواتير',
      'previousReading': 'قراءة سابقة',
      'currentReading': 'قراءة حالية',
      'consumption': 'الاستهلاك',
      'amount': 'المبلغ',
      'paid': 'مدفوعة',
      'unpaid': 'غير مدفوعة',
      'visitorPass': 'تصريح الزائر الذكي',
      'visitorPassHint': 'أنشئ رمز QR لضيفك عند البوابة',
      'ads': 'الإعلانات',
      'noAds': 'لا توجد إعلانات',
      'noBills': 'لا توجد فواتير خدمات',
      'refresh': 'تحديث',
      'vehicles': 'مركباتي',
      'addVehicle': 'إضافة مركبة',
      'editVehicle': 'تعديل مركبة',
      'noVehicles': 'لا توجد مركبات مسجّلة',
      'plateNumber': 'رقم اللوحة',
      'vehicleType': 'نوع المركبة',
      'manufacturer': 'الشركة المصنعة',
      'manufactureYear': 'سنة الصنع',
      'color': 'اللون',
      'notes': 'ملاحظات',
      'save': 'حفظ',
      'family': 'أفراد الأسرة والتابعين',
      'householdCounts': 'أعداد الساكنين',
      'maleCount': 'عدد الذكور',
      'femaleCount': 'عدد الإناث',
      'updateInfo': 'تحديث المعلومات',
      'familyMembers': 'أفراد الأسرة',
      'addFamilyMember': 'إضافة فرد',
      'editFamilyMember': 'تعديل فرد',
      'noFamilyMembers': 'لا يوجد أفراد مسجّلون',
      'fullName': 'الاسم الكامل',
      'relation': 'صلة القرابة',
      'nationalId': 'رقم الهوية',
      'birthDate': 'تاريخ الميلاد',
    },
    AppLang.en: {
      'appTitle': 'Al Zahraa Complex',
      'residentServices': 'Resident services',
      'overview': 'Overview',
      'home': 'Home',
      'myUnit': 'My unit',
      'installments': 'Installments',
      'contracts': 'Contracts',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'noNotifications': 'No notifications yet',
      'language': 'Language',
      'theme': 'Theme',
      'lightMode': 'Light',
      'darkMode': 'Dark',
      'servicesBills': 'Utilities & services',
      'servicesBillsHint': 'Bills and meter readings',
      'readings': 'Readings',
      'bills': 'Bills',
      'previousReading': 'Previous',
      'currentReading': 'Current',
      'consumption': 'Consumption',
      'amount': 'Amount',
      'paid': 'Paid',
      'unpaid': 'Unpaid',
      'visitorPass': 'Smart visitor pass',
      'visitorPassHint': 'Create a QR for your guest at the gate',
      'ads': 'Announcements',
      'noAds': 'No announcements',
      'noBills': 'No utility bills yet',
      'refresh': 'Refresh',
      'vehicles': 'My vehicles',
      'addVehicle': 'Add vehicle',
      'editVehicle': 'Edit vehicle',
      'noVehicles': 'No vehicles yet',
      'plateNumber': 'Plate number',
      'vehicleType': 'Vehicle type',
      'manufacturer': 'Manufacturer',
      'manufactureYear': 'Year',
      'color': 'Color',
      'notes': 'Notes',
      'save': 'Save',
      'family': 'Family & dependents',
      'householdCounts': 'Household counts',
      'maleCount': 'Males',
      'femaleCount': 'Females',
      'updateInfo': 'Update info',
      'familyMembers': 'Family members',
      'addFamilyMember': 'Add member',
      'editFamilyMember': 'Edit member',
      'noFamilyMembers': 'No family members yet',
      'fullName': 'Full name',
      'relation': 'Relation',
      'nationalId': 'ID number',
      'birthDate': 'Birth date',
    },
    AppLang.ku: {
      'appTitle': 'کۆمەڵگەی زەهرا',
      'residentServices': 'خزمەتگوزارییەکانی دانیشتوو',
      'overview': 'تێڕوانینی خێرا',
      'home': 'سەرەکی',
      'myUnit': 'یەکەکەم',
      'installments': 'قیستەکان',
      'contracts': 'گرێبەستەکان',
      'profile': 'هەژمار',
      'notifications': 'ئاگادارکردنەوەکان',
      'noNotifications': 'هیچ ئاگادارکردنەوەیەک نییە',
      'language': 'زمان',
      'theme': 'ڕووکار',
      'lightMode': 'ڕۆژ',
      'darkMode': 'شەو',
      'servicesBills': 'کارەبا و خزمەتگوزارییەکان',
      'servicesBillsHint': 'پسوولە و خوێندنەوەکان',
      'readings': 'خوێندنەوەکان',
      'bills': 'پسوولەکان',
      'previousReading': 'خوێندنەوەی پێشوو',
      'currentReading': 'خوێندنەوەی ئێستا',
      'consumption': 'بەکارهێنان',
      'amount': 'بڕ',
      'paid': 'دراوە',
      'unpaid': 'نەدراوە',
      'visitorPass': 'مۆڵەتی سەردانیکەری زیرا',
      'visitorPassHint': 'QR بۆ میوانەکەت دروست بکە',
      'ads': 'ڕێکلامەکان',
      'noAds': 'هیچ ڕێکلامێک نییە',
      'noBills': 'هیچ پسوولەیەکی خزمەتگوزاری نییە',
      'refresh': 'نوێکردنەوە',
      'vehicles': 'ئۆتۆمبێلەکانم',
      'addVehicle': 'زیادکردنی ئۆتۆمبێل',
      'editVehicle': 'دەستکاری ئۆتۆمبێل',
      'noVehicles': 'هیچ ئۆتۆمبێلێک تۆمار نەکراوە',
      'plateNumber': 'ژمارەی تابلۆ',
      'vehicleType': 'جۆری ئۆتۆمبێل',
      'manufacturer': 'کۆمپانیای بەرهەمهێنەر',
      'manufactureYear': 'ساڵی دروستکردن',
      'color': 'ڕەنگ',
      'notes': 'تێبینی',
      'save': 'پاشەکەوت',
      'family': 'ئەندامانی خێزان و پەیوەستەکان',
      'householdCounts': 'ژمارەی دانیشتووان',
      'maleCount': 'ژمارەی نێر',
      'femaleCount': 'ژمارەی مێ',
      'updateInfo': 'نوێکردنەوەی زانیاری',
      'familyMembers': 'ئەندامانی خێزان',
      'addFamilyMember': 'زیادکردنی ئەندام',
      'editFamilyMember': 'دەستکاری ئەندام',
      'noFamilyMembers': 'هیچ ئەندامێک تۆمار نەکراوە',
      'fullName': 'ناوی تەواو',
      'relation': 'پەیوەندی خێزانی',
      'nationalId': 'ژمارەی ناسنامە',
      'birthDate': 'بەرواری لەدایکبوون',
    },
  };
}
