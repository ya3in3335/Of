import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OUTIFOR'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Securing your session…'**
  String get splashLoading;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @demoRibbon.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get demoRibbon;

  /// No description provided for @demoLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo version — sample data'**
  String get demoLoginTitle;

  /// No description provided for @demoLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent to a server; data resets when the app restarts. Tap an account to fill it in:'**
  String get demoLoginBody;

  /// No description provided for @demoAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get demoAdmin;

  /// No description provided for @demoEmployee.
  ///
  /// In en, this message translates to:
  /// **'Delivery employee'**
  String get demoEmployee;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navDashboard;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get navEmployees;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing the copy saved on this phone'**
  String get offlineBanner;

  /// No description provided for @actionActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get actionActivate;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get actionCall;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionCopyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get actionCopyAll;

  /// No description provided for @actionCopyPhone.
  ///
  /// In en, this message translates to:
  /// **'Copy phone'**
  String get actionCopyPhone;

  /// No description provided for @actionCopyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference'**
  String get actionCopyReference;

  /// No description provided for @actionCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get actionCreateAccount;

  /// No description provided for @actionCreateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create customer'**
  String get actionCreateCustomer;

  /// No description provided for @actionDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get actionDeactivate;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get actionGenerate;

  /// No description provided for @actionHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get actionHidePassword;

  /// No description provided for @actionShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get actionShowPassword;

  /// No description provided for @actionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get actionNavigate;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get actionOpenInMaps;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get actionOpenSettings;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// No description provided for @actionSearchAddressInMaps.
  ///
  /// In en, this message translates to:
  /// **'Search address in Google Maps'**
  String get actionSearchAddressInMaps;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location on map'**
  String get actionSetLocation;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionStartNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start navigation'**
  String get actionStartNavigation;

  /// No description provided for @actionViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get actionViewProfile;

  /// No description provided for @actionWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get actionWhatsapp;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'From invoice to customer in seconds'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Type the name printed on the invoice. Partial names, references and phone numbers all work.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Exact delivery locations'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'See each shop on the map and start Google Maps navigation with one tap.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Secure and always up to date'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Accounts are created by your manager. Changes reach every phone automatically.'**
  String get onboarding3Body;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the OUTIFOR customer directory'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginNoSignup.
  ///
  /// In en, this message translates to:
  /// **'Accounts are created by your administrator.'**
  String get loginNoSignup;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorOffline;

  /// No description provided for @errorOfflineSave.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Nothing was saved — try again when the connection is back.'**
  String get errorOfflineSave;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer. Try again.'**
  String get errorTimeout;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is deactivated. Contact your administrator.'**
  String get errorAccountDisabled;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this record. Reload and try again.'**
  String get errorConflict;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already in use.'**
  String get errorUsernameTaken;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password too weak: at least 8 characters with letters and digits.'**
  String get errorWeakPassword;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Some information is invalid. Check the form.'**
  String get errorValidation;

  /// No description provided for @errorNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'The server is not fully configured. Contact your administrator.'**
  String get errorNotConfigured;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @errorCannotOpenApp.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this.'**
  String get errorCannotOpenApp;

  /// No description provided for @stateOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get stateOfflineTitle;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load'**
  String get stateErrorTitle;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get validationTooShort;

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get validationTooLong;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid number (e.g. 0555 12 34 56)'**
  String get validationPhone;

  /// No description provided for @validationUsername.
  ///
  /// In en, this message translates to:
  /// **'3–32 characters: lowercase letters, digits, . _ -'**
  String get validationUsername;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters, with letters and digits'**
  String get validationPassword;

  /// No description provided for @validationMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationMismatch;

  /// No description provided for @validationNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get validationNumber;

  /// No description provided for @validationSamePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get validationSamePassword;

  /// No description provided for @formFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Please correct the highlighted fields.'**
  String get formFixErrors;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// No description provided for @syncDone.
  ///
  /// In en, this message translates to:
  /// **'Synced at {time}'**
  String syncDone(String time);

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline · data from {time}'**
  String syncOffline(String time);

  /// No description provided for @syncOfflineNoData.
  ///
  /// In en, this message translates to:
  /// **'Offline · not synced yet'**
  String get syncOfflineNoData;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed · tap to retry'**
  String get syncError;

  /// No description provided for @syncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncNever;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Directory is up to date'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Your changes are not affected; try again later.'**
  String get syncFailed;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeDaysAgo(int count);

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String distanceMeters(int meters);

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a customer'**
  String get homeTitle;

  /// No description provided for @homeCustomersAvailable.
  ///
  /// In en, this message translates to:
  /// **'customers in the directory'**
  String get homeCustomersAvailable;

  /// No description provided for @homeWithLocation.
  ///
  /// In en, this message translates to:
  /// **'with GPS location'**
  String get homeWithLocation;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Name on invoice, phone or OUT-reference'**
  String get searchHint;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 customer found} other{{count} customers found}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchMultipleHint.
  ///
  /// In en, this message translates to:
  /// **'Several customers match. Check the phone number and city before opening.'**
  String get searchMultipleHint;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No customer found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, try only the last name, or search by phone number.'**
  String get searchNoResultsBody;

  /// No description provided for @searchOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'You are offline: customers added since the last sync are not on this phone yet.'**
  String get searchOfflineNote;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get searchRecent;

  /// No description provided for @searchTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'You can search by'**
  String get searchTipsTitle;

  /// No description provided for @searchTipName.
  ///
  /// In en, this message translates to:
  /// **'Name (first, last or part of it)'**
  String get searchTipName;

  /// No description provided for @searchTipReference.
  ///
  /// In en, this message translates to:
  /// **'Customer reference'**
  String get searchTipReference;

  /// No description provided for @searchTipPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get searchTipPhone;

  /// No description provided for @directoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No customers} =1{1 customer} other{{count} customers}}'**
  String directoryCount(int count);

  /// No description provided for @directoryFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by name, phone, reference…'**
  String get directoryFilterHint;

  /// No description provided for @directoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get directoryEmptyTitle;

  /// No description provided for @directoryEmptyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer to start building the directory.'**
  String get directoryEmptyAdmin;

  /// No description provided for @directoryEmptyEmployee.
  ///
  /// In en, this message translates to:
  /// **'Customers added by your administrator will appear here.'**
  String get directoryEmptyEmployee;

  /// No description provided for @directoryNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get directoryNoMatchTitle;

  /// No description provided for @directoryNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'No customer matches these filters.'**
  String get directoryNoMatchBody;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterAllWilayas.
  ///
  /// In en, this message translates to:
  /// **'All wilayas'**
  String get filterAllWilayas;

  /// No description provided for @filterNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No GPS location'**
  String get filterNoLocation;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get filterReset;

  /// No description provided for @filterWilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get filterWilaya;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTitle;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortName;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortUpdated;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @statusArchivedPlural.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchivedPlural;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @customerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerProfileTitle;

  /// No description provided for @customerNew.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get customerNew;

  /// No description provided for @customerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get customerEditTitle;

  /// No description provided for @customerLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get customerLocation;

  /// No description provided for @customerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get customerContact;

  /// No description provided for @customerOtherAddresses.
  ///
  /// In en, this message translates to:
  /// **'Other delivery addresses'**
  String get customerOtherAddresses;

  /// No description provided for @customerRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get customerRecord;

  /// No description provided for @customerNoWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'No WhatsApp number registered.'**
  String get customerNoWhatsapp;

  /// No description provided for @customerNoLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'No GPS location recorded'**
  String get customerNoLocationTitle;

  /// No description provided for @customerNoLocationShort.
  ///
  /// In en, this message translates to:
  /// **'No GPS location'**
  String get customerNoLocationShort;

  /// No description provided for @customerNoLocationAdmin.
  ///
  /// In en, this message translates to:
  /// **'Place this customer on the map so drivers can navigate to them.'**
  String get customerNoLocationAdmin;

  /// No description provided for @customerNoLocationEmployee.
  ///
  /// In en, this message translates to:
  /// **'Use the written address, or call the customer for directions.'**
  String get customerNoLocationEmployee;

  /// No description provided for @customerNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer not found'**
  String get customerNotFoundTitle;

  /// No description provided for @customerNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This customer may have been deleted.'**
  String get customerNotFoundBody;

  /// No description provided for @customerArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive this customer?'**
  String get customerArchiveTitle;

  /// No description provided for @customerArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be hidden from employees’ searches. You can restore them at any time.'**
  String customerArchiveBody(String name);

  /// No description provided for @customerRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this customer?'**
  String get customerRestoreTitle;

  /// No description provided for @customerRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be visible to employees again.'**
  String customerRestoreBody(String name);

  /// No description provided for @customerArchived.
  ///
  /// In en, this message translates to:
  /// **'Customer archived'**
  String get customerArchived;

  /// No description provided for @customerRestored.
  ///
  /// In en, this message translates to:
  /// **'Customer restored'**
  String get customerRestored;

  /// No description provided for @customerDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get customerDeleteTitle;

  /// No description provided for @customerDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} ({reference}) and their addresses will be deleted for everyone. This cannot be undone. Consider archiving instead.'**
  String customerDeleteBody(String name, String reference);

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get customerDeleted;

  /// No description provided for @customerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer {reference} created'**
  String customerCreated(String reference);

  /// No description provided for @customerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get customerUpdated;

  /// No description provided for @copiedPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied'**
  String get copiedPhone;

  /// No description provided for @copiedReference.
  ///
  /// In en, this message translates to:
  /// **'Reference copied'**
  String get copiedReference;

  /// No description provided for @copiedAddress.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get copiedAddress;

  /// No description provided for @copiedCredentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials copied'**
  String get copiedCredentials;

  /// No description provided for @adminNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes.'**
  String get adminNotesEmpty;

  /// No description provided for @adminNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Visible to administrators only.'**
  String get adminNotesHint;

  /// No description provided for @adminNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Payment habits, opening hours, access instructions…'**
  String get adminNotesPlaceholder;

  /// No description provided for @fieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get fieldLastName;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Shop / business name'**
  String get fieldBusinessName;

  /// No description provided for @fieldPrimaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Primary phone'**
  String get fieldPrimaryPhone;

  /// No description provided for @fieldSecondaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Secondary phone'**
  String get fieldSecondaryPhone;

  /// No description provided for @fieldWhatsappPhone.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get fieldWhatsappPhone;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldWilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get fieldWilaya;

  /// No description provided for @fieldCommune.
  ///
  /// In en, this message translates to:
  /// **'Commune'**
  String get fieldCommune;

  /// No description provided for @fieldWilayaCommune.
  ///
  /// In en, this message translates to:
  /// **'Commune — Wilaya'**
  String get fieldWilayaCommune;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed address'**
  String get fieldAddress;

  /// No description provided for @fieldAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building, landmark…'**
  String get fieldAddressHint;

  /// No description provided for @fieldAdminNotes.
  ///
  /// In en, this message translates to:
  /// **'Administrator notes'**
  String get fieldAdminNotes;

  /// No description provided for @fieldCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get fieldCreatedAt;

  /// No description provided for @fieldUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get fieldUpdatedAt;

  /// No description provided for @fieldLastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login'**
  String get fieldLastLogin;

  /// No description provided for @fieldLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get fieldLatitude;

  /// No description provided for @fieldLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get fieldLongitude;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get fieldLabel;

  /// No description provided for @fieldLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Depot, Second shop'**
  String get fieldLabelHint;

  /// No description provided for @fieldCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get fieldCompanyName;

  /// No description provided for @fieldCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get fieldCurrentPassword;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPassword;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get fieldConfirmPassword;

  /// No description provided for @formIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get formIdentity;

  /// No description provided for @formAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get formAddress;

  /// No description provided for @formWhatsappSame.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp on the primary number'**
  String get formWhatsappSame;

  /// No description provided for @formWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'Only enter a WhatsApp number the customer actually uses on WhatsApp.'**
  String get formWhatsappHint;

  /// No description provided for @formNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location yet. Without it, drivers only have the written address.'**
  String get formNoLocation;

  /// No description provided for @formNoExtraAddresses.
  ///
  /// In en, this message translates to:
  /// **'No other address.'**
  String get formNoExtraAddresses;

  /// No description provided for @formStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active customer'**
  String get formStatusActive;

  /// No description provided for @formStatusActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Visible to employees.'**
  String get formStatusActiveHint;

  /// No description provided for @formStatusArchivedHint.
  ///
  /// In en, this message translates to:
  /// **'Archived: hidden from employees.'**
  String get formStatusArchivedHint;

  /// No description provided for @extraAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get extraAddressTitle;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes have not been saved.'**
  String get discardBody;

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Modified elsewhere'**
  String get conflictTitle;

  /// No description provided for @conflictBody.
  ///
  /// In en, this message translates to:
  /// **'Another administrator saved this customer while you were editing. The latest version has been loaded; please re-apply your changes.'**
  String get conflictBody;

  /// No description provided for @duplicateHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible existing customer'**
  String get duplicateHintTitle;

  /// No description provided for @duplicatesFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicates'**
  String get duplicatesFoundTitle;

  /// No description provided for @duplicatesFoundBody.
  ///
  /// In en, this message translates to:
  /// **'These customers have the same phone number or a very similar name. Check before creating a new record.'**
  String get duplicatesFoundBody;

  /// No description provided for @duplicatesReview.
  ///
  /// In en, this message translates to:
  /// **'Go back and check'**
  String get duplicatesReview;

  /// No description provided for @duplicatesSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'It is a different customer — save'**
  String get duplicatesSaveAnyway;

  /// No description provided for @duplicateSamePhone.
  ///
  /// In en, this message translates to:
  /// **'Same phone'**
  String get duplicateSamePhone;

  /// No description provided for @duplicateSimilarName.
  ///
  /// In en, this message translates to:
  /// **'Similar name'**
  String get duplicateSimilarName;

  /// No description provided for @duplicateScore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String duplicateScore(int percent);

  /// No description provided for @duplicatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate review'**
  String get duplicatesTitle;

  /// No description provided for @duplicatesShort.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get duplicatesShort;

  /// No description provided for @duplicatesIntro.
  ///
  /// In en, this message translates to:
  /// **'Records are never merged automatically. Open both, then archive or delete the wrong one, or mark the pair as different customers.'**
  String get duplicatesIntro;

  /// No description provided for @duplicatesNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No duplicates detected'**
  String get duplicatesNoneTitle;

  /// No description provided for @duplicatesNoneBody.
  ///
  /// In en, this message translates to:
  /// **'No customers share a phone number or a near-identical name.'**
  String get duplicatesNoneBody;

  /// No description provided for @duplicatesDismiss.
  ///
  /// In en, this message translates to:
  /// **'Different customers'**
  String get duplicatesDismiss;

  /// No description provided for @duplicatesDismissed.
  ///
  /// In en, this message translates to:
  /// **'Pair marked as different customers'**
  String get duplicatesDismissed;

  /// No description provided for @mapOpenFull.
  ///
  /// In en, this message translates to:
  /// **'Full map'**
  String get mapOpenFull;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapRecenter.
  ///
  /// In en, this message translates to:
  /// **'Center on customer'**
  String get mapRecenter;

  /// No description provided for @mapShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all customers'**
  String get mapShowAll;

  /// No description provided for @mapDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away (straight line)'**
  String mapDistanceAway(String distance);

  /// No description provided for @mapLocatedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} on map'**
  String mapLocatedCount(int count);

  /// No description provided for @mapMissingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} without GPS'**
  String mapMissingCount(int count);

  /// No description provided for @mapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No customer has a GPS location yet'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Open a customer and use “Set location on map”.'**
  String get mapEmptyAdmin;

  /// No description provided for @mapEmptyEmployee.
  ///
  /// In en, this message translates to:
  /// **'Locations added by your administrator will appear here.'**
  String get mapEmptyEmployee;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this phone.'**
  String get locationServiceDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was refused.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in the app settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not get a GPS fix. Move outdoors and try again.'**
  String get locationTimeout;

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer location'**
  String get pickerTitle;

  /// No description provided for @pickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search an address or place'**
  String get pickerSearchHint;

  /// No description provided for @pickerNoAddressFound.
  ///
  /// In en, this message translates to:
  /// **'No address found. Move the map manually.'**
  String get pickerNoAddressFound;

  /// No description provided for @pickerSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Address search unavailable. Check the connection or move the map manually.'**
  String get pickerSearchFailed;

  /// No description provided for @pickerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Move the map or tap to place the pin on the shop entrance.'**
  String get pickerInstructions;

  /// No description provided for @pickerUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current position'**
  String get pickerUseMyLocation;

  /// No description provided for @pickerManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get pickerManualTitle;

  /// No description provided for @pickerManualHint.
  ///
  /// In en, this message translates to:
  /// **'Decimal degrees, e.g. 36.753800 and 3.058800'**
  String get pickerManualHint;

  /// No description provided for @pickerMoveFirst.
  ///
  /// In en, this message translates to:
  /// **'Place the pin first: move the map, tap it, or search an address.'**
  String get pickerMoveFirst;

  /// No description provided for @pickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm this location'**
  String get pickerConfirm;

  /// No description provided for @pickerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the location'**
  String get pickerConfirmTitle;

  /// No description provided for @pickerConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Drivers will be guided to exactly this point.'**
  String get pickerConfirmBody;

  /// No description provided for @pickerUseThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get pickerUseThisLocation;

  /// No description provided for @pickerAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get pickerAdjust;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardDirectory.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get dashboardDirectory;

  /// No description provided for @dashboardRecentCustomers.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get dashboardRecentCustomers;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashboardRecentActivity;

  /// No description provided for @statTotalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get statTotalCustomers;

  /// No description provided for @statActiveCustomers.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActiveCustomers;

  /// No description provided for @statEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get statEmployees;

  /// No description provided for @statAdded30Days.
  ///
  /// In en, this message translates to:
  /// **'Added in 30 days'**
  String get statAdded30Days;

  /// No description provided for @statAddedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+{count} this week'**
  String statAddedThisWeek(int count);

  /// No description provided for @statArchived.
  ///
  /// In en, this message translates to:
  /// **'{count} archived'**
  String statArchived(int count);

  /// No description provided for @statEmployeesActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String statEmployeesActive(int count);

  /// No description provided for @statMissingLocation.
  ///
  /// In en, this message translates to:
  /// **'{count} without GPS'**
  String statMissingLocation(int count);

  /// No description provided for @statAllLocated.
  ///
  /// In en, this message translates to:
  /// **'All located'**
  String get statAllLocated;

  /// No description provided for @employeeNew.
  ///
  /// In en, this message translates to:
  /// **'New employee'**
  String get employeeNew;

  /// No description provided for @employeesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get employeesSearchHint;

  /// No description provided for @employeesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get employeesEmptyTitle;

  /// No description provided for @employeesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create an account for each delivery employee.'**
  String get employeesEmptyBody;

  /// No description provided for @employeeNeverLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Never logged in'**
  String get employeeNeverLoggedIn;

  /// No description provided for @employeeLastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login {when}'**
  String employeeLastLogin(String when);

  /// No description provided for @employeeIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get employeeIdentity;

  /// No description provided for @employeeRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get employeeRole;

  /// No description provided for @employeeTempPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get employeeTempPassword;

  /// No description provided for @usernameHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to sign in. Lowercase, no spaces.'**
  String get usernameHelper;

  /// No description provided for @passwordRules.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with letters and digits. Share it privately; the employee can change it in Account settings.'**
  String get passwordRules;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Delivery employee'**
  String get roleEmployee;

  /// No description provided for @roleAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Full access: customers, employees, settings.'**
  String get roleAdminHint;

  /// No description provided for @roleEmployeeHint.
  ///
  /// In en, this message translates to:
  /// **'Search and view customers, call, navigate. Cannot modify data.'**
  String get roleEmployeeHint;

  /// No description provided for @employeeAdminConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an administrator?'**
  String get employeeAdminConfirmTitle;

  /// No description provided for @employeeAdminConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This person will be able to modify and delete customers and manage all accounts.'**
  String get employeeAdminConfirmBody;

  /// No description provided for @employeeCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get employeeCreated;

  /// No description provided for @credentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in details'**
  String get credentialsTitle;

  /// No description provided for @credentialsBody.
  ///
  /// In en, this message translates to:
  /// **'Give these to the employee now. The password will not be shown again.'**
  String get credentialsBody;

  /// No description provided for @employeeDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employeeDetailsTitle;

  /// No description provided for @employeeAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get employeeAccount;

  /// No description provided for @employeeManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get employeeManage;

  /// No description provided for @employeeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit name and role'**
  String get employeeEditTitle;

  /// No description provided for @employeeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get employeeUpdated;

  /// No description provided for @employeeResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get employeeResetTitle;

  /// No description provided for @employeeResetHint.
  ///
  /// In en, this message translates to:
  /// **'Sets a new temporary password.'**
  String get employeeResetHint;

  /// No description provided for @employeeResetBody.
  ///
  /// In en, this message translates to:
  /// **'Set a new password for {name}. Their current password stops working immediately.'**
  String employeeResetBody(String name);

  /// No description provided for @employeeDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate this account?'**
  String get employeeDeactivateTitle;

  /// No description provided for @employeeDeactivateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will immediately lose access to customer data on every device.'**
  String employeeDeactivateBody(String name);

  /// No description provided for @employeeDeactivateHint.
  ///
  /// In en, this message translates to:
  /// **'Blocks access immediately.'**
  String get employeeDeactivateHint;

  /// No description provided for @employeeActivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate this account?'**
  String get employeeActivateTitle;

  /// No description provided for @employeeActivateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be able to sign in again.'**
  String employeeActivateBody(String name);

  /// No description provided for @employeeActivateHint.
  ///
  /// In en, this message translates to:
  /// **'Restores access.'**
  String get employeeActivateHint;

  /// No description provided for @employeeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Account deactivated'**
  String get employeeDeactivated;

  /// No description provided for @employeeActivated.
  ///
  /// In en, this message translates to:
  /// **'Account activated'**
  String get employeeActivated;

  /// No description provided for @employeeSelfHint.
  ///
  /// In en, this message translates to:
  /// **'You cannot deactivate your own account.'**
  String get employeeSelfHint;

  /// No description provided for @employeeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get employeeRecentActivity;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityEmpty;

  /// No description provided for @activityFilterAdmin.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get activityFilterAdmin;

  /// No description provided for @activityFilterField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get activityFilterField;

  /// No description provided for @activitySystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get activitySystem;

  /// No description provided for @logCustomerCreated.
  ///
  /// In en, this message translates to:
  /// **'Created customer {name}'**
  String logCustomerCreated(String name);

  /// No description provided for @logCustomerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {name}'**
  String logCustomerUpdated(String name);

  /// No description provided for @logCustomerLocation.
  ///
  /// In en, this message translates to:
  /// **'Moved location of {name}'**
  String logCustomerLocation(String name);

  /// No description provided for @logCustomerArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived {name}'**
  String logCustomerArchived(String name);

  /// No description provided for @logCustomerRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored {name}'**
  String logCustomerRestored(String name);

  /// No description provided for @logCustomerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String logCustomerDeleted(String name);

  /// No description provided for @logCustomerViewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed {name}'**
  String logCustomerViewed(String name);

  /// No description provided for @logCustomerCalled.
  ///
  /// In en, this message translates to:
  /// **'Called {name}'**
  String logCustomerCalled(String name);

  /// No description provided for @logCustomerWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Opened WhatsApp with {name}'**
  String logCustomerWhatsapp(String name);

  /// No description provided for @logCustomerNavigated.
  ///
  /// In en, this message translates to:
  /// **'Started navigation to {name}'**
  String logCustomerNavigated(String name);

  /// No description provided for @logEmployeeCreated.
  ///
  /// In en, this message translates to:
  /// **'Created account for {name}'**
  String logEmployeeCreated(String name);

  /// No description provided for @logEmployeeActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated {name}'**
  String logEmployeeActivated(String name);

  /// No description provided for @logEmployeeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated {name}'**
  String logEmployeeDeactivated(String name);

  /// No description provided for @logEmployeePassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password of {name}'**
  String logEmployeePassword(String name);

  /// No description provided for @logEmployeeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated account of {name}'**
  String logEmployeeUpdated(String name);

  /// No description provided for @logDuplicateDismissed.
  ///
  /// In en, this message translates to:
  /// **'Marked two customers as different'**
  String get logDuplicateDismissed;

  /// No description provided for @logSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated company settings'**
  String get logSettingsUpdated;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsIntro.
  ///
  /// In en, this message translates to:
  /// **'Directory changes received on this phone.'**
  String get notificationsIntro;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New customers and location changes will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notifCreated.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get notifCreated;

  /// No description provided for @notifUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated'**
  String get notifUpdated;

  /// No description provided for @notifLocation.
  ///
  /// In en, this message translates to:
  /// **'Location changed'**
  String get notifLocation;

  /// No description provided for @notifArchived.
  ///
  /// In en, this message translates to:
  /// **'Customer archived'**
  String get notifArchived;

  /// No description provided for @notifRestored.
  ///
  /// In en, this message translates to:
  /// **'Customer restored'**
  String get notifRestored;

  /// No description provided for @notifDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get notifDeleted;

  /// No description provided for @settingsAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountGroup;

  /// No description provided for @settingsAdminGroup.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get settingsAdminGroup;

  /// No description provided for @settingsDataGroup.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataGroup;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account & password'**
  String get settingsAccount;

  /// No description provided for @settingsAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountInfo;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'Company settings'**
  String get settingsApp;

  /// No description provided for @settingsCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get settingsCompany;

  /// No description provided for @settingsMapCenter.
  ///
  /// In en, this message translates to:
  /// **'Default map area'**
  String get settingsMapCenter;

  /// No description provided for @settingsMapCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Where maps open when no customer is selected.'**
  String get settingsMapCenterHint;

  /// No description provided for @settingsMapZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom level: {zoom}'**
  String settingsMapZoom(int zoom);

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileSaved;

  /// No description provided for @profileRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Your role and username can only be changed by an administrator.'**
  String get profileRoleHint;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystem;

  /// No description provided for @languageSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Follows the phone settings'**
  String get languageSystemHint;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'Customer names are always shown as they were entered.'**
  String get languageNote;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'The customer data saved on this phone will be erased.'**
  String get signOutBody;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
