import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:outifor/core/router/app_router.dart';
import 'package:outifor/core/utils/validators.dart';
import 'package:outifor/data/models/profile.dart';
import 'package:outifor/data/repositories/auth_repository.dart';
import 'package:outifor/data/services/launcher_service.dart';
import 'package:outifor/features/auth/auth_controller.dart';
import 'package:outifor/features/employees/password_tools.dart';

Profile _profile(UserRole role) => Profile(
  id: 'p',
  fullName: 'Test User',
  username: 'test',
  role: role,
  isActive: true,
  createdAt: DateTime.utc(2026),
);

void main() {
  group('Validators', () {
    test('phones', () {
      expect(Validators.phone('0555 12 34 56'), isNull);
      expect(Validators.phone('+213 7 70 11 22 33'), isNull);
      expect(Validators.phone('021 54 32 10'), isNull);
      expect(Validators.phone('0855123456'), FieldError.invalidPhone);
      expect(Validators.phone('12'), FieldError.invalidPhone);
      expect(Validators.phone('abc'), FieldError.invalidPhone);
      expect(Validators.phone(''), FieldError.required);
      expect(Validators.phone('', isRequired: false), isNull);
    });

    test('usernames and passwords follow the Edge Function rules', () {
      expect(Validators.username('samir.benali'), isNull);
      expect(Validators.username('Sa'), FieldError.invalidUsername);
      expect(Validators.username('has space'), FieldError.invalidUsername);
      expect(Validators.password('abcdefgh'), FieldError.weakPassword);
      expect(Validators.password('abc12'), FieldError.weakPassword);
      expect(Validators.password('abcd1234'), isNull);
    });

    test('username suggestion', () {
      expect(Validators.suggestUsername('Samir Ben Ali'), 'samir.ali');
      expect(Validators.suggestUsername('Aïcha'), 'aicha');
      expect(Validators.suggestUsername(''), '');
    });

    test('coordinates', () {
      expect(Validators.coordinate('36,7538', min: -90, max: 90), isNull);
      expect(Validators.coordinate('95', min: -90, max: 90), FieldError.invalidNumber);
      expect(Validators.coordinate('x', min: -90, max: 90), FieldError.invalidNumber);
    });
  });

  test('avatar initials use letters only', () {
    Profile p(String name) => Profile(
      id: 'x',
      fullName: name,
      username: 'x',
      role: UserRole.employee,
      isActive: true,
      createdAt: DateTime.utc(2026),
    );
    expect(p('Ancien employé (démo)').initials, 'AD');
    expect(p('Samir').initials, 'S');
    expect(p('(  )').initials, '?');
    expect(p('محمد بن علي').initials, 'مع');
  });

  test('generated temporary passwords always pass validation', () {
    final rng = Random(42);
    for (var i = 0; i < 500; i++) {
      final p = generateTemporaryPassword(random: rng);
      expect(Validators.password(p), isNull, reason: p);
      expect(p, isNot(matches(RegExp('[0O1lI]'))));
    }
  });

  group('external links', () {
    test('WhatsApp uses the international format', () {
      expect(LauncherService.whatsappUri('0555123456').toString(), 'https://wa.me/213555123456');
    });
    test('navigation uses Google Maps directions to exact coordinates', () {
      final uri = LauncherService.directionsUri(36.7213, 3.1834);
      expect(uri.host, 'www.google.com');
      expect(uri.queryParameters['destination'], '36.7213,3.1834');
    });
    test('dialer', () => expect(LauncherService.callUri('0555123456').toString(), 'tel:0555123456'));
  });

  test('usernames map to Auth emails; full emails pass through', () {
    expect(AuthRepository.emailFor(' Samir.Benali '), 'samir.benali@outifor.local');
    expect(AuthRepository.emailFor('Admin@Company.dz'), 'admin@company.dz');
  });

  group('route guard', () {
    final employee = AuthState.signedIn(_profile(UserRole.employee));
    final admin = AuthState.signedIn(_profile(UserRole.admin));
    String? go(String loc, AuthState auth, {bool onboarded = true}) =>
        resolveRedirect(location: loc, auth: auth, onboardingDone: onboarded);

    test('signed out users only reach onboarding / login', () {
      expect(go('/dashboard', const AuthState.signedOut(), onboarded: false), Routes.onboarding);
      expect(go('/customer/1', const AuthState.signedOut()), Routes.login);
      expect(go(Routes.login, const AuthState.signedOut()), isNull);
    });

    test('the intro animation plays to the end before any other screen', () {
      expect(
        resolveRedirect(location: '/login', auth: const AuthState.signedOut(), onboardingDone: true, splashDone: false),
        Routes.splash,
      );
      expect(
        resolveRedirect(location: '/home', auth: employee, onboardingDone: true, splashDone: false),
        Routes.splash,
      );
      expect(resolveRedirect(location: Routes.splash, auth: employee, onboardingDone: true), Routes.home);
    });

    test('while restoring the session, only the splash is shown', () {
      expect(go('/home', const AuthState.initializing()), Routes.splash);
    });

    test('employees cannot open admin screens', () {
      for (final loc in [
        '/dashboard',
        '/customers',
        '/employees',
        '/employee/x',
        '/employee-new',
        '/customer-new',
        '/customer/abc/edit',
        '/duplicates',
        '/activity',
        '/app-settings',
        '/settings',
        '/map',
      ]) {
        expect(go(loc, employee), Routes.home, reason: loc);
      }
    });

    test('employees reach their screens and customer profiles', () {
      for (final loc in [
        '/home',
        '/directory',
        '/explore',
        '/me',
        '/customer/abc',
        '/customer/abc/location',
        '/search',
      ]) {
        expect(go(loc, employee), isNull, reason: loc);
      }
    });

    test('admins land on the dashboard and reach admin screens', () {
      expect(go(Routes.login, admin), Routes.dashboard);
      expect(go('/home', admin), Routes.dashboard);
      expect(go('/customer/abc/edit', admin), isNull);
      expect(go('/employees', admin), isNull);
    });
  });
}
