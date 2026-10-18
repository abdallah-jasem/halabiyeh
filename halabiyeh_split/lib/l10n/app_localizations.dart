import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @navSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get navSplit;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @outingLabel.
  ///
  /// In en, this message translates to:
  /// **'OUTING'**
  String get outingLabel;

  /// No description provided for @friendsAndItems.
  ///
  /// In en, this message translates to:
  /// **'{friends} friends · {items} items'**
  String friendsAndItems(int friends, int items);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @sectionFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get sectionFriends;

  /// No description provided for @sectionItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get sectionItems;

  /// No description provided for @sectionPaid.
  ///
  /// In en, this message translates to:
  /// **'Who paid?'**
  String get sectionPaid;

  /// No description provided for @sectionResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get sectionResults;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @servicePercent.
  ///
  /// In en, this message translates to:
  /// **'Service %'**
  String get servicePercent;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @diff.
  ///
  /// In en, this message translates to:
  /// **'Diff'**
  String get diff;

  /// No description provided for @copyWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Copy for WhatsApp'**
  String get copyWhatsapp;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @saveToHistory.
  ///
  /// In en, this message translates to:
  /// **'Save outing to history'**
  String get saveToHistory;

  /// No description provided for @savedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get savedToHistory;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get addFriend;

  /// No description provided for @editFriend.
  ///
  /// In en, this message translates to:
  /// **'Edit friend'**
  String get editFriend;

  /// No description provided for @hintName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hintName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @itemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemLabel;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @whoShared.
  ///
  /// In en, this message translates to:
  /// **'Who shared it?'**
  String get whoShared;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @equal.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get equal;

  /// No description provided for @uneven.
  ///
  /// In en, this message translates to:
  /// **'Uneven'**
  String get uneven;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get auto;

  /// No description provided for @sharing.
  ///
  /// In en, this message translates to:
  /// **'{count} sharing'**
  String sharing(int count);

  /// No description provided for @noOneShares.
  ///
  /// In en, this message translates to:
  /// **'No one shares this item'**
  String get noOneShares;

  /// No description provided for @paidMissing.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {total} (missing {missing})'**
  String paidMissing(int paid, int total, int missing);

  /// No description provided for @paidOver.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {total} (over by {over})'**
  String paidOver(int paid, int total, int over);

  /// No description provided for @settleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUp;

  /// No description provided for @allSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled'**
  String get allSettled;

  /// No description provided for @gives.
  ///
  /// In en, this message translates to:
  /// **'{from} gives {to} {amount}'**
  String gives(String from, String to, int amount);

  /// No description provided for @getsBack.
  ///
  /// In en, this message translates to:
  /// **'gets back'**
  String get getsBack;

  /// No description provided for @owes.
  ///
  /// In en, this message translates to:
  /// **'owes'**
  String get owes;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @attachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt'**
  String get attachReceipt;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @removeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove receipt'**
  String get removeReceipt;

  /// No description provided for @newOuting.
  ///
  /// In en, this message translates to:
  /// **'New outing'**
  String get newOuting;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved outings yet'**
  String get noHistory;

  /// No description provided for @historyRow.
  ///
  /// In en, this message translates to:
  /// **'{date} · {people} people · {total}'**
  String historyRow(String date, int people, int total);

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @savedGroup.
  ///
  /// In en, this message translates to:
  /// **'Saved group'**
  String get savedGroup;

  /// No description provided for @savedGroupHint.
  ///
  /// In en, this message translates to:
  /// **'These friends are added to every new outing.'**
  String get savedGroupHint;

  /// No description provided for @loadGroup.
  ///
  /// In en, this message translates to:
  /// **'Load group'**
  String get loadGroup;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @duplicateName.
  ///
  /// In en, this message translates to:
  /// **'Name already added'**
  String get duplicateName;

  /// No description provided for @price0.
  ///
  /// In en, this message translates to:
  /// **'Price must be above 0'**
  String get price0;

  /// No description provided for @noServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Service and tip need at least one priced item'**
  String get noServiceHint;

  /// No description provided for @unevenHint.
  ///
  /// In en, this message translates to:
  /// **'Type what each person ATE, not what they paid. Leave empty to split the rest.'**
  String get unevenHint;

  /// No description provided for @unevenMismatch.
  ///
  /// In en, this message translates to:
  /// **'Amounts add up to {assigned}, but the item costs {price}'**
  String unevenMismatch(int assigned, int price);

  /// No description provided for @unbalanced.
  ///
  /// In en, this message translates to:
  /// **'The bill doesn\'t balance (off by {gap}). Fix payments or items first.'**
  String unbalanced(int gap);

  /// No description provided for @serviceTip.
  ///
  /// In en, this message translates to:
  /// **'Service + tip'**
  String get serviceTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
