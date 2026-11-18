// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OUTIFOR';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get splashLoading => 'Securing your session…';

  @override
  String get loading => 'Loading…';

  @override
  String get demoRibbon => 'DEMO';

  @override
  String get demoLoginTitle => 'Demo version — sample data';

  @override
  String get demoLoginBody =>
      'Nothing is sent to a server; data resets when the app restarts. Tap an account to fill it in:';

  @override
  String get demoAdmin => 'Administrator';

  @override
  String get demoEmployee => 'Delivery employee';

  @override
  String get navDashboard => 'Home';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navEmployees => 'Employees';

  @override
  String get navMap => 'Map';

  @override
  String get navSettings => 'Settings';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String get offlineBanner => 'Offline — showing the copy saved on this phone';

  @override
  String get actionActivate => 'Activate';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionBack => 'Back';

  @override
  String get actionCall => 'Call';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionChange => 'Change';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCopyAll => 'Copy all';

  @override
  String get actionCopyPhone => 'Copy phone';

  @override
  String get actionCopyReference => 'Copy reference';

  @override
  String get actionCreateAccount => 'Create account';

  @override
  String get actionCreateCustomer => 'Create customer';

  @override
  String get actionDeactivate => 'Deactivate';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionDone => 'Done';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionGenerate => 'Generate';

  @override
  String get actionHidePassword => 'Hide password';

  @override
  String get actionShowPassword => 'Show password';

  @override
  String get actionNavigate => 'Route';

  @override
  String get actionNext => 'Next';

  @override
  String get actionOk => 'OK';

  @override
  String get actionOpenInMaps => 'Open in Maps';

  @override
  String get actionOpenSettings => 'Settings';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get actionSearchAddressInMaps => 'Search address in Google Maps';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionSetLocation => 'Set location on map';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionStartNavigation => 'Start navigation';

  @override
  String get actionViewProfile => 'View profile';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get onboarding1Title => 'From invoice to customer in seconds';

  @override
  String get onboarding1Body =>
      'Type the name printed on the invoice. Partial names, references and phone numbers all work.';

  @override
  String get onboarding2Title => 'Exact delivery locations';

  @override
  String get onboarding2Body =>
      'See each shop on the map and start Google Maps navigation with one tap.';

  @override
  String get onboarding3Title => 'Secure and always up to date';

  @override
  String get onboarding3Body =>
      'Accounts are created by your manager. Changes reach every phone automatically.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to the OUTIFOR customer directory';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginNoSignup => 'Accounts are created by your administrator.';

  @override
  String get errorOffline =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorOfflineSave =>
      'You are offline. Nothing was saved — try again when the connection is back.';

  @override
  String get errorTimeout => 'The server took too long to answer. Try again.';

  @override
  String get errorInvalidCredentials => 'Incorrect username or password.';

  @override
  String get errorAccountDisabled =>
      'This account is deactivated. Contact your administrator.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorForbidden => 'You do not have permission for this action.';

  @override
  String get errorNotFound => 'This item no longer exists.';

  @override
  String get errorConflict =>
      'Someone else changed this record. Reload and try again.';

  @override
  String get errorUsernameTaken => 'This username is already in use.';

  @override
  String get errorWeakPassword =>
      'Password too weak: at least 8 characters with letters and digits.';

  @override
  String get errorValidation => 'Some information is invalid. Check the form.';

  @override
  String get errorNotConfigured =>
      'The server is not fully configured. Contact your administrator.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorCannotOpenApp => 'No app on this phone can open this.';

  @override
  String get stateOfflineTitle => 'You\'re offline';

  @override
  String get stateErrorTitle => 'Couldn\'t load';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationTooShort => 'Too short';

  @override
  String get validationTooLong => 'Too long';

  @override
  String get validationPhone => 'Invalid number (e.g. 0555 12 34 56)';

  @override
  String get validationUsername =>
      '3–32 characters: lowercase letters, digits, . _ -';

  @override
  String get validationPassword =>
      'At least 8 characters, with letters and digits';

  @override
  String get validationMismatch => 'Passwords do not match';

  @override
  String get validationNumber => 'Invalid value';

  @override
  String get validationSamePassword => 'Choose a different password';

  @override
  String get formFixErrors => 'Please correct the highlighted fields.';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String syncDone(String time) {
    return 'Synced at $time';
  }

  @override
  String syncOffline(String time) {
    return 'Offline · data from $time';
  }

  @override
  String get syncOfflineNoData => 'Offline · not synced yet';

  @override
  String get syncError => 'Sync failed · tap to retry';

  @override
  String get syncNever => 'Not synced yet';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncCompleted => 'Directory is up to date';

  @override
  String get syncFailed =>
      'Sync failed. Your changes are not affected; try again later.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get timeYesterday => 'yesterday';

  @override
  String timeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters m';
  }

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String homeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get homeTitle => 'Find a customer';

  @override
  String get homeCustomersAvailable => 'customers in the directory';

  @override
  String get homeWithLocation => 'with GPS location';

  @override
  String get searchTitle => 'Search customers';

  @override
  String get searchHint => 'Name on invoice, phone or OUT-reference';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers found',
      one: '1 customer found',
    );
    return '$_temp0';
  }

  @override
  String get searchMultipleHint =>
      'Several customers match. Check the phone number and city before opening.';

  @override
  String get searchNoResultsTitle => 'No customer found';

  @override
  String get searchNoResultsBody =>
      'Check the spelling, try only the last name, or search by phone number.';

  @override
  String get searchOfflineNote =>
      'You are offline: customers added since the last sync are not on this phone yet.';

  @override
  String get searchRecent => 'Recently opened';

  @override
  String get searchTipsTitle => 'You can search by';

  @override
  String get searchTipName => 'Name (first, last or part of it)';

  @override
  String get searchTipReference => 'Customer reference';

  @override
  String get searchTipPhone => 'Phone number';

  @override
  String directoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count customers',
      one: '1 customer',
      zero: 'No customers',
    );
    return '$_temp0';
  }

  @override
  String get directoryFilterHint => 'Filter by name, phone, reference…';

  @override
  String get directoryEmptyTitle => 'No customers yet';

  @override
  String get directoryEmptyAdmin =>
      'Add your first customer to start building the directory.';

  @override
  String get directoryEmptyEmployee =>
      'Customers added by your administrator will appear here.';

  @override
  String get directoryNoMatchTitle => 'No match';

  @override
  String get directoryNoMatchBody => 'No customer matches these filters.';

  @override
  String get filterAll => 'All';

  @override
  String get filterAllWilayas => 'All wilayas';

  @override
  String get filterNoLocation => 'No GPS location';

  @override
  String get filterReset => 'Reset filters';

  @override
  String get filterWilaya => 'Wilaya';

  @override
  String get sortTitle => 'Sort';

  @override
  String get sortName => 'Name A–Z';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortUpdated => 'Recently updated';

  @override
  String get statusActive => 'Active';

  @override
  String get statusArchived => 'Archived';

  @override
  String get statusArchivedPlural => 'Archived';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get customerProfileTitle => 'Customer';

  @override
  String get customerNew => 'New customer';

  @override
  String get customerEditTitle => 'Edit customer';

  @override
  String get customerLocation => 'Location';

  @override
  String get customerContact => 'Contact';

  @override
  String get customerOtherAddresses => 'Other delivery addresses';

  @override
  String get customerRecord => 'Record';

  @override
  String get customerNoWhatsapp => 'No WhatsApp number registered.';

  @override
  String get customerNoLocationTitle => 'No GPS location recorded';

  @override
  String get customerNoLocationShort => 'No GPS location';

  @override
  String get customerNoLocationAdmin =>
      'Place this customer on the map so drivers can navigate to them.';

  @override
  String get customerNoLocationEmployee =>
      'Use the written address, or call the customer for directions.';

  @override
  String get customerNotFoundTitle => 'Customer not found';

  @override
  String get customerNotFoundBody => 'This customer may have been deleted.';

  @override
  String get customerArchiveTitle => 'Archive this customer?';

  @override
  String customerArchiveBody(String name) {
    return '$name will be hidden from employees’ searches. You can restore them at any time.';
  }

  @override
  String get customerRestoreTitle => 'Restore this customer?';

  @override
  String customerRestoreBody(String name) {
    return '$name will be visible to employees again.';
  }

  @override
  String get customerArchived => 'Customer archived';

  @override
  String get customerRestored => 'Customer restored';

  @override
  String get customerDeleteTitle => 'Delete permanently?';

  @override
  String customerDeleteBody(String name, String reference) {
    return '$name ($reference) and their addresses will be deleted for everyone. This cannot be undone. Consider archiving instead.';
  }

  @override
  String get customerDeleted => 'Customer deleted';

  @override
  String customerCreated(String reference) {
    return 'Customer $reference created';
  }

  @override
  String get customerUpdated => 'Changes saved';

  @override
  String get copiedPhone => 'Phone number copied';

  @override
  String get copiedReference => 'Reference copied';

  @override
  String get copiedAddress => 'Address copied';

  @override
  String get copiedCredentials => 'Credentials copied';

  @override
  String get adminNotesEmpty => 'No notes.';

  @override
  String get adminNotesHint => 'Visible to administrators only.';

  @override
  String get adminNotesPlaceholder =>
      'Payment habits, opening hours, access instructions…';

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldBusinessName => 'Shop / business name';

  @override
  String get fieldPrimaryPhone => 'Primary phone';

  @override
  String get fieldSecondaryPhone => 'Secondary phone';

  @override
  String get fieldWhatsappPhone => 'WhatsApp number';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldWilaya => 'Wilaya';

  @override
  String get fieldCommune => 'Commune';

  @override
  String get fieldWilayaCommune => 'Commune — Wilaya';

  @override
  String get fieldAddress => 'Detailed address';

  @override
  String get fieldAddressHint => 'Street, building, landmark…';

  @override
  String get fieldAdminNotes => 'Administrator notes';

  @override
  String get fieldCreatedAt => 'Created';

  @override
  String get fieldUpdatedAt => 'Last modified';

  @override
  String get fieldLastLogin => 'Last login';

  @override
  String get fieldLatitude => 'Latitude';

  @override
  String get fieldLongitude => 'Longitude';

  @override
  String get fieldLabel => 'Label';

  @override
  String get fieldLabelHint => 'e.g. Depot, Second shop';

  @override
  String get fieldCompanyName => 'Company name';

  @override
  String get fieldCurrentPassword => 'Current password';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get fieldConfirmPassword => 'Confirm new password';

  @override
  String get formIdentity => 'Identity';

  @override
  String get formAddress => 'Address';

  @override
  String get formWhatsappSame => 'WhatsApp on the primary number';

  @override
  String get formWhatsappHint =>
      'Only enter a WhatsApp number the customer actually uses on WhatsApp.';

  @override
  String get formNoLocation =>
      'No location yet. Without it, drivers only have the written address.';

  @override
  String get formNoExtraAddresses => 'No other address.';

  @override
  String get formStatusActive => 'Active customer';

  @override
  String get formStatusActiveHint => 'Visible to employees.';

  @override
  String get formStatusArchivedHint => 'Archived: hidden from employees.';

  @override
  String get extraAddressTitle => 'Delivery address';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'Your changes have not been saved.';

  @override
  String get conflictTitle => 'Modified elsewhere';

  @override
  String get conflictBody =>
      'Another administrator saved this customer while you were editing. The latest version has been loaded; please re-apply your changes.';

  @override
  String get duplicateHintTitle => 'Possible existing customer';

  @override
  String get duplicatesFoundTitle => 'Possible duplicates';

  @override
  String get duplicatesFoundBody =>
      'These customers have the same phone number or a very similar name. Check before creating a new record.';

  @override
  String get duplicatesReview => 'Go back and check';

  @override
  String get duplicatesSaveAnyway => 'It is a different customer — save';

  @override
  String get duplicateSamePhone => 'Same phone';

  @override
  String get duplicateSimilarName => 'Similar name';

  @override
  String duplicateScore(int percent) {
    return '$percent% match';
  }

  @override
  String get duplicatesTitle => 'Duplicate review';

  @override
  String get duplicatesShort => 'Duplicates';

  @override
  String get duplicatesIntro =>
      'Records are never merged automatically. Open both, then archive or delete the wrong one, or mark the pair as different customers.';

  @override
  String get duplicatesNoneTitle => 'No duplicates detected';

  @override
  String get duplicatesNoneBody =>
      'No customers share a phone number or a near-identical name.';

  @override
  String get duplicatesDismiss => 'Different customers';

  @override
  String get duplicatesDismissed => 'Pair marked as different customers';

  @override
  String get mapOpenFull => 'Full map';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapRecenter => 'Center on customer';

  @override
  String get mapShowAll => 'Show all customers';

  @override
  String mapDistanceAway(String distance) {
    return '$distance away (straight line)';
  }

  @override
  String mapLocatedCount(int count) {
    return '$count on map';
  }

  @override
  String mapMissingCount(int count) {
    return '$count without GPS';
  }

  @override
  String get mapEmptyTitle => 'No customer has a GPS location yet';

  @override
  String get mapEmptyAdmin => 'Open a customer and use “Set location on map”.';

  @override
  String get mapEmptyEmployee =>
      'Locations added by your administrator will appear here.';

  @override
  String get locationServiceDisabled => 'Location is turned off on this phone.';

  @override
  String get locationDenied => 'Location permission was refused.';

  @override
  String get locationDeniedForever =>
      'Location permission is blocked. Enable it in the app settings.';

  @override
  String get locationTimeout =>
      'Could not get a GPS fix. Move outdoors and try again.';

  @override
  String get pickerTitle => 'Customer location';

  @override
  String get pickerSearchHint => 'Search an address or place';

  @override
  String get pickerNoAddressFound => 'No address found. Move the map manually.';

  @override
  String get pickerSearchFailed =>
      'Address search unavailable. Check the connection or move the map manually.';

  @override
  String get pickerInstructions =>
      'Move the map or tap to place the pin on the shop entrance.';

  @override
  String get pickerUseMyLocation => 'Use my current position';

  @override
  String get pickerManualTitle => 'Enter coordinates';

  @override
  String get pickerManualHint => 'Decimal degrees, e.g. 36.753800 and 3.058800';

  @override
  String get pickerMoveFirst =>
      'Place the pin first: move the map, tap it, or search an address.';

  @override
  String get pickerConfirm => 'Confirm this location';

  @override
  String get pickerConfirmTitle => 'Check the location';

  @override
  String get pickerConfirmBody =>
      'Drivers will be guided to exactly this point.';

  @override
  String get pickerUseThisLocation => 'Use this location';

  @override
  String get pickerAdjust => 'Adjust';

  @override
  String get dashboardQuickActions => 'Quick actions';

  @override
  String get dashboardDirectory => 'Directory';

  @override
  String get dashboardRecentCustomers => 'Recently added';

  @override
  String get dashboardRecentActivity => 'Recent activity';

  @override
  String get statTotalCustomers => 'Customers';

  @override
  String get statActiveCustomers => 'Active';

  @override
  String get statEmployees => 'Employees';

  @override
  String get statAdded30Days => 'Added in 30 days';

  @override
  String statAddedThisWeek(int count) {
    return '+$count this week';
  }

  @override
  String statArchived(int count) {
    return '$count archived';
  }

  @override
  String statEmployeesActive(int count) {
    return '$count active';
  }

  @override
  String statMissingLocation(int count) {
    return '$count without GPS';
  }

  @override
  String get statAllLocated => 'All located';

  @override
  String get employeeNew => 'New employee';

  @override
  String get employeesSearchHint => 'Search by name or username';

  @override
  String get employeesEmptyTitle => 'No accounts yet';

  @override
  String get employeesEmptyBody =>
      'Create an account for each delivery employee.';

  @override
  String get employeeNeverLoggedIn => 'Never logged in';

  @override
  String employeeLastLogin(String when) {
    return 'Last login $when';
  }

  @override
  String get employeeIdentity => 'Identity';

  @override
  String get employeeRole => 'Role';

  @override
  String get employeeTempPassword => 'Temporary password';

  @override
  String get usernameHelper => 'Used to sign in. Lowercase, no spaces.';

  @override
  String get passwordRules =>
      'At least 8 characters with letters and digits. Share it privately; the employee can change it in Account settings.';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleEmployee => 'Delivery employee';

  @override
  String get roleAdminHint => 'Full access: customers, employees, settings.';

  @override
  String get roleEmployeeHint =>
      'Search and view customers, call, navigate. Cannot modify data.';

  @override
  String get employeeAdminConfirmTitle => 'Create an administrator?';

  @override
  String get employeeAdminConfirmBody =>
      'This person will be able to modify and delete customers and manage all accounts.';

  @override
  String get employeeCreated => 'Account created';

  @override
  String get credentialsTitle => 'Sign-in details';

  @override
  String get credentialsBody =>
      'Give these to the employee now. The password will not be shown again.';

  @override
  String get employeeDetailsTitle => 'Employee';

  @override
  String get employeeAccount => 'Account';

  @override
  String get employeeManage => 'Manage';

  @override
  String get employeeEditTitle => 'Edit name and role';

  @override
  String get employeeUpdated => 'Account updated';

  @override
  String get employeeResetTitle => 'Reset password';

  @override
  String get employeeResetHint => 'Sets a new temporary password.';

  @override
  String employeeResetBody(String name) {
    return 'Set a new password for $name. Their current password stops working immediately.';
  }

  @override
  String get employeeDeactivateTitle => 'Deactivate this account?';

  @override
  String employeeDeactivateBody(String name) {
    return '$name will immediately lose access to customer data on every device.';
  }

  @override
  String get employeeDeactivateHint => 'Blocks access immediately.';

  @override
  String get employeeActivateTitle => 'Reactivate this account?';

  @override
  String employeeActivateBody(String name) {
    return '$name will be able to sign in again.';
  }

  @override
  String get employeeActivateHint => 'Restores access.';

  @override
  String get employeeDeactivated => 'Account deactivated';

  @override
  String get employeeActivated => 'Account activated';

  @override
  String get employeeSelfHint => 'You cannot deactivate your own account.';

  @override
  String get employeeRecentActivity => 'Recent activity';

  @override
  String get activityTitle => 'Activity log';

  @override
  String get activityEmpty => 'No activity yet';

  @override
  String get activityFilterAdmin => 'Changes';

  @override
  String get activityFilterField => 'Field';

  @override
  String get activitySystem => 'System';

  @override
  String logCustomerCreated(String name) {
    return 'Created customer $name';
  }

  @override
  String logCustomerUpdated(String name) {
    return 'Updated $name';
  }

  @override
  String logCustomerLocation(String name) {
    return 'Moved location of $name';
  }

  @override
  String logCustomerArchived(String name) {
    return 'Archived $name';
  }

  @override
  String logCustomerRestored(String name) {
    return 'Restored $name';
  }

  @override
  String logCustomerDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String logCustomerViewed(String name) {
    return 'Viewed $name';
  }

  @override
  String logCustomerCalled(String name) {
    return 'Called $name';
  }

  @override
  String logCustomerWhatsapp(String name) {
    return 'Opened WhatsApp with $name';
  }

  @override
  String logCustomerNavigated(String name) {
    return 'Started navigation to $name';
  }

  @override
  String logEmployeeCreated(String name) {
    return 'Created account for $name';
  }

  @override
  String logEmployeeActivated(String name) {
    return 'Activated $name';
  }

  @override
  String logEmployeeDeactivated(String name) {
    return 'Deactivated $name';
  }

  @override
  String logEmployeePassword(String name) {
    return 'Reset password of $name';
  }

  @override
  String logEmployeeUpdated(String name) {
    return 'Updated account of $name';
  }

  @override
  String get logDuplicateDismissed => 'Marked two customers as different';

  @override
  String get logSettingsUpdated => 'Updated company settings';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsIntro => 'Directory changes received on this phone.';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody =>
      'New customers and location changes will appear here.';

  @override
  String get notifCreated => 'New customer';

  @override
  String get notifUpdated => 'Customer updated';

  @override
  String get notifLocation => 'Location changed';

  @override
  String get notifArchived => 'Customer archived';

  @override
  String get notifRestored => 'Customer restored';

  @override
  String get notifDeleted => 'Customer deleted';

  @override
  String get settingsAccountGroup => 'Account';

  @override
  String get settingsAdminGroup => 'Administration';

  @override
  String get settingsDataGroup => 'Data';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsAccount => 'Account & password';

  @override
  String get settingsAccountInfo => 'Account';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsApp => 'Company settings';

  @override
  String get settingsCompany => 'Company';

  @override
  String get settingsMapCenter => 'Default map area';

  @override
  String get settingsMapCenterHint =>
      'Where maps open when no customer is selected.';

  @override
  String settingsMapZoom(int zoom) {
    return 'Zoom level: $zoom';
  }

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get profileRoleHint =>
      'Your role and username can only be changed by an administrator.';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get languageSystemHint => 'Follows the phone settings';

  @override
  String get languageNote =>
      'Customer names are always shown as they were entered.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutBody =>
      'The customer data saved on this phone will be erased.';
}
