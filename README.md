# Halabiyeh · حلبية

Split a group bill with your friends: who ate what, who paid, and who owes whom.
Android app built with Flutter, in English and Arabic.

## What it does

You go out with friends. One person pays most of the bill, someone else pays a bit, and nobody
ate the same amount. Halabiyeh works out each person's fair share and the fewest transfers
that settle everyone.

- **Friends**: add, rename, or remove names. Save "the usual friends" once and every new
  outing starts with them.
- **Items**: name and price for each thing ordered. Tap the names of the people who shared it,
  or "All".
- **Equal or uneven split**: split an item equally, or type a fixed amount one person ate and
  split the rest among the others.
- **Service and tip**: service % and tip are split in proportion to what each person ordered.
- **Who paid**: type what each person paid. Sums work too: `150 + 60` becomes 210.
  The app warns you when the payments don't match the bill total.
- **Results**: each person's share, what they paid, and the difference, with a line under
  each name that shows where the share came from.
- **Settle up**: "Ziad gives Kekhia 110". The fewest transfers to make everyone even.
- **Share**: copy a WhatsApp-ready summary of the bill and settlement.
- **Receipt photo**: attach a photo of the bill as proof.
- **History**: every outing is saved on the phone with its name, date, people, and total.
- **Arabic / English**: switch the whole app, including right-to-left layout and the WhatsApp
  text.

Everything stays on the phone. No account, no server, no internet needed.

## How the math works

An example with three friends:

| Item  | Price | Shared by            | Split                         |
|-------|------:|----------------------|-------------------------------|
| Mixed | 210   | Kekhia, Abood, Ziad  | Kekhia ate 40, rest split equally |
| Food  | 60    | Kekhia, Abood, Ziad  | Equal                         |
| Cola  | 15    | Kekhia, Abood, Ziad  | Equal                         |

**1. Each item is split among the people who shared it.**
Mixed: Kekhia's fixed 40 comes first, and the remaining 170 splits equally, so Abood and Ziad
each get 85. Food is 20 each, Cola is 5 each.

**2. Shares add up per person.**

| Name   | Share | Paid | Difference |
|--------|------:|-----:|-----------:|
| Kekhia | 65    | 210  | +145       |
| Abood  | 110   | 75   | −35        |
| Ziad   | 110   | 0    | −110       |
| Total  | 285   | 285  | 0          |

Difference = paid − share. Positive means the person gets money back, negative means they owe.

**3. Service and tip** (when set) are added to each person in proportion to their item share.
Someone who ate half the food pays half the service.

**4. Settle up.** The app takes the person who owes the most and pays the person who is owed
the most, then repeats until everyone is at zero:

- Ziad gives Kekhia 110
- Abood gives Kekhia 35

This gives at most one transfer fewer than the number of people.

**5. Checks.** If the payments don't add up to the bill, an item has no one sharing it, or the
uneven amounts don't fit the item's price, the app shows a warning and holds back the
settlement until the bill balances.

## Install

Android only. Download **Halabiyeh.apk** from the
[latest release](https://github.com/abdallah-jasem/halabiyeh/releases/latest), open it on your
phone, and tap Install (allow installs from unknown sources if Android asks).
Older phones that refuse it: use **Halabiyeh-universal.apk** from the same release.

Or build it yourself:

```bash
cd halabiyeh_split
flutter pub get
flutter build apk --release
```

The APK lands in `halabiyeh_split/build/app/outputs/flutter-apk/`.
Release builds sign with `android/key.properties` when present; create your own keystore for that.

## Development

```bash
cd halabiyeh_split
flutter run          # run on a connected phone or emulator
flutter test         # unit tests for the money math + a widget test
flutter analyze
```

### Stack

| Part       | Choice |
|------------|--------|
| UI         | Flutter (Material 3) |
| State      | Riverpod |
| Storage    | Hive for history and the saved group, SharedPreferences for settings |
| Languages  | `flutter gen-l10n` with English and Arabic `.arb` files |

### Project layout

Clean Architecture (light), organized by feature. The money math is plain Dart with no
Flutter imports, so it is easy to test.

```
halabiyeh_split/lib/
  core/            theme, Hive setup, dependency wiring
  features/
    bill/          the outing editor
      domain/      entities + use cases: split, balances, settle up, sum parsing
      data/        receipt photo storage
      presentation/ Split screen and its Riverpod state
    history/       saved outings (Hive)
    groups/        "the usual friends" (Hive)
    share/         WhatsApp text
    settings/      name, color, language
    nav/           bottom navigation
  l10n/            English and Arabic strings
```

