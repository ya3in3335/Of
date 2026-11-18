import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/activity.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';
import '../maps/location_picker_screen.dart';
import '../maps/map_widgets.dart';
import 'app_settings_controller.dart';

/// Company-wide settings (admin only; RLS rejects updates from employees).
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  LatLng? _center;
  double _zoom = 11;
  bool _initialised = false;

  @override
  void dispose() {
    _company.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _center == null) return;
    final l10n = context.l10n;
    try {
      await ref
          .read(appSettingsProvider.notifier)
          .save(
            AppSettings(
              companyName: _company.text.trim(),
              defaultLatitude: _center!.latitude,
              defaultLongitude: _center!.longitude,
              defaultZoom: _zoom,
            ),
          );
      if (!mounted) return;
      showToast(context, l10n.settingsSaved, kind: ToastKind.success);
      context.pop();
    } catch (e) {
      if (mounted) showErrorToast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsApp)),
      body: settings.when(
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(appSettingsProvider)),
        data: (s) {
          if (!_initialised) {
            _initialised = true;
            _company.text = s.companyName;
            _center = LatLng(s.defaultLatitude, s.defaultLongitude);
            _zoom = s.defaultZoom;
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxl),
              children: [
                SectionCard(
                  title: l10n.settingsCompany,
                  child: TextFormField(
                    controller: _company,
                    decoration: InputDecoration(
                      labelText: l10n.fieldCompanyName,
                      prefixIcon: const Icon(Icons.business_rounded),
                    ),
                    validator: (v) => fieldErrorText(context, Validators.required(v, min: 2, max: 80)),
                  ),
                ),
                const SizedBox(height: Space.md),
                SectionCard(
                  title: l10n.settingsMapCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.settingsMapCenterHint, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: Space.sm),
                      if (_center != null) MiniMapPreview(point: _center!, height: 150),
                      const SizedBox(height: Space.xs),
                      if (_center != null)
                        Text(
                          Formatters.coordinates(_center!.latitude, _center!.longitude),
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      const SizedBox(height: Space.xs),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await LocationPickerScreen.open(context, initial: _center);
                          if (picked != null) setState(() => _center = picked.point);
                        },
                        icon: const Icon(Icons.edit_location_alt_outlined),
                        label: Text(l10n.actionChange),
                      ),
                      const SizedBox(height: Space.sm),
                      Text(l10n.settingsMapZoom(_zoom.round()), style: Theme.of(context).textTheme.labelMedium),
                      Slider(
                        value: _zoom,
                        min: 5,
                        max: 16,
                        divisions: 11,
                        label: '${_zoom.round()}',
                        onChanged: (v) => setState(() => _zoom = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xl),
                AsyncButton(label: l10n.actionSaveChanges, icon: Icons.check_rounded, onPressed: _save),
              ],
            ),
          );
        },
      ),
    );
  }
}
