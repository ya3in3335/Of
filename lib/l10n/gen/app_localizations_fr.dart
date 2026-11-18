// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'OUTIFOR';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get splashLoading => 'Sécurisation de la session…';

  @override
  String get loading => 'Chargement…';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navCustomers => 'Clients';

  @override
  String get navEmployees => 'Employés';

  @override
  String get navMap => 'Carte';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navProfile => 'Profil';

  @override
  String get offlineBanner =>
      'Hors ligne — affichage de la copie enregistrée sur ce téléphone';

  @override
  String get actionActivate => 'Activer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionApply => 'Appliquer';

  @override
  String get actionArchive => 'Archiver';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionCall => 'Appeler';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionChange => 'Modifier';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionCopyAll => 'Tout copier';

  @override
  String get actionCopyPhone => 'Copier le n°';

  @override
  String get actionCopyReference => 'Copier la réf.';

  @override
  String get actionCreateAccount => 'Créer le compte';

  @override
  String get actionCreateCustomer => 'Créer le client';

  @override
  String get actionDeactivate => 'Désactiver';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionDiscard => 'Abandonner';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionGenerate => 'Générer';

  @override
  String get actionHidePassword => 'Masquer le mot de passe';

  @override
  String get actionShowPassword => 'Afficher le mot de passe';

  @override
  String get actionNavigate => 'Itinéraire';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionOk => 'OK';

  @override
  String get actionOpenInMaps => 'Ouvrir dans Maps';

  @override
  String get actionOpenSettings => 'Réglages';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionSaveChanges => 'Enregistrer';

  @override
  String get actionSearchAddressInMaps =>
      'Chercher l\'adresse dans Google Maps';

  @override
  String get actionSeeAll => 'Tout voir';

  @override
  String get actionSetLocation => 'Placer sur la carte';

  @override
  String get actionSignOut => 'Se déconnecter';

  @override
  String get actionSkip => 'Passer';

  @override
  String get actionStartNavigation => 'Démarrer la navigation';

  @override
  String get actionViewProfile => 'Voir la fiche';

  @override
  String get actionWhatsapp => 'WhatsApp';

  @override
  String get onboarding1Title => 'De la facture au client en quelques secondes';

  @override
  String get onboarding1Body =>
      'Tapez le nom inscrit sur la facture. Noms partiels, références et numéros fonctionnent.';

  @override
  String get onboarding2Title => 'Adresses de livraison exactes';

  @override
  String get onboarding2Body =>
      'Visualisez chaque commerce sur la carte et lancez Google Maps en un geste.';

  @override
  String get onboarding3Title => 'Sécurisé et toujours à jour';

  @override
  String get onboarding3Body =>
      'Les comptes sont créés par votre responsable. Les modifications arrivent sur chaque téléphone automatiquement.';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous à l\'annuaire clients OUTIFOR';

  @override
  String get loginUsername => 'Nom d\'utilisateur';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginNoSignup =>
      'Les comptes sont créés par votre administrateur.';

  @override
  String get errorOffline =>
      'Pas de connexion internet. Vérifiez le réseau puis réessayez.';

  @override
  String get errorOfflineSave =>
      'Vous êtes hors ligne. Rien n\'a été enregistré — réessayez une fois la connexion rétablie.';

  @override
  String get errorTimeout =>
      'Le serveur met trop de temps à répondre. Réessayez.';

  @override
  String get errorInvalidCredentials =>
      'Nom d\'utilisateur ou mot de passe incorrect.';

  @override
  String get errorAccountDisabled =>
      'Ce compte est désactivé. Contactez votre administrateur.';

  @override
  String get errorSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorForbidden =>
      'Vous n\'avez pas l\'autorisation pour cette action.';

  @override
  String get errorNotFound => 'Cet élément n\'existe plus.';

  @override
  String get errorConflict =>
      'Quelqu\'un d\'autre a modifié cette fiche. Rechargez puis réessayez.';

  @override
  String get errorUsernameTaken => 'Ce nom d\'utilisateur est déjà utilisé.';

  @override
  String get errorWeakPassword =>
      'Mot de passe trop faible : au moins 8 caractères avec lettres et chiffres.';

  @override
  String get errorValidation =>
      'Certaines informations sont invalides. Vérifiez le formulaire.';

  @override
  String get errorNotConfigured =>
      'Le serveur n\'est pas entièrement configuré. Contactez votre administrateur.';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Réessayez.';

  @override
  String get errorCannotOpenApp =>
      'Aucune application du téléphone ne peut ouvrir ceci.';

  @override
  String get stateOfflineTitle => 'Vous êtes hors ligne';

  @override
  String get stateErrorTitle => 'Chargement impossible';

  @override
  String get validationRequired => 'Obligatoire';

  @override
  String get validationTooShort => 'Trop court';

  @override
  String get validationTooLong => 'Trop long';

  @override
  String get validationPhone => 'Numéro invalide (ex. 0555 12 34 56)';

  @override
  String get validationUsername =>
      '3 à 32 caractères : minuscules, chiffres, . _ -';

  @override
  String get validationPassword =>
      'Au moins 8 caractères, avec lettres et chiffres';

  @override
  String get validationMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get validationNumber => 'Valeur invalide';

  @override
  String get validationSamePassword => 'Choisissez un autre mot de passe';

  @override
  String get formFixErrors => 'Veuillez corriger les champs signalés.';

  @override
  String get syncSyncing => 'Synchronisation…';

  @override
  String syncDone(String time) {
    return 'Synchronisé à $time';
  }

  @override
  String syncOffline(String time) {
    return 'Hors ligne · données de $time';
  }

  @override
  String get syncOfflineNoData => 'Hors ligne · jamais synchronisé';

  @override
  String get syncError => 'Échec de synchro · toucher pour réessayer';

  @override
  String get syncNever => 'Pas encore synchronisé';

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get syncCompleted => 'L\'annuaire est à jour';

  @override
  String get syncFailed => 'Échec de la synchronisation. Réessayez plus tard.';

  @override
  String get timeJustNow => 'à l\'instant';

  @override
  String timeMinutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String timeHoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String get timeYesterday => 'hier';

  @override
  String timeDaysAgo(int count) {
    return 'il y a $count jours';
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
    return 'Bonjour $name';
  }

  @override
  String get homeTitle => 'Trouver un client';

  @override
  String get homeCustomersAvailable => 'clients dans l\'annuaire';

  @override
  String get homeWithLocation => 'avec position GPS';

  @override
  String get searchTitle => 'Rechercher un client';

  @override
  String get searchHint => 'Nom sur la facture, téléphone ou réf. OUT';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients trouvés',
      one: '1 client trouvé',
    );
    return '$_temp0';
  }

  @override
  String get searchMultipleHint =>
      'Plusieurs clients correspondent. Vérifiez le téléphone et la ville avant d’ouvrir.';

  @override
  String get searchNoResultsTitle => 'Aucun client trouvé';

  @override
  String get searchNoResultsBody =>
      'Vérifiez l\'orthographe, essayez seulement le nom de famille ou cherchez par téléphone.';

  @override
  String get searchOfflineNote =>
      'Vous êtes hors ligne : les clients ajoutés depuis la dernière synchro ne sont pas encore sur ce téléphone.';

  @override
  String get searchRecent => 'Consultés récemment';

  @override
  String get searchTipsTitle => 'Vous pouvez chercher par';

  @override
  String get searchTipName => 'Nom (prénom, nom ou une partie)';

  @override
  String get searchTipReference => 'Référence client';

  @override
  String get searchTipPhone => 'Numéro de téléphone';

  @override
  String directoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients',
      one: '1 client',
      zero: 'Aucun client',
    );
    return '$_temp0';
  }

  @override
  String get directoryFilterHint => 'Filtrer par nom, téléphone, référence…';

  @override
  String get directoryEmptyTitle => 'Aucun client pour le moment';

  @override
  String get directoryEmptyAdmin =>
      'Ajoutez votre premier client pour constituer l\'annuaire.';

  @override
  String get directoryEmptyEmployee =>
      'Les clients ajoutés par votre administrateur apparaîtront ici.';

  @override
  String get directoryNoMatchTitle => 'Aucun résultat';

  @override
  String get directoryNoMatchBody =>
      'Aucun client ne correspond à ces filtres.';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterAllWilayas => 'Toutes les wilayas';

  @override
  String get filterNoLocation => 'Sans position GPS';

  @override
  String get filterReset => 'Réinitialiser';

  @override
  String get filterWilaya => 'Wilaya';

  @override
  String get sortTitle => 'Trier';

  @override
  String get sortName => 'Nom A–Z';

  @override
  String get sortNewest => 'Plus récents';

  @override
  String get sortUpdated => 'Modifiés récemment';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusArchived => 'Archivé';

  @override
  String get statusArchivedPlural => 'Archivés';

  @override
  String get statusInactive => 'Inactif';

  @override
  String get customerProfileTitle => 'Fiche client';

  @override
  String get customerNew => 'Nouveau client';

  @override
  String get customerEditTitle => 'Modifier le client';

  @override
  String get customerLocation => 'Localisation';

  @override
  String get customerContact => 'Contact';

  @override
  String get customerOtherAddresses => 'Autres adresses de livraison';

  @override
  String get customerRecord => 'Historique de la fiche';

  @override
  String get customerNoWhatsapp => 'Aucun numéro WhatsApp enregistré.';

  @override
  String get customerNoLocationTitle => 'Aucune position GPS enregistrée';

  @override
  String get customerNoLocationShort => 'Sans position GPS';

  @override
  String get customerNoLocationAdmin =>
      'Placez ce client sur la carte pour que les livreurs puissent s’y rendre.';

  @override
  String get customerNoLocationEmployee =>
      'Utilisez l\'adresse écrite ou appelez le client pour être guidé.';

  @override
  String get customerNotFoundTitle => 'Client introuvable';

  @override
  String get customerNotFoundBody => 'Ce client a peut-être été supprimé.';

  @override
  String get customerArchiveTitle => 'Archiver ce client ?';

  @override
  String customerArchiveBody(String name) {
    return '$name sera masqué des recherches des employés. Vous pourrez le restaurer à tout moment.';
  }

  @override
  String get customerRestoreTitle => 'Restaurer ce client ?';

  @override
  String customerRestoreBody(String name) {
    return '$name sera de nouveau visible par les employés.';
  }

  @override
  String get customerArchived => 'Client archivé';

  @override
  String get customerRestored => 'Client restauré';

  @override
  String get customerDeleteTitle => 'Supprimer définitivement ?';

  @override
  String customerDeleteBody(String name, String reference) {
    return '$name ($reference) et ses adresses seront supprimés pour tous. Action irréversible. Préférez l’archivage si possible.';
  }

  @override
  String get customerDeleted => 'Client supprimé';

  @override
  String customerCreated(String reference) {
    return 'Client $reference créé';
  }

  @override
  String get customerUpdated => 'Modifications enregistrées';

  @override
  String get copiedPhone => 'Numéro copié';

  @override
  String get copiedReference => 'Référence copiée';

  @override
  String get copiedAddress => 'Adresse copiée';

  @override
  String get copiedCredentials => 'Identifiants copiés';

  @override
  String get adminNotesEmpty => 'Aucune note.';

  @override
  String get adminNotesHint => 'Visible uniquement par les administrateurs.';

  @override
  String get adminNotesPlaceholder =>
      'Habitudes de paiement, horaires, consignes d\'accès…';

  @override
  String get fieldFirstName => 'Prénom';

  @override
  String get fieldLastName => 'Nom';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get fieldBusinessName => 'Nom du commerce';

  @override
  String get fieldPrimaryPhone => 'Téléphone principal';

  @override
  String get fieldSecondaryPhone => 'Téléphone secondaire';

  @override
  String get fieldWhatsappPhone => 'Numéro WhatsApp';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldWilaya => 'Wilaya';

  @override
  String get fieldCommune => 'Commune';

  @override
  String get fieldWilayaCommune => 'Commune — Wilaya';

  @override
  String get fieldAddress => 'Adresse détaillée';

  @override
  String get fieldAddressHint => 'Rue, bâtiment, point de repère…';

  @override
  String get fieldAdminNotes => 'Notes administrateur';

  @override
  String get fieldCreatedAt => 'Créé le';

  @override
  String get fieldUpdatedAt => 'Dernière modification';

  @override
  String get fieldLastLogin => 'Dernière connexion';

  @override
  String get fieldLatitude => 'Latitude';

  @override
  String get fieldLongitude => 'Longitude';

  @override
  String get fieldLabel => 'Libellé';

  @override
  String get fieldLabelHint => 'ex. Dépôt, Deuxième magasin';

  @override
  String get fieldCompanyName => 'Nom de l\'entreprise';

  @override
  String get fieldCurrentPassword => 'Mot de passe actuel';

  @override
  String get fieldNewPassword => 'Nouveau mot de passe';

  @override
  String get fieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get formIdentity => 'Identité';

  @override
  String get formAddress => 'Adresse';

  @override
  String get formWhatsappSame => 'WhatsApp sur le numéro principal';

  @override
  String get formWhatsappHint =>
      'Indiquez uniquement un numéro réellement utilisé sur WhatsApp.';

  @override
  String get formNoLocation =>
      'Pas encore de position. Sans elle, les livreurs n\'ont que l\'adresse écrite.';

  @override
  String get formNoExtraAddresses => 'Aucune autre adresse.';

  @override
  String get formStatusActive => 'Client actif';

  @override
  String get formStatusActiveHint => 'Visible par les employés.';

  @override
  String get formStatusArchivedHint => 'Archivé : masqué pour les employés.';

  @override
  String get extraAddressTitle => 'Adresse de livraison';

  @override
  String get discardTitle => 'Abandonner les modifications ?';

  @override
  String get discardBody => 'Vos modifications n\'ont pas été enregistrées.';

  @override
  String get conflictTitle => 'Modifié ailleurs';

  @override
  String get conflictBody =>
      'Un autre administrateur a enregistré ce client pendant votre modification. La dernière version est chargée ; refaites vos changements.';

  @override
  String get duplicateHintTitle => 'Client peut-être déjà enregistré';

  @override
  String get duplicatesFoundTitle => 'Doublons possibles';

  @override
  String get duplicatesFoundBody =>
      'Ces clients ont le même numéro ou un nom très proche. Vérifiez avant de créer une nouvelle fiche.';

  @override
  String get duplicatesReview => 'Revenir et vérifier';

  @override
  String get duplicatesSaveAnyway => 'C\'est un autre client — enregistrer';

  @override
  String get duplicateSamePhone => 'Même téléphone';

  @override
  String get duplicateSimilarName => 'Nom proche';

  @override
  String duplicateScore(int percent) {
    return 'Similarité $percent %';
  }

  @override
  String get duplicatesTitle => 'Revue des doublons';

  @override
  String get duplicatesShort => 'Doublons';

  @override
  String get duplicatesIntro =>
      'Les fiches ne sont jamais fusionnées automatiquement. Ouvrez les deux, puis archivez ou supprimez la mauvaise, ou marquez-les comme clients différents.';

  @override
  String get duplicatesNoneTitle => 'Aucun doublon détecté';

  @override
  String get duplicatesNoneBody =>
      'Aucun client ne partage un numéro ou un nom quasi identique.';

  @override
  String get duplicatesDismiss => 'Clients différents';

  @override
  String get duplicatesDismissed => 'Paire marquée comme clients différents';

  @override
  String get mapOpenFull => 'Plein écran';

  @override
  String get mapMyLocation => 'Ma position';

  @override
  String get mapRecenter => 'Centrer sur le client';

  @override
  String get mapShowAll => 'Afficher tous les clients';

  @override
  String mapDistanceAway(String distance) {
    return 'À $distance (à vol d’oiseau)';
  }

  @override
  String mapLocatedCount(int count) {
    return '$count sur la carte';
  }

  @override
  String mapMissingCount(int count) {
    return '$count sans GPS';
  }

  @override
  String get mapEmptyTitle => 'Aucun client n\'a encore de position GPS';

  @override
  String get mapEmptyAdmin => 'Ouvrez un client puis « Placer sur la carte ».';

  @override
  String get mapEmptyEmployee =>
      'Les positions ajoutées par votre administrateur apparaîtront ici.';

  @override
  String get locationServiceDisabled =>
      'La localisation est désactivée sur ce téléphone.';

  @override
  String get locationDenied => 'La permission de localisation a été refusée.';

  @override
  String get locationDeniedForever =>
      'La localisation est bloquée. Activez-la dans les réglages de l\'application.';

  @override
  String get locationTimeout =>
      'Position GPS introuvable. Sortez à découvert et réessayez.';

  @override
  String get pickerTitle => 'Position du client';

  @override
  String get pickerSearchHint => 'Chercher une adresse ou un lieu';

  @override
  String get pickerNoAddressFound =>
      'Aucune adresse trouvée. Déplacez la carte manuellement.';

  @override
  String get pickerSearchFailed =>
      'Recherche indisponible. Vérifiez la connexion ou déplacez la carte manuellement.';

  @override
  String get pickerInstructions =>
      'Déplacez la carte ou touchez pour placer l\'épingle sur l\'entrée du commerce.';

  @override
  String get pickerUseMyLocation => 'Utiliser ma position';

  @override
  String get pickerManualTitle => 'Saisir les coordonnées';

  @override
  String get pickerManualHint => 'Degrés décimaux, ex. 36.753800 et 3.058800';

  @override
  String get pickerMoveFirst =>
      'Placez d\'abord l\'épingle : déplacez la carte, touchez-la ou cherchez une adresse.';

  @override
  String get pickerConfirm => 'Valider cette position';

  @override
  String get pickerConfirmTitle => 'Vérifiez la position';

  @override
  String get pickerConfirmBody =>
      'Les livreurs seront guidés exactement vers ce point.';

  @override
  String get pickerUseThisLocation => 'Utiliser cette position';

  @override
  String get pickerAdjust => 'Ajuster';

  @override
  String get dashboardQuickActions => 'Actions rapides';

  @override
  String get dashboardDirectory => 'Annuaire';

  @override
  String get dashboardRecentCustomers => 'Ajoutés récemment';

  @override
  String get dashboardRecentActivity => 'Activité récente';

  @override
  String get statTotalCustomers => 'Clients';

  @override
  String get statActiveCustomers => 'Actifs';

  @override
  String get statEmployees => 'Employés';

  @override
  String get statAdded30Days => 'Ajoutés en 30 jours';

  @override
  String statAddedThisWeek(int count) {
    return '+$count cette semaine';
  }

  @override
  String statArchived(int count) {
    return '$count archivés';
  }

  @override
  String statEmployeesActive(int count) {
    return '$count actifs';
  }

  @override
  String statMissingLocation(int count) {
    return '$count sans GPS';
  }

  @override
  String get statAllLocated => 'Tous localisés';

  @override
  String get employeeNew => 'Nouvel employé';

  @override
  String get employeesSearchHint => 'Chercher par nom ou identifiant';

  @override
  String get employeesEmptyTitle => 'Aucun compte';

  @override
  String get employeesEmptyBody => 'Créez un compte pour chaque livreur.';

  @override
  String get employeeNeverLoggedIn => 'Jamais connecté';

  @override
  String employeeLastLogin(String when) {
    return 'Dernière connexion $when';
  }

  @override
  String get employeeIdentity => 'Identité';

  @override
  String get employeeRole => 'Rôle';

  @override
  String get employeeTempPassword => 'Mot de passe temporaire';

  @override
  String get usernameHelper => 'Sert à la connexion. Minuscules, sans espaces.';

  @override
  String get passwordRules =>
      'Au moins 8 caractères avec lettres et chiffres. Transmettez-le en privé ; l’employé pourra le changer dans Compte.';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleEmployee => 'Livreur / Employé';

  @override
  String get roleAdminHint => 'Accès complet : clients, employés, paramètres.';

  @override
  String get roleEmployeeHint =>
      'Recherche et consultation, appel, navigation. Aucune modification.';

  @override
  String get employeeAdminConfirmTitle => 'Créer un administrateur ?';

  @override
  String get employeeAdminConfirmBody =>
      'Cette personne pourra modifier et supprimer des clients et gérer tous les comptes.';

  @override
  String get employeeCreated => 'Compte créé';

  @override
  String get credentialsTitle => 'Identifiants de connexion';

  @override
  String get credentialsBody =>
      'Transmettez-les maintenant. Le mot de passe ne sera plus affiché.';

  @override
  String get employeeDetailsTitle => 'Employé';

  @override
  String get employeeAccount => 'Compte';

  @override
  String get employeeManage => 'Gestion';

  @override
  String get employeeEditTitle => 'Modifier nom et rôle';

  @override
  String get employeeUpdated => 'Compte mis à jour';

  @override
  String get employeeResetTitle => 'Réinitialiser le mot de passe';

  @override
  String get employeeResetHint => 'Définit un nouveau mot de passe temporaire.';

  @override
  String employeeResetBody(String name) {
    return 'Nouveau mot de passe pour $name. L’ancien cesse de fonctionner immédiatement.';
  }

  @override
  String get employeeDeactivateTitle => 'Désactiver ce compte ?';

  @override
  String employeeDeactivateBody(String name) {
    return '$name perdra immédiatement l\'accès aux données clients sur tous ses appareils.';
  }

  @override
  String get employeeDeactivateHint => 'Bloque l\'accès immédiatement.';

  @override
  String get employeeActivateTitle => 'Réactiver ce compte ?';

  @override
  String employeeActivateBody(String name) {
    return '$name pourra de nouveau se connecter.';
  }

  @override
  String get employeeActivateHint => 'Rétablit l\'accès.';

  @override
  String get employeeDeactivated => 'Compte désactivé';

  @override
  String get employeeActivated => 'Compte activé';

  @override
  String get employeeSelfHint =>
      'Vous ne pouvez pas désactiver votre propre compte.';

  @override
  String get employeeRecentActivity => 'Activité récente';

  @override
  String get activityTitle => 'Journal d\'activité';

  @override
  String get activityEmpty => 'Aucune activité';

  @override
  String get activityFilterAdmin => 'Modifications';

  @override
  String get activityFilterField => 'Terrain';

  @override
  String get activitySystem => 'Système';

  @override
  String logCustomerCreated(String name) {
    return 'Client $name créé';
  }

  @override
  String logCustomerUpdated(String name) {
    return '$name modifié';
  }

  @override
  String logCustomerLocation(String name) {
    return 'Position de $name modifiée';
  }

  @override
  String logCustomerArchived(String name) {
    return '$name archivé';
  }

  @override
  String logCustomerRestored(String name) {
    return '$name restauré';
  }

  @override
  String logCustomerDeleted(String name) {
    return '$name supprimé';
  }

  @override
  String logCustomerViewed(String name) {
    return 'A consulté $name';
  }

  @override
  String logCustomerCalled(String name) {
    return 'A appelé $name';
  }

  @override
  String logCustomerWhatsapp(String name) {
    return 'A ouvert WhatsApp avec $name';
  }

  @override
  String logCustomerNavigated(String name) {
    return 'Itinéraire vers $name';
  }

  @override
  String logEmployeeCreated(String name) {
    return 'Compte créé pour $name';
  }

  @override
  String logEmployeeActivated(String name) {
    return '$name activé';
  }

  @override
  String logEmployeeDeactivated(String name) {
    return '$name désactivé';
  }

  @override
  String logEmployeePassword(String name) {
    return 'Mot de passe de $name réinitialisé';
  }

  @override
  String logEmployeeUpdated(String name) {
    return 'Compte de $name modifié';
  }

  @override
  String get logDuplicateDismissed => 'Deux clients marqués comme différents';

  @override
  String get logSettingsUpdated => 'Paramètres de l\'entreprise modifiés';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsIntro =>
      'Changements de l\'annuaire reçus sur ce téléphone.';

  @override
  String get notificationsEmptyTitle => 'Aucune notification';

  @override
  String get notificationsEmptyBody =>
      'Les nouveaux clients et changements de position apparaîtront ici.';

  @override
  String get notifCreated => 'Nouveau client';

  @override
  String get notifUpdated => 'Fiche modifiée';

  @override
  String get notifLocation => 'Position modifiée';

  @override
  String get notifArchived => 'Client archivé';

  @override
  String get notifRestored => 'Client restauré';

  @override
  String get notifDeleted => 'Client supprimé';

  @override
  String get settingsAccountGroup => 'Compte';

  @override
  String get settingsAdminGroup => 'Administration';

  @override
  String get settingsDataGroup => 'Données';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsAccount => 'Compte et mot de passe';

  @override
  String get settingsAccountInfo => 'Compte';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsApp => 'Paramètres de l\'entreprise';

  @override
  String get settingsCompany => 'Entreprise';

  @override
  String get settingsMapCenter => 'Zone de carte par défaut';

  @override
  String get settingsMapCenterHint =>
      'Où s\'ouvrent les cartes quand aucun client n\'est sélectionné.';

  @override
  String settingsMapZoom(int zoom) {
    return 'Niveau de zoom : $zoom';
  }

  @override
  String get settingsSaved => 'Paramètres enregistrés';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get passwordChanged => 'Mot de passe modifié';

  @override
  String get profileSaved => 'Profil mis à jour';

  @override
  String get profileRoleHint =>
      'Votre rôle et votre identifiant ne peuvent être modifiés que par un administrateur.';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get languageSystemHint => 'Suit les réglages du téléphone';

  @override
  String get languageNote =>
      'Les noms des clients sont toujours affichés tels qu’ils ont été saisis.';

  @override
  String get signOutTitle => 'Se déconnecter ?';

  @override
  String get signOutBody =>
      'Les données clients enregistrées sur ce téléphone seront effacées.';
}
