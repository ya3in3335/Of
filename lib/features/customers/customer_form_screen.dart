import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/algeria.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/text_normalizer.dart';
import '../../core/utils/validators.dart';
import '../../data/models/customer.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';
import '../maps/location_picker_screen.dart';
import '../maps/map_widgets.dart';
import 'customer_profile_screen.dart';

/// Add (customerId == null) or edit a customer. Admin only (route guard + RLS).
class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customerId});
  final String? customerId;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _business = TextEditingController();
  final _phone = TextEditingController();
  final _phone2 = TextEditingController();
  final _whatsapp = TextEditingController();
  final _wilaya = TextEditingController();
  final _commune = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  Customer? _original;
  LatLng? _point;
  bool _archived = false;
  bool _whatsappSameAsPrimary = false;
  List<CustomerAddress> _extraAddresses = [];
  bool _dirty = false;
  bool _notesLoaded = false;
  List<Customer> _localDuplicates = const [];
  Timer? _dupDebounce;

  bool get _isEdit => widget.customerId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = ref.read(customerByIdProvider(widget.customerId!));
      if (c != null) _load(c);
    } else {
      _notesLoaded = true;
    }
    for (final c in [_first, _last, _phone, _phone2, _whatsapp]) {
      c.addListener(_scheduleDuplicateHint);
    }
  }

  void _load(Customer c) {
    _original = c;
    _first.text = c.firstName;
    _last.text = c.lastName;
    _business.text = c.businessName ?? '';
    _phone.text = Formatters.phone(c.primaryPhone);
    _phone2.text = Formatters.phone(c.secondaryPhone);
    _whatsapp.text = Formatters.phone(c.whatsappPhone);
    _whatsappSameAsPrimary = c.whatsappPhone != null && c.whatsappPhone == c.primaryPhone;
    _wilaya.text = c.wilaya;
    _commune.text = c.commune;
    _address.text = c.address;
    _point = c.point;
    _archived = c.isArchived;
    _extraAddresses = List.of(c.addresses);
  }

  @override
  void dispose() {
    _dupDebounce?.cancel();
    for (final c in [_first, _last, _business, _phone, _phone2, _whatsapp, _wilaya, _commune, _address, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// Instant local hint (device copy); the server check on save is authoritative.
  void _scheduleDuplicateHint() {
    _dupDebounce?.cancel();
    _dupDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final engine = ref.read(directoryProvider).engine;
      final found = engine.possibleDuplicates(
        firstName: _first.text,
        lastName: _last.text,
        phones: [_phone.text, _phone2.text, _whatsapp.text],
        excludeId: widget.customerId,
      );
      setState(() => _localDuplicates = found.take(3).toList());
    });
  }

  CustomerDraft _draft() {
    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final primary = TextNormalizer.normalizePhone(_phone.text)!;
    return CustomerDraft(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      businessName: opt(_business),
      primaryPhone: primary,
      secondaryPhone: TextNormalizer.normalizePhone(_phone2.text),
      whatsappPhone: _whatsappSameAsPrimary ? primary : TextNormalizer.normalizePhone(_whatsapp.text),
      wilaya: _wilaya.text.trim(),
      commune: _commune.text.trim(),
      address: _address.text.trim(),
      latitude: _point?.latitude,
      longitude: _point?.longitude,
      status: _archived ? CustomerStatus.archived : CustomerStatus.active,
      addresses: _extraAddresses,
      // Notes are only sent once loaded, so an edit made while they were still
      // loading cannot erase them.
      adminNotes: _notesLoaded ? _notes.text.trim() : null,
    );
  }

  bool _identityChanged(CustomerDraft d) {
    final o = _original;
    if (o == null) return true;
    return o.firstName != d.firstName ||
        o.lastName != d.lastName ||
        o.primaryPhone != d.primaryPhone ||
        o.secondaryPhone != d.secondaryPhone ||
        o.whatsappPhone != d.whatsappPhone;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      showToast(context, l10n.formFixErrors, kind: ToastKind.error);
      return;
    }
    if (ref.read(connectivityProvider).value == false) {
      showToast(context, l10n.errorOfflineSave, kind: ToastKind.error);
      return;
    }
    final draft = _draft();
    final repo = ref.read(customerRepositoryProvider);
    try {
      if (_identityChanged(draft)) {
        final duplicates = await repo.findDuplicates(draft, excludeId: widget.customerId);
        if (duplicates.isNotEmpty && mounted) {
          final proceed = await _confirmDuplicates(duplicates);
          if (!proceed) return;
        }
      }
      final saved = await repo.save(id: widget.customerId, draft: draft, expectedUpdatedAt: _original?.updatedAt);
      ref.read(directoryProvider.notifier).applyServerRow(saved);
      if (_isEdit) ref.invalidate(adminNotesProvider(saved.id));
      if (!mounted) return;
      _dirty = false;
      showToast(
        context,
        _isEdit ? l10n.customerUpdated : l10n.customerCreated(saved.reference),
        kind: ToastKind.success,
      );
      if (_isEdit) {
        context.pop();
      } else {
        context.pushReplacement(Routes.customer(saved.id));
      }
    } on AppException catch (e) {
      if (!mounted) return;
      if (e.kind == AppErrorKind.conflict) {
        await showConfirmDialog(
          context,
          icon: Icons.sync_problem_rounded,
          title: l10n.conflictTitle,
          message: l10n.conflictBody,
          confirmLabel: l10n.actionOk,
        );
        await ref.read(directoryProvider.notifier).sync();
        final fresh = ref.read(customerByIdProvider(widget.customerId!));
        if (fresh != null && mounted) {
          setState(() => _load(fresh));
        }
      } else {
        showErrorToast(context, e);
      }
    }
  }

  Future<bool> _confirmDuplicates(List<DuplicateCandidate> list) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: Space.xs),
                  Expanded(child: Text(l10n.duplicatesFoundTitle, style: Theme.of(context).textTheme.titleLarge)),
                ],
              ),
              const SizedBox(height: Space.xs),
              Text(l10n.duplicatesFoundBody, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: Space.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final d in list)
                      Container(
                        margin: const EdgeInsets.only(bottom: Space.xs),
                        padding: const EdgeInsets.all(Space.sm),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: Radii.field,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(child: Text(d.fullName, style: Theme.of(context).textTheme.titleSmall)),
                                      const SizedBox(width: 6),
                                      ReferencePill(d.reference),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${Formatters.phone(d.primaryPhone)} · ${d.cityLine}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: d.reason == 'phone' ? l10n.duplicateSamePhone : l10n.duplicateSimilarName,
                              tone: d.reason == 'phone' ? ChipTone.danger : ChipTone.warning,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
              FilledButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.duplicatesReview)),
              const SizedBox(height: Space.xs),
              OutlinedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.duplicatesSaveAnyway)),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<void> _pickLocation() async {
    final picked = await LocationPickerScreen.open(
      context,
      initial: _point,
      addressHint: [_address.text, _commune.text, _wilaya.text].where((s) => s.trim().isNotEmpty).join(', '),
    );
    if (picked == null) return;
    setState(() {
      _point = picked.point;
      _dirty = true;
      if (_commune.text.trim().isEmpty && picked.commune != null) _commune.text = picked.commune!;
    });
  }

  Future<void> _editExtraAddress([int? index]) async {
    final result = await showModalBottomSheet<CustomerAddress>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ExtraAddressSheet(initial: index == null ? null : _extraAddresses[index]),
    );
    if (result == null) return;
    setState(() {
      _dirty = true;
      if (index == null) {
        _extraAddresses = [..._extraAddresses, result];
      } else {
        _extraAddresses = List.of(_extraAddresses)..[index] = result;
      }
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final l10n = context.l10n;
    return showConfirmDialog(
      context,
      title: l10n.discardTitle,
      message: l10n.discardBody,
      confirmLabel: l10n.actionDiscard,
      destructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    if (_isEdit && _original == null) {
      final c = ref.watch(customerByIdProvider(widget.customerId!));
      if (c == null) {
        return Scaffold(
          appBar: AppBar(),
          body: EmptyState(icon: Icons.person_off_outlined, title: l10n.customerNotFoundTitle),
        );
      }
      _load(c);
    }

    if (_isEdit && !_notesLoaded) {
      final notes = ref.watch(adminNotesProvider(widget.customerId!));
      if (notes.hasValue && !_notesLoaded) {
        _notes.text = notes.value ?? '';
        _notesLoaded = true;
      }
    }

    InputDecoration deco(String label, {IconData? icon, String? hint, bool required = false}) => InputDecoration(
      labelText: required ? '$label *' : label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
    String? err(FieldError? e) => fieldErrorText(context, e);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          _dirty = false;
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l10n.customerEditTitle : l10n.customerNew),
          bottom: _original == null
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: ReferencePill(_original!.reference),
                  ),
                ),
        ),
        body: Form(
          key: _formKey,
          onChanged: _markDirty,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 140),
            children: [
              if (_localDuplicates.isNotEmpty) ...[
                _DuplicateHint(customers: _localDuplicates),
                const SizedBox(height: Space.md),
              ],
              SectionCard(
                title: l10n.formIdentity,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _first,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: deco(l10n.fieldFirstName, required: true),
                            validator: (v) => err(Validators.required(v, max: 80)),
                          ),
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: TextFormField(
                            controller: _last,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: deco(l10n.fieldLastName, required: true),
                            validator: (v) => err(Validators.required(v, max: 80)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.sm),
                    TextFormField(
                      controller: _business,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: deco(l10n.fieldBusinessName, icon: Icons.storefront_outlined),
                      validator: (v) => err(Validators.optional(v, max: 120)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.customerContact,
                child: Column(
                  children: [
                    _PhoneField(
                      controller: _phone,
                      label: l10n.fieldPrimaryPhone,
                      required: true,
                      validator: (v) => err(Validators.phone(v)),
                    ),
                    const SizedBox(height: Space.sm),
                    _PhoneField(
                      controller: _phone2,
                      label: l10n.fieldSecondaryPhone,
                      validator: (v) => err(Validators.phone(v, isRequired: false)),
                    ),
                    const SizedBox(height: Space.xs),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _whatsappSameAsPrimary,
                      title: Text(l10n.formWhatsappSame, style: text.bodyMedium),
                      secondary: const Icon(Icons.chat_rounded, color: AppColors.whatsapp),
                      onChanged: (v) => setState(() {
                        _whatsappSameAsPrimary = v;
                        _dirty = true;
                      }),
                    ),
                    if (!_whatsappSameAsPrimary)
                      _PhoneField(
                        controller: _whatsapp,
                        label: l10n.fieldWhatsappPhone,
                        icon: Icons.chat_outlined,
                        validator: (v) => err(Validators.phone(v, isRequired: false)),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: Space.xs),
                      child: Text(l10n.formWhatsappHint, style: text.bodySmall),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.formAddress,
                child: Column(
                  children: [
                    _WilayaField(
                      controller: _wilaya,
                      label: '${l10n.fieldWilaya} *',
                      validator: (v) => err(Validators.required(v, min: 2, max: 60)),
                    ),
                    const SizedBox(height: Space.sm),
                    TextFormField(
                      controller: _commune,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: deco(l10n.fieldCommune, icon: Icons.location_city_outlined, required: true),
                      validator: (v) => err(Validators.required(v, min: 2, max: 80)),
                    ),
                    const SizedBox(height: Space.sm),
                    TextFormField(
                      controller: _address,
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: deco(
                        l10n.fieldAddress,
                        icon: Icons.signpost_outlined,
                        required: true,
                        hint: l10n.fieldAddressHint,
                      ),
                      validator: (v) => err(Validators.required(v, min: 3, max: 300)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.customerLocation,
                child: _point == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l10n.formNoLocation, style: text.bodySmall),
                          const SizedBox(height: Space.sm),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                            onPressed: _pickLocation,
                            icon: const Icon(Icons.add_location_alt_rounded),
                            label: Text(l10n.actionSetLocation),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MiniMapPreview(point: _point!, height: 150),
                          const SizedBox(height: Space.xs),
                          Text(
                            Formatters.coordinates(_point!.latitude, _point!.longitude),
                            textDirection: TextDirection.ltr,
                            style: text.labelMedium,
                          ),
                          const SizedBox(height: Space.xs),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickLocation,
                                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                                  label: Text(l10n.actionChange),
                                ),
                              ),
                              const SizedBox(width: Space.xs),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                  onPressed: () => setState(() {
                                    _point = null;
                                    _dirty = true;
                                  }),
                                  icon: const Icon(Icons.location_off_outlined, size: 18),
                                  label: Text(l10n.actionRemove),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.customerOtherAddresses,
                trailing: TextButton.icon(
                  onPressed: _extraAddresses.length >= 20 ? null : () => _editExtraAddress(),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.actionAdd),
                ),
                child: _extraAddresses.isEmpty
                    ? Text(l10n.formNoExtraAddresses, style: text.bodySmall)
                    : Column(
                        children: [
                          for (var i = 0; i < _extraAddresses.length; i++)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                _extraAddresses[i].hasLocation
                                    ? Icons.location_on_rounded
                                    : Icons.location_off_outlined,
                                color: _extraAddresses[i].hasLocation ? AppColors.success : AppColors.warning,
                              ),
                              title: Text(_extraAddresses[i].label),
                              subtitle: Text(_extraAddresses[i].address, maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () => _editExtraAddress(i),
                              trailing: IconButton(
                                tooltip: l10n.actionRemove,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => setState(() {
                                  _extraAddresses = List.of(_extraAddresses)..removeAt(i);
                                  _dirty = true;
                                }),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: Space.md),
              SectionCard(
                title: l10n.fieldAdminNotes,
                trailing: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textTertiary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _notes,
                      enabled: _notesLoaded,
                      minLines: 2,
                      maxLines: 6,
                      maxLength: 4000,
                      decoration: InputDecoration(hintText: _notesLoaded ? l10n.adminNotesPlaceholder : l10n.loading),
                    ),
                    Text(l10n.adminNotesHint, style: text.bodySmall),
                  ],
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: Space.md),
                SectionCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: !_archived,
                    title: Text(l10n.formStatusActive),
                    subtitle: Text(_archived ? l10n.formStatusArchivedHint : l10n.formStatusActiveHint),
                    onChanged: (v) => setState(() {
                      _archived = !v;
                      _dirty = true;
                    }),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.sm),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: AsyncButton(
              label: _isEdit ? l10n.actionSaveChanges : l10n.actionCreateCustomer,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.label,
    required this.validator,
    this.required = false,
    this.icon = Icons.phone_outlined,
  });
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final bool required;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: '0555 12 34 56',
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

class _WilayaField extends StatefulWidget {
  const _WilayaField({required this.controller, required this.label, required this.validator});
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;

  @override
  State<_WilayaField> createState() => _WilayaFieldState();
}

class _WilayaFieldState extends State<_WilayaField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final validator = widget.validator;
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (value) {
        final q = TextNormalizer.normalize(value.text);
        if (q.isEmpty) return const [];
        return algerianWilayas.where((w) => TextNormalizer.normalize(w).contains(q)).take(6);
      },
      fieldViewBuilder: (context, ctrl, focus, onSubmit) => TextFormField(
        controller: ctrl,
        focusNode: focus,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.map_outlined)),
        validator: validator,
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: AlignmentDirectional.topStart,
        child: Material(
          elevation: 4,
          borderRadius: Radii.field,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [for (final o in options) ListTile(title: Text(o), onTap: () => onSelected(o))],
            ),
          ),
        ),
      ),
    );
  }
}

class _DuplicateHint extends StatelessWidget {
  const _DuplicateHint({required this.customers});
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: Radii.field,
        border: Border.all(color: const Color(0xFFF3D9A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: Space.xs),
              Expanded(child: Text(l10n.duplicateHintTitle, style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: Space.xs),
          for (final c in customers)
            InkWell(
              onTap: () => context.push(Routes.customer(c.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ReferencePill(c.reference),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text(
                        '${c.fullName} · ${Formatters.phone(c.primaryPhone)} · ${c.commune}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExtraAddressSheet extends StatefulWidget {
  const _ExtraAddressSheet({this.initial});
  final CustomerAddress? initial;

  @override
  State<_ExtraAddressSheet> createState() => _ExtraAddressSheetState();
}

class _ExtraAddressSheetState extends State<_ExtraAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.initial?.label ?? '');
  late final _address = TextEditingController(text: widget.initial?.address ?? '');
  late final _commune = TextEditingController(text: widget.initial?.commune ?? '');
  late final _wilaya = TextEditingController(text: widget.initial?.wilaya ?? '');
  late LatLng? _point = widget.initial?.point;

  @override
  void dispose() {
    _label.dispose();
    _address.dispose();
    _commune.dispose();
    _wilaya.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? err(FieldError? e) => fieldErrorText(context, e);
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.page, 0, Space.page, MediaQuery.viewInsetsOf(context).bottom + Space.page),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.extraAddressTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: Space.md),
              TextFormField(
                controller: _label,
                decoration: InputDecoration(labelText: '${l10n.fieldLabel} *', hintText: l10n.fieldLabelHint),
                validator: (v) => err(Validators.required(v, max: 60)),
              ),
              const SizedBox(height: Space.sm),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: '${l10n.fieldAddress} *'),
                validator: (v) => err(Validators.required(v, min: 3, max: 300)),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commune,
                      decoration: InputDecoration(labelText: l10n.fieldCommune),
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _wilaya,
                      decoration: InputDecoration(labelText: l10n.fieldWilaya),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await LocationPickerScreen.open(context, initial: _point, addressHint: _address.text);
                  if (picked != null) setState(() => _point = picked.point);
                },
                icon: Icon(_point == null ? Icons.add_location_alt_outlined : Icons.edit_location_alt_outlined),
                label: Text(
                  _point == null ? l10n.actionSetLocation : Formatters.coordinates(_point!.latitude, _point!.longitude),
                ),
              ),
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
                  Navigator.pop(
                    context,
                    CustomerAddress(
                      id: widget.initial?.id,
                      label: _label.text.trim(),
                      address: _address.text.trim(),
                      commune: opt(_commune),
                      wilaya: opt(_wilaya),
                      latitude: _point?.latitude,
                      longitude: _point?.longitude,
                    ),
                  );
                },
                child: Text(l10n.actionApply),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
