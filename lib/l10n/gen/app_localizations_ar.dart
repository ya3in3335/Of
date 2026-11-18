// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'OUTIFOR';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get splashLoading => 'جارٍ تأمين الجلسة…';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get demoRibbon => 'تجريبي';

  @override
  String get demoLoginTitle => 'نسخة تجريبية — بيانات وهمية';

  @override
  String get demoLoginBody =>
      'لا يُرسل أي شيء إلى خادم، وتُعاد البيانات عند إعادة تشغيل التطبيق. المس حسابًا لملئه:';

  @override
  String get demoAdmin => 'المسؤول';

  @override
  String get demoEmployee => 'موظف التوصيل';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navCustomers => 'الزبائن';

  @override
  String get navEmployees => 'الموظفون';

  @override
  String get navMap => 'الخريطة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navSearch => 'البحث';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get offlineBanner => 'غير متصل — عرض النسخة المحفوظة على هذا الهاتف';

  @override
  String get actionActivate => 'تفعيل';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionApply => 'تطبيق';

  @override
  String get actionArchive => 'أرشفة';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionCall => 'اتصال';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionChange => 'تغيير';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionCopyAll => 'نسخ الكل';

  @override
  String get actionCopyPhone => 'نسخ الرقم';

  @override
  String get actionCopyReference => 'نسخ المرجع';

  @override
  String get actionCreateAccount => 'إنشاء الحساب';

  @override
  String get actionCreateCustomer => 'إنشاء الزبون';

  @override
  String get actionDeactivate => 'تعطيل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDiscard => 'تجاهل';

  @override
  String get actionDone => 'تم';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionGenerate => 'توليد';

  @override
  String get actionHidePassword => 'إخفاء كلمة المرور';

  @override
  String get actionShowPassword => 'إظهار كلمة المرور';

  @override
  String get actionNavigate => 'الطريق';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionOk => 'حسنًا';

  @override
  String get actionOpenInMaps => 'فتح في الخرائط';

  @override
  String get actionOpenSettings => 'الإعدادات';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get actionReset => 'إعادة تعيين';

  @override
  String get actionRestore => 'استعادة';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionSaveChanges => 'حفظ التغييرات';

  @override
  String get actionSearchAddressInMaps => 'البحث عن العنوان في خرائط Google';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionSetLocation => 'تحديد الموقع على الخريطة';

  @override
  String get actionSignOut => 'تسجيل الخروج';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionStartNavigation => 'بدء الملاحة';

  @override
  String get actionViewProfile => 'عرض الملف';

  @override
  String get actionWhatsapp => 'واتساب';

  @override
  String get onboarding1Title => 'من الفاتورة إلى الزبون في ثوانٍ';

  @override
  String get onboarding1Body =>
      'اكتب الاسم المطبوع على الفاتورة. يعمل البحث بجزء من الاسم أو بالمرجع أو برقم الهاتف.';

  @override
  String get onboarding2Title => 'مواقع تسليم دقيقة';

  @override
  String get onboarding2Body =>
      'شاهد كل محل على الخريطة وابدأ الملاحة عبر خرائط Google بلمسة واحدة.';

  @override
  String get onboarding3Title => 'آمن ومحدَّث دائمًا';

  @override
  String get onboarding3Body =>
      'يُنشئ المدير الحسابات، وتصل التعديلات إلى كل الهواتف تلقائيًا.';

  @override
  String get onboardingStart => 'ابدأ';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول إلى دليل زبائن OUTIFOR';

  @override
  String get loginUsername => 'اسم المستخدم';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginNoSignup => 'يتم إنشاء الحسابات من طرف المسؤول.';

  @override
  String get errorOffline =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.';

  @override
  String get errorOfflineSave =>
      'أنت غير متصل. لم يتم حفظ أي شيء — أعد المحاولة عند عودة الاتصال.';

  @override
  String get errorTimeout => 'استغرق الخادم وقتًا طويلًا للرد. أعد المحاولة.';

  @override
  String get errorInvalidCredentials =>
      'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get errorAccountDisabled => 'هذا الحساب معطّل. اتصل بالمسؤول.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجددًا.';

  @override
  String get errorForbidden => 'ليست لديك صلاحية لهذا الإجراء.';

  @override
  String get errorNotFound => 'هذا العنصر لم يعد موجودًا.';

  @override
  String get errorConflict =>
      'قام شخص آخر بتعديل هذا السجل. أعد التحميل وحاول مجددًا.';

  @override
  String get errorUsernameTaken => 'اسم المستخدم هذا مستعمل بالفعل.';

  @override
  String get errorWeakPassword =>
      'كلمة المرور ضعيفة: 8 أحرف على الأقل تتضمن حروفًا وأرقامًا.';

  @override
  String get errorValidation => 'بعض المعلومات غير صالحة. تحقق من الاستمارة.';

  @override
  String get errorNotConfigured => 'الخادم غير مهيأ بالكامل. اتصل بالمسؤول.';

  @override
  String get errorGeneric => 'حدث خطأ ما. أعد المحاولة.';

  @override
  String get errorCannotOpenApp =>
      'لا يوجد تطبيق على هذا الهاتف يمكنه فتح هذا.';

  @override
  String get stateOfflineTitle => 'أنت غير متصل';

  @override
  String get stateErrorTitle => 'تعذّر التحميل';

  @override
  String get validationRequired => 'مطلوب';

  @override
  String get validationTooShort => 'قصير جدًا';

  @override
  String get validationTooLong => 'طويل جدًا';

  @override
  String get validationPhone => 'رقم غير صالح (مثال: 0555 12 34 56)';

  @override
  String get validationUsername =>
      'من 3 إلى 32 حرفًا: حروف لاتينية صغيرة وأرقام و . _ -';

  @override
  String get validationPassword => '8 أحرف على الأقل، تتضمن حروفًا وأرقامًا';

  @override
  String get validationMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationNumber => 'قيمة غير صالحة';

  @override
  String get validationSamePassword => 'اختر كلمة مرور مختلفة';

  @override
  String get formFixErrors => 'يرجى تصحيح الحقول المشار إليها.';

  @override
  String get syncSyncing => 'جارٍ المزامنة…';

  @override
  String syncDone(String time) {
    return 'تمت المزامنة $time';
  }

  @override
  String syncOffline(String time) {
    return 'غير متصل · بيانات $time';
  }

  @override
  String get syncOfflineNoData => 'غير متصل · لم تتم المزامنة بعد';

  @override
  String get syncError => 'فشلت المزامنة · المس لإعادة المحاولة';

  @override
  String get syncNever => 'لم تتم المزامنة بعد';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncCompleted => 'الدليل محدَّث';

  @override
  String get syncFailed => 'فشلت المزامنة. أعد المحاولة لاحقًا.';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String timeHoursAgo(int count) {
    return 'منذ $count سا';
  }

  @override
  String get timeYesterday => 'أمس';

  @override
  String timeDaysAgo(int count) {
    return 'منذ $count أيام';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters م';
  }

  @override
  String distanceKm(String km) {
    return '$km كم';
  }

  @override
  String homeGreeting(String name) {
    return 'مرحبًا $name';
  }

  @override
  String get homeTitle => 'ابحث عن زبون';

  @override
  String get homeCustomersAvailable => 'زبون في الدليل';

  @override
  String get homeWithLocation => 'بموقع GPS';

  @override
  String get searchTitle => 'البحث عن زبون';

  @override
  String get searchHint => 'الاسم في الفاتورة أو الهاتف أو المرجع OUT';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count زبون',
      few: 'تم العثور على $count زبائن',
      two: 'تم العثور على زبونين',
      one: 'تم العثور على زبون واحد',
    );
    return '$_temp0';
  }

  @override
  String get searchMultipleHint =>
      'عدة زبائن مطابقون. تحقق من رقم الهاتف والمدينة قبل الفتح.';

  @override
  String get searchNoResultsTitle => 'لم يتم العثور على أي زبون';

  @override
  String get searchNoResultsBody =>
      'تحقق من الكتابة، أو جرّب اللقب فقط، أو ابحث برقم الهاتف.';

  @override
  String get searchOfflineNote =>
      'أنت غير متصل: الزبائن المضافون منذ آخر مزامنة غير موجودين بعد على هذا الهاتف.';

  @override
  String get searchRecent => 'المفتوحة مؤخرًا';

  @override
  String get searchTipsTitle => 'يمكنك البحث بـ';

  @override
  String get searchTipName => 'الاسم (الاسم أو اللقب أو جزء منه)';

  @override
  String get searchTipReference => 'مرجع الزبون';

  @override
  String get searchTipPhone => 'رقم الهاتف';

  @override
  String directoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زبون',
      few: '$count زبائن',
      two: 'زبونان',
      one: 'زبون واحد',
      zero: 'لا يوجد زبائن',
    );
    return '$_temp0';
  }

  @override
  String get directoryFilterHint => 'تصفية بالاسم أو الهاتف أو المرجع…';

  @override
  String get directoryEmptyTitle => 'لا يوجد زبائن بعد';

  @override
  String get directoryEmptyAdmin => 'أضف أول زبون لبدء بناء الدليل.';

  @override
  String get directoryEmptyEmployee =>
      'سيظهر هنا الزبائن الذين يضيفهم المسؤول.';

  @override
  String get directoryNoMatchTitle => 'لا توجد نتائج';

  @override
  String get directoryNoMatchBody => 'لا يوجد زبون يطابق هذه المرشحات.';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterAllWilayas => 'كل الولايات';

  @override
  String get filterNoLocation => 'بدون موقع GPS';

  @override
  String get filterReset => 'إعادة ضبط المرشحات';

  @override
  String get filterWilaya => 'الولاية';

  @override
  String get sortTitle => 'ترتيب';

  @override
  String get sortName => 'الاسم أ–ي';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortUpdated => 'المعدّلة مؤخرًا';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusArchived => 'مؤرشف';

  @override
  String get statusArchivedPlural => 'المؤرشفون';

  @override
  String get statusInactive => 'معطّل';

  @override
  String get customerProfileTitle => 'بطاقة الزبون';

  @override
  String get customerNew => 'زبون جديد';

  @override
  String get customerEditTitle => 'تعديل الزبون';

  @override
  String get customerLocation => 'الموقع';

  @override
  String get customerContact => 'الاتصال';

  @override
  String get customerOtherAddresses => 'عناوين تسليم أخرى';

  @override
  String get customerRecord => 'السجل';

  @override
  String get customerNoWhatsapp => 'لا يوجد رقم واتساب مسجل.';

  @override
  String get customerNoLocationTitle => 'لم يُسجَّل موقع GPS';

  @override
  String get customerNoLocationShort => 'بدون موقع GPS';

  @override
  String get customerNoLocationAdmin =>
      'حدد موقع هذا الزبون على الخريطة ليتمكن السائقون من الوصول إليه.';

  @override
  String get customerNoLocationEmployee =>
      'استعمل العنوان المكتوب أو اتصل بالزبون للإرشاد.';

  @override
  String get customerNotFoundTitle => 'الزبون غير موجود';

  @override
  String get customerNotFoundBody => 'ربما تم حذف هذا الزبون.';

  @override
  String get customerArchiveTitle => 'أرشفة هذا الزبون؟';

  @override
  String customerArchiveBody(String name) {
    return 'سيتم إخفاء $name من بحث الموظفين. يمكنك استعادته في أي وقت.';
  }

  @override
  String get customerRestoreTitle => 'استعادة هذا الزبون؟';

  @override
  String customerRestoreBody(String name) {
    return 'سيصبح $name مرئيًا للموظفين مجددًا.';
  }

  @override
  String get customerArchived => 'تمت أرشفة الزبون';

  @override
  String get customerRestored => 'تمت استعادة الزبون';

  @override
  String get customerDeleteTitle => 'حذف نهائي؟';

  @override
  String customerDeleteBody(String name, String reference) {
    return 'سيتم حذف $name ($reference) وعناوينه لدى الجميع. لا يمكن التراجع. يُفضَّل الأرشفة.';
  }

  @override
  String get customerDeleted => 'تم حذف الزبون';

  @override
  String customerCreated(String reference) {
    return 'تم إنشاء الزبون $reference';
  }

  @override
  String get customerUpdated => 'تم حفظ التغييرات';

  @override
  String get copiedPhone => 'تم نسخ الرقم';

  @override
  String get copiedReference => 'تم نسخ المرجع';

  @override
  String get copiedAddress => 'تم نسخ العنوان';

  @override
  String get copiedCredentials => 'تم نسخ بيانات الدخول';

  @override
  String get adminNotesEmpty => 'لا توجد ملاحظات.';

  @override
  String get adminNotesHint => 'مرئية للمسؤولين فقط.';

  @override
  String get adminNotesPlaceholder =>
      'عادات الدفع، أوقات العمل، تعليمات الوصول…';

  @override
  String get fieldFirstName => 'الاسم';

  @override
  String get fieldLastName => 'اللقب';

  @override
  String get fieldFullName => 'الاسم الكامل';

  @override
  String get fieldBusinessName => 'اسم المحل / المؤسسة';

  @override
  String get fieldPrimaryPhone => 'الهاتف الرئيسي';

  @override
  String get fieldSecondaryPhone => 'الهاتف الثانوي';

  @override
  String get fieldWhatsappPhone => 'رقم واتساب';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldWilaya => 'الولاية';

  @override
  String get fieldCommune => 'البلدية';

  @override
  String get fieldWilayaCommune => 'البلدية — الولاية';

  @override
  String get fieldAddress => 'العنوان المفصل';

  @override
  String get fieldAddressHint => 'الشارع، العمارة، معلم قريب…';

  @override
  String get fieldAdminNotes => 'ملاحظات المسؤول';

  @override
  String get fieldCreatedAt => 'تاريخ الإنشاء';

  @override
  String get fieldUpdatedAt => 'آخر تعديل';

  @override
  String get fieldLastLogin => 'آخر دخول';

  @override
  String get fieldLatitude => 'خط العرض';

  @override
  String get fieldLongitude => 'خط الطول';

  @override
  String get fieldLabel => 'التسمية';

  @override
  String get fieldLabelHint => 'مثال: المستودع، المحل الثاني';

  @override
  String get fieldCompanyName => 'اسم الشركة';

  @override
  String get fieldCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get fieldNewPassword => 'كلمة المرور الجديدة';

  @override
  String get fieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get formIdentity => 'الهوية';

  @override
  String get formAddress => 'العنوان';

  @override
  String get formWhatsappSame => 'واتساب على الرقم الرئيسي';

  @override
  String get formWhatsappHint =>
      'أدخل فقط رقمًا يستعمله الزبون فعلًا على واتساب.';

  @override
  String get formNoLocation =>
      'لا يوجد موقع بعد. بدونه لن يملك السائقون سوى العنوان المكتوب.';

  @override
  String get formNoExtraAddresses => 'لا يوجد عنوان آخر.';

  @override
  String get formStatusActive => 'زبون نشط';

  @override
  String get formStatusActiveHint => 'مرئي للموظفين.';

  @override
  String get formStatusArchivedHint => 'مؤرشف: مخفي عن الموظفين.';

  @override
  String get extraAddressTitle => 'عنوان التسليم';

  @override
  String get discardTitle => 'تجاهل التغييرات؟';

  @override
  String get discardBody => 'لم يتم حفظ تغييراتك.';

  @override
  String get conflictTitle => 'تم التعديل من جهة أخرى';

  @override
  String get conflictBody =>
      'قام مسؤول آخر بحفظ هذا الزبون أثناء تعديلك. تم تحميل آخر نسخة؛ يرجى إعادة تطبيق تغييراتك.';

  @override
  String get duplicateHintTitle => 'زبون مسجل مسبقًا على الأرجح';

  @override
  String get duplicatesFoundTitle => 'تكرارات محتملة';

  @override
  String get duplicatesFoundBody =>
      'لهؤلاء الزبائن نفس رقم الهاتف أو اسم مشابه جدًا. تحقق قبل إنشاء سجل جديد.';

  @override
  String get duplicatesReview => 'الرجوع والتحقق';

  @override
  String get duplicatesSaveAnyway => 'إنه زبون مختلف — حفظ';

  @override
  String get duplicateSamePhone => 'نفس الهاتف';

  @override
  String get duplicateSimilarName => 'اسم مشابه';

  @override
  String duplicateScore(int percent) {
    return 'تطابق $percent%';
  }

  @override
  String get duplicatesTitle => 'مراجعة التكرارات';

  @override
  String get duplicatesShort => 'التكرارات';

  @override
  String get duplicatesIntro =>
      'لا يتم دمج السجلات تلقائيًا أبدًا. افتح الاثنين ثم أرشف أو احذف الخاطئ، أو علّمهما كزبونين مختلفين.';

  @override
  String get duplicatesNoneTitle => 'لم يتم اكتشاف تكرارات';

  @override
  String get duplicatesNoneBody =>
      'لا يوجد زبائن يتشاركون رقم هاتف أو اسمًا شبه متطابق.';

  @override
  String get duplicatesDismiss => 'زبونان مختلفان';

  @override
  String get duplicatesDismissed => 'تم تعليم الزوج كزبونين مختلفين';

  @override
  String get mapOpenFull => 'خريطة كاملة';

  @override
  String get mapMyLocation => 'موقعي';

  @override
  String get mapRecenter => 'التمركز على الزبون';

  @override
  String get mapShowAll => 'عرض كل الزبائن';

  @override
  String mapDistanceAway(String distance) {
    return 'على بعد $distance (خط مستقيم)';
  }

  @override
  String mapLocatedCount(int count) {
    return '$count على الخريطة';
  }

  @override
  String mapMissingCount(int count) {
    return '$count بدون GPS';
  }

  @override
  String get mapEmptyTitle => 'لا يوجد زبون بموقع GPS بعد';

  @override
  String get mapEmptyAdmin => 'افتح زبونًا واستعمل «تحديد الموقع على الخريطة».';

  @override
  String get mapEmptyEmployee => 'ستظهر هنا المواقع التي يضيفها المسؤول.';

  @override
  String get locationServiceDisabled => 'خدمة الموقع متوقفة على هذا الهاتف.';

  @override
  String get locationDenied => 'تم رفض إذن الموقع.';

  @override
  String get locationDeniedForever =>
      'إذن الموقع محظور. فعّله من إعدادات التطبيق.';

  @override
  String get locationTimeout =>
      'تعذّر تحديد الموقع. انتقل إلى مكان مكشوف وأعد المحاولة.';

  @override
  String get pickerTitle => 'موقع الزبون';

  @override
  String get pickerSearchHint => 'ابحث عن عنوان أو مكان';

  @override
  String get pickerNoAddressFound =>
      'لم يتم العثور على عنوان. حرّك الخريطة يدويًا.';

  @override
  String get pickerSearchFailed =>
      'البحث غير متاح. تحقق من الاتصال أو حرّك الخريطة يدويًا.';

  @override
  String get pickerInstructions =>
      'حرّك الخريطة أو المس لوضع الدبوس على مدخل المحل.';

  @override
  String get pickerUseMyLocation => 'استخدام موقعي الحالي';

  @override
  String get pickerManualTitle => 'إدخال الإحداثيات';

  @override
  String get pickerManualHint => 'بالدرجات العشرية، مثال 36.753800 و 3.058800';

  @override
  String get pickerMoveFirst =>
      'ضع الدبوس أولًا: حرّك الخريطة أو المسها أو ابحث عن عنوان.';

  @override
  String get pickerConfirm => 'تأكيد هذا الموقع';

  @override
  String get pickerConfirmTitle => 'تحقق من الموقع';

  @override
  String get pickerConfirmBody => 'سيتم توجيه السائقين إلى هذه النقطة بالضبط.';

  @override
  String get pickerUseThisLocation => 'استخدام هذا الموقع';

  @override
  String get pickerAdjust => 'تعديل';

  @override
  String get dashboardQuickActions => 'إجراءات سريعة';

  @override
  String get dashboardDirectory => 'الدليل';

  @override
  String get dashboardRecentCustomers => 'المضافون مؤخرًا';

  @override
  String get dashboardRecentActivity => 'النشاط الأخير';

  @override
  String get statTotalCustomers => 'الزبائن';

  @override
  String get statActiveCustomers => 'النشطون';

  @override
  String get statEmployees => 'الموظفون';

  @override
  String get statAdded30Days => 'المضافون خلال 30 يومًا';

  @override
  String statAddedThisWeek(int count) {
    return '+$count هذا الأسبوع';
  }

  @override
  String statArchived(int count) {
    return '$count مؤرشف';
  }

  @override
  String statEmployeesActive(int count) {
    return '$count نشط';
  }

  @override
  String statMissingLocation(int count) {
    return '$count بدون GPS';
  }

  @override
  String get statAllLocated => 'كلهم بموقع';

  @override
  String get employeeNew => 'موظف جديد';

  @override
  String get employeesSearchHint => 'ابحث بالاسم أو اسم المستخدم';

  @override
  String get employeesEmptyTitle => 'لا توجد حسابات بعد';

  @override
  String get employeesEmptyBody => 'أنشئ حسابًا لكل موظف توصيل.';

  @override
  String get employeeNeverLoggedIn => 'لم يسجل الدخول أبدًا';

  @override
  String employeeLastLogin(String when) {
    return 'آخر دخول $when';
  }

  @override
  String get employeeIdentity => 'الهوية';

  @override
  String get employeeRole => 'الدور';

  @override
  String get employeeTempPassword => 'كلمة مرور مؤقتة';

  @override
  String get usernameHelper => 'يُستعمل لتسجيل الدخول. حروف صغيرة بدون مسافات.';

  @override
  String get passwordRules =>
      '8 أحرف على الأقل تتضمن حروفًا وأرقامًا. شاركها بشكل خاص؛ يمكن للموظف تغييرها من إعدادات الحساب.';

  @override
  String get roleAdmin => 'مسؤول';

  @override
  String get roleEmployee => 'موظف توصيل';

  @override
  String get roleAdminHint => 'صلاحية كاملة: الزبائن والموظفون والإعدادات.';

  @override
  String get roleEmployeeHint =>
      'البحث والاطلاع والاتصال والملاحة. لا يمكنه تعديل البيانات.';

  @override
  String get employeeAdminConfirmTitle => 'إنشاء مسؤول؟';

  @override
  String get employeeAdminConfirmBody =>
      'سيتمكن هذا الشخص من تعديل الزبائن وحذفهم وإدارة كل الحسابات.';

  @override
  String get employeeCreated => 'تم إنشاء الحساب';

  @override
  String get credentialsTitle => 'بيانات تسجيل الدخول';

  @override
  String get credentialsBody =>
      'سلّمها للموظف الآن. لن تظهر كلمة المرور مرة أخرى.';

  @override
  String get employeeDetailsTitle => 'الموظف';

  @override
  String get employeeAccount => 'الحساب';

  @override
  String get employeeManage => 'الإدارة';

  @override
  String get employeeEditTitle => 'تعديل الاسم والدور';

  @override
  String get employeeUpdated => 'تم تحديث الحساب';

  @override
  String get employeeResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get employeeResetHint => 'تعيين كلمة مرور مؤقتة جديدة.';

  @override
  String employeeResetBody(String name) {
    return 'كلمة مرور جديدة لـ $name. تتوقف كلمة المرور الحالية عن العمل فورًا.';
  }

  @override
  String get employeeDeactivateTitle => 'تعطيل هذا الحساب؟';

  @override
  String employeeDeactivateBody(String name) {
    return 'سيفقد $name فورًا الوصول إلى بيانات الزبائن على كل الأجهزة.';
  }

  @override
  String get employeeDeactivateHint => 'يمنع الوصول فورًا.';

  @override
  String get employeeActivateTitle => 'إعادة تفعيل هذا الحساب؟';

  @override
  String employeeActivateBody(String name) {
    return 'سيتمكن $name من تسجيل الدخول مجددًا.';
  }

  @override
  String get employeeActivateHint => 'يعيد الوصول.';

  @override
  String get employeeDeactivated => 'تم تعطيل الحساب';

  @override
  String get employeeActivated => 'تم تفعيل الحساب';

  @override
  String get employeeSelfHint => 'لا يمكنك تعطيل حسابك الخاص.';

  @override
  String get employeeRecentActivity => 'النشاط الأخير';

  @override
  String get activityTitle => 'سجل النشاط';

  @override
  String get activityEmpty => 'لا يوجد نشاط بعد';

  @override
  String get activityFilterAdmin => 'التعديلات';

  @override
  String get activityFilterField => 'الميدان';

  @override
  String get activitySystem => 'النظام';

  @override
  String logCustomerCreated(String name) {
    return 'إنشاء الزبون $name';
  }

  @override
  String logCustomerUpdated(String name) {
    return 'تعديل $name';
  }

  @override
  String logCustomerLocation(String name) {
    return 'تعديل موقع $name';
  }

  @override
  String logCustomerArchived(String name) {
    return 'أرشفة $name';
  }

  @override
  String logCustomerRestored(String name) {
    return 'استعادة $name';
  }

  @override
  String logCustomerDeleted(String name) {
    return 'حذف $name';
  }

  @override
  String logCustomerViewed(String name) {
    return 'اطّلع على $name';
  }

  @override
  String logCustomerCalled(String name) {
    return 'اتصل بـ $name';
  }

  @override
  String logCustomerWhatsapp(String name) {
    return 'فتح واتساب مع $name';
  }

  @override
  String logCustomerNavigated(String name) {
    return 'بدأ الملاحة نحو $name';
  }

  @override
  String logEmployeeCreated(String name) {
    return 'إنشاء حساب لـ $name';
  }

  @override
  String logEmployeeActivated(String name) {
    return 'تفعيل $name';
  }

  @override
  String logEmployeeDeactivated(String name) {
    return 'تعطيل $name';
  }

  @override
  String logEmployeePassword(String name) {
    return 'إعادة تعيين كلمة مرور $name';
  }

  @override
  String logEmployeeUpdated(String name) {
    return 'تعديل حساب $name';
  }

  @override
  String get logDuplicateDismissed => 'تعليم زبونين كمختلفين';

  @override
  String get logSettingsUpdated => 'تعديل إعدادات الشركة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsIntro => 'تغييرات الدليل التي وصلت إلى هذا الهاتف.';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyBody =>
      'سيظهر هنا الزبائن الجدد وتغييرات المواقع.';

  @override
  String get notifCreated => 'زبون جديد';

  @override
  String get notifUpdated => 'تم تعديل الزبون';

  @override
  String get notifLocation => 'تم تغيير الموقع';

  @override
  String get notifArchived => 'تمت أرشفة الزبون';

  @override
  String get notifRestored => 'تمت استعادة الزبون';

  @override
  String get notifDeleted => 'تم حذف الزبون';

  @override
  String get settingsAccountGroup => 'الحساب';

  @override
  String get settingsAdminGroup => 'الإدارة';

  @override
  String get settingsDataGroup => 'البيانات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsAccount => 'الحساب وكلمة المرور';

  @override
  String get settingsAccountInfo => 'الحساب';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsApp => 'إعدادات الشركة';

  @override
  String get settingsCompany => 'الشركة';

  @override
  String get settingsMapCenter => 'منطقة الخريطة الافتراضية';

  @override
  String get settingsMapCenterHint =>
      'المكان الذي تُفتح عليه الخرائط عند عدم اختيار زبون.';

  @override
  String settingsMapZoom(int zoom) {
    return 'مستوى التكبير: $zoom';
  }

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get profileSaved => 'تم تحديث الملف';

  @override
  String get profileRoleHint =>
      'لا يمكن تغيير دورك واسم المستخدم إلا من طرف المسؤول.';

  @override
  String get languageSystem => 'لغة الهاتف';

  @override
  String get languageSystemHint => 'تتبع إعدادات الهاتف';

  @override
  String get languageNote => 'تظهر أسماء الزبائن دائمًا كما أُدخلت.';

  @override
  String get signOutTitle => 'تسجيل الخروج؟';

  @override
  String get signOutBody => 'سيتم مسح بيانات الزبائن المحفوظة على هذا الهاتف.';
}
