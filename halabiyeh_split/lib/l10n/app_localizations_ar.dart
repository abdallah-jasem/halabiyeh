// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navSplit => 'الحساب';

  @override
  String get navHistory => 'السجل';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get outingLabel => 'الطلعة';

  @override
  String friendsAndItems(int friends, int items) {
    return '$friends أشخاص · $items أكلات';
  }

  @override
  String get total => 'المجموع';

  @override
  String get sectionFriends => 'الشلة';

  @override
  String get sectionItems => 'الأكلات';

  @override
  String get sectionPaid => 'مين دفع؟';

  @override
  String get sectionResults => 'النتيجة';

  @override
  String get add => 'ضيف';

  @override
  String get addItem => 'ضيف أكلة';

  @override
  String get servicePercent => 'الخدمة %';

  @override
  String get tip => 'البخشيش';

  @override
  String get name => 'الاسم';

  @override
  String get share => 'حصته';

  @override
  String get paid => 'دفع';

  @override
  String get diff => 'الفرق';

  @override
  String get copyWhatsapp => 'انسخ للواتس';

  @override
  String get copied => 'انتسخ';

  @override
  String get sharePdf => 'شارك PDF';

  @override
  String get saveToHistory => 'احفظ الطلعة بالسجل';

  @override
  String get savedToHistory => 'انحفظت بالسجل';

  @override
  String get addFriend => 'ضيف حدا';

  @override
  String get editFriend => 'عدّل الاسم';

  @override
  String get hintName => 'الاسم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get remove => 'شيل';

  @override
  String get save => 'احفظ';

  @override
  String get itemName => 'اسم الأكلة';

  @override
  String get itemLabel => 'الأكلة';

  @override
  String get price => 'السعر';

  @override
  String get whoShared => 'مين تشارك فيها؟';

  @override
  String get all => 'الكل';

  @override
  String get equal => 'بالتساوي';

  @override
  String get uneven => 'مو بالتساوي';

  @override
  String get auto => 'تلقائي';

  @override
  String sharing(int count) {
    return '$count متشاركين';
  }

  @override
  String get noOneShares => 'ما حدا متشارك فيها';

  @override
  String paidMissing(int paid, int total, int missing) {
    return 'دفعتوا $paid من $total (ناقص $missing)';
  }

  @override
  String paidOver(int paid, int total, int over) {
    return 'دفعتوا $paid من $total (زيادة $over)';
  }

  @override
  String get settleUp => 'مين بيدفع لمين';

  @override
  String get allSettled => 'كلشي خالص';

  @override
  String gives(String from, String to, int amount) {
    return '$from بيعطي $to $amount';
  }

  @override
  String get getsBack => 'إلو';

  @override
  String get owes => 'عليه';

  @override
  String get receipt => 'الفاتورة';

  @override
  String get attachReceipt => 'صوّر الفاتورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get removeReceipt => 'شيل الفاتورة';

  @override
  String get newOuting => 'طلعة جديدة';

  @override
  String get noHistory => 'ما في طلعات محفوظة';

  @override
  String historyRow(String date, int people, int total) {
    return '$date · $people أشخاص · $total';
  }

  @override
  String get yourName => 'اسمك';

  @override
  String get accentColor => 'لون التطبيق';

  @override
  String get savedGroup => 'الشلة المحفوظة';

  @override
  String get savedGroupHint => 'هدول بينضافوا لكل طلعة جديدة.';

  @override
  String get loadGroup => 'جيب الشلة';

  @override
  String get language => 'اللغة';

  @override
  String get duplicateName => 'الاسم موجود';

  @override
  String get price0 => 'لازم السعر يكون أكتر من 0';

  @override
  String get noServiceHint => 'الخدمة والبخشيش بدهن أكلة إلها سعر';

  @override
  String get unevenHint =>
      'اكتب قديش أكل كل واحد، مو قديش دفع. الفاضي بيتقسم عليه الباقي.';

  @override
  String unevenMismatch(int assigned, int price) {
    return 'المبالغ مجموعها $assigned والأكلة سعرها $price';
  }

  @override
  String unbalanced(int gap) {
    return 'الحساب مو مزبوط (الفرق $gap). صلّح المدفوع أو الأكلات أول.';
  }

  @override
  String get serviceTip => 'خدمة وبخشيش';
}
