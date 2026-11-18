import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../data/models/customer.dart';
import '../../data/repositories/customer_repository.dart';
import '../../shared/widgets/feedback.dart';
import '../auth/auth_controller.dart';

/// Field actions on a customer (call, WhatsApp, navigation, copy). Employee
/// actions are recorded in the activity log, best effort.
class CustomerActions {
  CustomerActions(this.ref, this.context);
  final WidgetRef ref;
  final BuildContext context;

  void _log(CustomerAction action, Customer c) {
    if (!(ref.read(authControllerProvider).isAdmin)) {
      ref.read(customerRepositoryProvider).logAction(action, c.id);
    }
  }

  void _failed() => showToast(context, context.l10n.errorCannotOpenApp, kind: ToastKind.error);

  Future<void> call(Customer c, [String? phone]) async {
    _log(CustomerAction.called, c);
    if (!await ref.read(launcherProvider).call(phone ?? c.primaryPhone) && context.mounted) _failed();
  }

  Future<void> whatsapp(Customer c) async {
    final number = c.whatsappPhone;
    if (number == null) return;
    _log(CustomerAction.whatsapp, c);
    if (!await ref.read(launcherProvider).whatsapp(number) && context.mounted) _failed();
  }

  Future<void> navigate(Customer c, {CustomerAddress? address}) async {
    final lat = address?.latitude ?? c.latitude;
    final lng = address?.longitude ?? c.longitude;
    _log(CustomerAction.navigated, c);
    final launcher = ref.read(launcherProvider);
    final ok = (lat != null && lng != null)
        ? await launcher.directions(lat, lng)
        : await launcher.searchAddress(
            address == null ? '${c.address}, ${c.commune}, ${c.wilaya}' : '${address.address}, ${address.commune ?? ''}');
    if (!ok && context.mounted) _failed();
  }

  Future<void> copy(String value, String confirmation) async {
    await ref.read(launcherProvider).copy(value);
    if (context.mounted) showToast(context, confirmation, kind: ToastKind.success);
  }
}
