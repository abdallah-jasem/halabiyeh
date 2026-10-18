import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../share/domain/format_outing_summary.dart';
import '../../data/receipt_store.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/outing_item.dart';
import '../../domain/usecases/calculate_balances.dart';
import '../../domain/usecases/parse_amount.dart';
import '../../domain/usecases/settle_up.dart';
import '../outing_notifier.dart';
import '../widgets/money_text.dart';

const _red = Color(0xFFA8441C);
const _green = Color(0xFF1E5F48);

ShareLabels shareLabels(AppLocalizations l) =>
    ShareLabels(total: l.total, getsBack: l.getsBack, owes: l.owes, settleUp: l.settleUp, gives: l.gives);

class SplitScreen extends ConsumerWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(outingProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final outing = ref.watch(outingProvider);
    final balances = ref.watch(balancesProvider);
    final transfers = ref.watch(transfersProvider);
    final nameFor = {for (final m in outing.members) m.id: m.name};
    final paidGap = outing.total - outing.totalPaid;
    final breakdown = shareBreakdown(outing);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          // New id (after save / open from history) rebuilds every field.
          key: ValueKey(outing.id),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: settings.accent, foregroundColor: Colors.white, child: const Text('حـ')),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halabiyeh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('حلبية', style: TextStyle(color: kMuted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.outingLabel, style: const TextStyle(fontSize: 12, color: kMuted)),
                  TextFormField(
                    initialValue: outing.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    onChanged: notifier.setTitle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l.friendsAndItems(outing.members.length, outing.items.length),
                          style: const TextStyle(color: kMuted),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l.total, style: const TextStyle(fontSize: 12, color: kMuted)),
                          MoneyText(outing.total, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _SectionHeader('1', l.sectionFriends),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in outing.members)
                  InputChip(
                    label: Text(m.name, overflow: TextOverflow.ellipsis),
                    avatar: CircleAvatar(backgroundColor: Color(m.colorValue)),
                    onPressed: () => _promptEditMember(context, ref, m),
                    onDeleted: () => notifier.removeMember(m.id),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l.add),
                  onPressed: () => _promptAddMember(context, ref),
                ),
                ActionChip(
                  avatar: const Icon(Icons.group_add_outlined, size: 18),
                  label: Text(l.loadGroup),
                  onPressed: notifier.loadGroup,
                ),
              ],
            ),
            const SizedBox(height: 22),

            _SectionHeader('2', l.sectionItems),
            for (final item in outing.items) _ItemCard(key: ValueKey(item.id), item: item, members: outing.members),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.addItem),
              onPressed: () => _promptAddItem(context, ref),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.servicePercent, style: const TextStyle(fontSize: 13, color: kMuted)),
                        TextFormField(
                          initialValue: outing.servicePercent.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (v) => notifier.setServicePercent(double.tryParse(v) ?? 0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.tip, style: const TextStyle(fontSize: 13, color: kMuted)),
                        TextFormField(
                          initialValue: outing.tip.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          onChanged: (v) => notifier.setTip(double.tryParse(v) ?? 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (outing.subtotal == 0 && (outing.servicePercent != 0 || outing.tip != 0))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(l.noServiceHint, style: const TextStyle(color: _red, fontSize: 13)),
              ),
            const SizedBox(height: 12),

            _SectionHeader('3', l.sectionPaid),
            _Card(
              child: Column(
                children: [
                  for (final m in outing.members)
                    _PaidRow(
                      key: ValueKey(m.id),
                      member: m,
                      initial: outing.payments[m.id] ?? 0,
                      onChanged: (v) => notifier.setPayment(m.id, v),
                    ),
                  if (paidGap.abs() >= 0.5)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: _red, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              paidGap > 0
                                  ? l.paidMissing(outing.totalPaid.round(), outing.total.round(), paidGap.round())
                                  : l.paidOver(outing.totalPaid.round(), outing.total.round(), (-paidGap).round()),
                              style: const TextStyle(color: _red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _SectionHeader('4', l.sectionResults),
            _Card(
              child: Table(
                columnWidths: const {0: FlexColumnWidth(2)},
                children: [
                  TableRow(children: [_head(l.name, start: true), _head(l.share), _head(l.paid), _head(l.diff)]),
                  for (final b in balances)
                    TableRow(
                      children: [
                        _cell(
                          _NameWithBreakdown(
                            name: nameFor[b.memberId] ?? '?',
                            lines: breakdown[b.memberId] ?? const {},
                          ),
                        ),
                        _cell(MoneyText(b.share, textAlign: TextAlign.end)),
                        _cell(MoneyText(b.paid, textAlign: TextAlign.end)),
                        _cell(
                          MoneyText(
                            b.diff,
                            signed: true,
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold, color: b.diff >= 0 ? _green : _red),
                          ),
                        ),
                      ],
                    ),
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFDDD9CF))),
                    ),
                    children: [
                      _cell(Text(l.total, style: const TextStyle(fontWeight: FontWeight.bold))),
                      _cell(
                        MoneyText(
                          balances.fold(0.0, (s, b) => s + b.share),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _cell(
                        MoneyText(
                          balances.fold(0.0, (s, b) => s + b.paid),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _cell(
                        MoneyText(
                          balances.fold(0.0, (s, b) => s + b.diff),
                          signed: true,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settleUp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  if (!isBalanced(balances))
                    Text(l.unbalanced(balanceGap(balances).round().abs()), style: const TextStyle(color: _red))
                  else if (transfers.isEmpty)
                    Text(l.allSettled, style: const TextStyle(color: kMuted))
                  else
                    for (final t in transfers)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          l.gives(isolate(nameFor[t.fromId] ?? '?'), isolate(nameFor[t.toId] ?? '?'), t.amount.round()),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _ReceiptCard(path: outing.receiptPath),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: Text(l.copyWhatsapp),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () async {
                final text = formatOutingSummary(outing, shareLabels(l));
                await Clipboard.setData(ClipboardData(text: text));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                }
              },
            ),
            const SizedBox(height: 10),

            FilledButton.icon(
              icon: const Icon(Icons.history),
              label: Text(l.saveToHistory),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54), backgroundColor: settings.accent),
              onPressed: () async {
                await notifier.save(settings.language);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.savedToHistory)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _head(String text, {bool start = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      text,
      textAlign: start ? TextAlign.start : TextAlign.end,
      style: const TextStyle(color: kMuted, fontSize: 12),
    ),
  );

  Widget _cell(Widget child) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: child);

  Future<void> _promptAddMember(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addFriend),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.hintName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(l.add)),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    if (!ref.read(outingProvider.notifier).addMember(name) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.duplicateName)));
    }
  }

  Future<void> _promptEditMember(BuildContext context, WidgetRef ref, Member member) async {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(outingProvider.notifier);
    final controller = TextEditingController(text: member.name);
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editFriend),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.hintName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: Text(l.remove, style: const TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, 'save'), child: Text(l.save)),
        ],
      ),
    );
    if (action == 'delete') {
      notifier.removeMember(member.id);
    } else if (action == 'save' && controller.text.trim().isNotEmpty) {
      notifier.renameMember(member.id, controller.text.trim());
    }
  }

  Future<void> _promptAddItem(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(outingProvider.notifier);
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(l.addItem),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: l.itemName),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(hintText: l.price, errorText: error),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
              FilledButton(
                onPressed: () {
                  final price = double.tryParse(priceController.text) ?? 0;
                  if (nameController.text.trim().isEmpty) return;
                  if (price <= 0) return setState(() => error = l.price0);
                  notifier.addItem(
                    name: nameController.text.trim(),
                    price: price,
                    sharedBy: ref.read(outingProvider).members.map((m) => m.id).toList(),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(l.add),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One "Who paid?" row. Keeps the raw text so "150 + 60" survives typing.
class _PaidRow extends StatefulWidget {
  final Member member;
  final double initial;
  final ValueChanged<double> onChanged;
  const _PaidRow({super.key, required this.member, required this.initial, required this.onChanged});

  @override
  State<_PaidRow> createState() => _PaidRowState();
}

class _PaidRowState extends State<_PaidRow> {
  late final _controller = TextEditingController(text: widget.initial.toStringAsFixed(0));
  double? _sum;

  @override
  void initState() {
    super.initState();
    _sum = widget.initial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final showSum = _sum != null && _controller.text.contains('+');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: Color(m.colorValue), radius: 18, child: Text(m.name[0])),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(m.name)),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+.\s]'))],
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                error: _sum == null ? const SizedBox.shrink() : null,
                helperText: showSum ? '= ${_sum!.round()}' : null,
              ),
              onChanged: (v) {
                final parsed = parseAmountSum(v);
                setState(() => _sum = parsed);
                if (parsed != null) widget.onChanged(parsed);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends ConsumerWidget {
  final String? path;
  const _ReceiptCard({required this.path});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(outingProvider.notifier);
    final file = path == null ? null : File(path!);
    final exists = file != null && file.existsSync();

    Future<void> pick(ImageSource source) async {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      notifier.setReceipt(await storeReceipt(picked.path));
    }

    return _Card(
      child: Row(
        children: [
          if (exists)
            GestureDetector(
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => Dialog(child: InteractiveViewer(child: Image.file(file))),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(file, width: 64, height: 64, fit: BoxFit.cover),
              ),
            )
          else
            const Icon(Icons.receipt_outlined, size: 32, color: kMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l.receipt, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (exists)
            IconButton(
              tooltip: l.removeReceipt,
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                file.deleteSync();
                notifier.setReceipt(null);
              },
            )
          else ...[
            IconButton(
              tooltip: l.camera,
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: () => pick(ImageSource.camera),
            ),
            IconButton(
              tooltip: l.gallery,
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: () => pick(ImageSource.gallery),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  const _SectionHeader(this.number, this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            number,
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: child,
    );
  }
}

class _ItemCard extends ConsumerStatefulWidget {
  final OutingItem item;
  final List<Member> members;
  const _ItemCard({super.key, required this.item, required this.members});

  @override
  ConsumerState<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<_ItemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notifier = ref.read(outingProvider.notifier);
    final item = widget.item;

    if (!_expanded) {
      return _Card(
        child: InkWell(
          onTap: () => setState(() => _expanded = true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    item.sharedByMemberIds.isEmpty
                        ? Text(l.noOneShares, style: const TextStyle(fontSize: 13, color: _red))
                        : unevenMismatch(item) != null
                        ? Text(
                            l.unevenMismatch(unevenMismatch(item)!.round(), item.price.round()),
                            style: const TextStyle(fontSize: 13, color: _red),
                          )
                        : Text(
                            l.sharing(item.sharedByMemberIds.length),
                            style: const TextStyle(fontSize: 13, color: kMuted),
                          ),
                  ],
                ),
              ),
              MoneyText(item.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => notifier.removeItem(item.id)),
            ],
          ),
        ),
      );
    }

    final shares = itemShares(item);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(labelText: l.itemLabel, isDense: true),
                  onChanged: (v) => notifier.updateItem(item.copyWith(name: v)),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: TextFormField(
                  initialValue: item.price.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(labelText: l.price, isDense: true),
                  onChanged: (v) => notifier.updateItem(item.copyWith(price: double.tryParse(v) ?? 0)),
                ),
              ),
              IconButton(icon: const Icon(Icons.expand_less), onPressed: () => setState(() => _expanded = false)),
            ],
          ),
          const SizedBox(height: 10),
          Text(l.whoShared, style: const TextStyle(fontSize: 12, color: kMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilterChip(
                avatar: const Icon(Icons.groups_outlined, size: 18),
                showCheckmark: false,
                label: Text(l.all, style: const TextStyle(fontWeight: FontWeight.w600)),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                selected: item.sharedByMemberIds.length == widget.members.length,
                onSelected: (_) =>
                    notifier.updateItem(item.copyWith(sharedByMemberIds: widget.members.map((m) => m.id).toList())),
              ),
              for (final m in widget.members)
                FilterChip(
                  label: Text(m.name),
                  selected: item.sharedByMemberIds.contains(m.id),
                  onSelected: (selected) {
                    final ids = List<String>.from(item.sharedByMemberIds);
                    selected ? ids.add(m.id) : ids.remove(m.id);
                    notifier.updateItem(item.copyWith(sharedByMemberIds: ids));
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SplitMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: SplitMode.equal, label: Text(l.equal)),
                ButtonSegment(value: SplitMode.uneven, label: Text(l.uneven)),
              ],
              selected: {item.splitMode},
              onSelectionChanged: (m) => notifier.updateItem(item.copyWith(splitMode: m.first)),
            ),
          ),
          const SizedBox(height: 10),
          if (item.splitMode == SplitMode.uneven) ...[
            Text(l.unevenHint, style: const TextStyle(fontSize: 12, color: kMuted)),
            if (unevenMismatch(item) != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.unevenMismatch(unevenMismatch(item)!.round(), item.price.round()),
                  style: const TextStyle(fontSize: 13, color: _red),
                ),
              ),
            const SizedBox(height: 6),
          ],
          for (final memberId in item.sharedByMemberIds)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(widget.members.firstWhere((m) => m.id == memberId).name)),
                  if (item.splitMode == SplitMode.uneven)
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        key: ValueKey('${item.id}-$memberId-fixed'),
                        initialValue: item.fixedShares[memberId]?.toStringAsFixed(0) ?? '',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(isDense: true, hintText: l.auto),
                        onChanged: (v) {
                          final fixed = Map<String, double>.from(item.fixedShares);
                          final parsed = double.tryParse(v);
                          parsed == null ? fixed.remove(memberId) : fixed[memberId] = parsed;
                          notifier.updateItem(item.copyWith(fixedShares: fixed));
                        },
                      ),
                    )
                  else
                    MoneyText(shares[memberId] ?? 0, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Name plus where the share came from: "Food 20 · Cola 5 · Service + tip 3".
class _NameWithBreakdown extends StatelessWidget {
  final String name;
  final Map<String, double> lines;
  const _NameWithBreakdown({required this.name, required this.lines});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final parts = [
      for (final e in lines.entries)
        if (e.value.round() != 0)
          '${isolate(e.key == serviceTipKey ? l.serviceTip : e.key)} ${ltr('${e.value.round()}')}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name),
        if (parts.isNotEmpty) Text(parts.join(' · '), style: const TextStyle(fontSize: 11, color: kMuted)),
      ],
    );
  }
}
