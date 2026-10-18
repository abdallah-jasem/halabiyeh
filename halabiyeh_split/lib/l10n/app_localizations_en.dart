// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navSplit => 'Split';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get outingLabel => 'OUTING';

  @override
  String friendsAndItems(int friends, int items) {
    return '$friends friends · $items items';
  }

  @override
  String get total => 'Total';

  @override
  String get sectionFriends => 'Friends';

  @override
  String get sectionItems => 'Items';

  @override
  String get sectionPaid => 'Who paid?';

  @override
  String get sectionResults => 'Results';

  @override
  String get add => 'Add';

  @override
  String get addItem => 'Add item';

  @override
  String get servicePercent => 'Service %';

  @override
  String get tip => 'Tip';

  @override
  String get name => 'Name';

  @override
  String get share => 'Share';

  @override
  String get paid => 'Paid';

  @override
  String get diff => 'Diff';

  @override
  String get copyWhatsapp => 'Copy for WhatsApp';

  @override
  String get copied => 'Copied';

  @override
  String get saveToHistory => 'Save outing to history';

  @override
  String get savedToHistory => 'Saved to history';

  @override
  String get addFriend => 'Add friend';

  @override
  String get editFriend => 'Edit friend';

  @override
  String get hintName => 'Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get itemName => 'Item name';

  @override
  String get itemLabel => 'Item';

  @override
  String get price => 'Price';

  @override
  String get whoShared => 'Who shared it?';

  @override
  String get all => 'All';

  @override
  String get equal => 'Equal';

  @override
  String get uneven => 'Uneven';

  @override
  String get auto => 'auto';

  @override
  String sharing(int count) {
    return '$count sharing';
  }

  @override
  String get noOneShares => 'No one shares this item';

  @override
  String paidMissing(int paid, int total, int missing) {
    return 'Paid $paid of $total (missing $missing)';
  }

  @override
  String paidOver(int paid, int total, int over) {
    return 'Paid $paid of $total (over by $over)';
  }

  @override
  String get settleUp => 'Settle up';

  @override
  String get allSettled => 'All settled';

  @override
  String gives(String from, String to, int amount) {
    return '$from gives $to $amount';
  }

  @override
  String get getsBack => 'gets back';

  @override
  String get owes => 'owes';

  @override
  String get receipt => 'Receipt';

  @override
  String get attachReceipt => 'Attach receipt';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removeReceipt => 'Remove receipt';

  @override
  String get newOuting => 'New outing';

  @override
  String get noHistory => 'No saved outings yet';

  @override
  String historyRow(String date, int people, int total) {
    return '$date · $people people · $total';
  }

  @override
  String get yourName => 'Your name';

  @override
  String get accentColor => 'Accent color';

  @override
  String get savedGroup => 'Saved group';

  @override
  String get savedGroupHint => 'These friends are added to every new outing.';

  @override
  String get loadGroup => 'Load group';

  @override
  String get language => 'Language';

  @override
  String get duplicateName => 'Name already added';

  @override
  String get price0 => 'Price must be above 0';

  @override
  String get noServiceHint => 'Service and tip need at least one priced item';

  @override
  String get unevenHint =>
      'Type what each person ATE, not what they paid. Leave empty to split the rest.';

  @override
  String unevenMismatch(int assigned, int price) {
    return 'Amounts add up to $assigned, but the item costs $price';
  }

  @override
  String unbalanced(int gap) {
    return 'The bill doesn\'t balance (off by $gap). Fix payments or items first.';
  }

  @override
  String get serviceTip => 'Service + tip';
}
