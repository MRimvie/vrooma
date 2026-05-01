# Application VTC - Type Yango

## 📱 Description

Application mobile complète de mise en relation entre clients et chauffeurs, similaire à Yango/Uber, développée avec Flutter. L'application permet le transport de personnes et de marchandises avec un système de réservation en temps réel, paiement intégré et suivi GPS.

## ✨ Fonctionnalités

### Application Client

- ✅ **Authentification**
  - Connexion par numéro de téléphone avec OTP (Firebase)
  - Connexion par email et mot de passe
  - Création et gestion de profil utilisateur

- ✅ **Réservation de course**
  - Sélection du point de départ et destination sur carte interactive (Google Maps)
  - Calcul automatique du tarif estimé
  - Choix du type de véhicule (Economy, Comfort, Premium, Van, Camion)
  - Commande de course pour un tiers
  - Application de codes promotionnels

- ✅ **Suivi en temps réel**
  - Localisation du chauffeur en temps réel
  - Estimation du temps d'arrivée
  - Notifications push et SMS
  - Partage de la course

- ✅ **Paiement**
  - Espèces
  - Mobile Money (Orange Money, MTN, Moov, Wave)
  - Carte bancaire
  - Portefeuille intégré

- ✅ **Historique et évaluation**
  - Historique complet des courses
  - Système d'évaluation des chauffeurs (notes et commentaires)
  - Reçus de paiement

### Application Chauffeur

- ✅ **Gestion du statut**
  - Activation/désactivation du statut en ligne
  - Réception des demandes de course
  - Acceptation/refus des courses

- ✅ **Navigation**
  - GPS intégré pour la navigation
  - Suivi de la course en temps réel
  - Mise à jour automatique de la position

- ✅ **Gains et statistiques**
  - Consultation des gains journaliers
  - Historique des courses effectuées
  - Statistiques de performance
  - Gestion des commissions

- ✅ **Documents**
  - Téléchargement des documents (permis, assurance, etc.)
  - Vérification et validation des documents

## 🛠 Technologies utilisées

### Frontend (Mobile)
- **Flutter** 3.6.1
- **Dart** SDK ^3.6.1
- **GetX** - State management et navigation
- **Google Maps Flutter** - Cartographie
- **Firebase** - Authentication, Firestore, Cloud Messaging
- **Socket.IO** - Communication temps réel
- **Flutter Animate** - Animations fluides

### Backend (À configurer)
- **Node.js** avec NestJS / Laravel / Spring Boot
- **MySQL** / **PostgreSQL**
- **WebSocket** / **Firebase** pour le temps réel
- **Google Maps API**

## 📦 Dépendances principales

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  get: ^4.6.5
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.7.9
  cloud_firestore: ^4.13.6
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  flutter_polyline_points: ^2.0.0
  
  # Real-time
  socket_io_client: ^2.0.3+1
  web_socket_channel: ^3.0.1
  
  # Payment
  flutter_stripe: ^10.1.1
  razorpay_flutter: ^1.3.6
  
  # UI/UX
  flutter_screenutil: ^5.9.3
  flutter_animate: ^4.3.0
  animations: ^2.0.11
  lottie: ^2.7.0
  lucide_icons: ^0.257.0
  google_fonts: ^4.0.4
  
  # Other
  pin_code_fields: ^8.0.1
  flutter_rating_bar: ^4.0.1
  permission_handler: ^11.1.0
  share_plus: ^7.2.1
```

## 🚀 Installation

### Prérequis

1. **Flutter SDK** (3.6.1 ou supérieur)
2. **Android Studio** / **Xcode** (pour iOS)
3. **Compte Firebase**
4. **Clé API Google Maps**

### Configuration

1. **Cloner le projet**
```bash
cd /Users/sahelys/AndroidStudioProjects/solidar/vrooma
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration Firebase**
   - Créer un projet sur [Firebase Console](https://console.firebase.google.com)
   - Télécharger `google-services.json` (Android) et `GoogleService-Info.plist` (iOS)
   - Placer les fichiers dans les dossiers appropriés
   - Activer Authentication (Phone, Email/Password)
   - Activer Cloud Firestore
   - Activer Cloud Messaging

4. **Configuration Google Maps**
   - Obtenir une clé API sur [Google Cloud Console](https://console.cloud.google.com)
   - Activer les APIs suivantes:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Directions API
     - Places API
     - Geocoding API

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="VOTRE_CLE_API"/>
   ```

   **iOS** (`ios/Runner/AppDelegate.swift`):
   ```swift
   GMSServices.provideAPIKey("VOTRE_CLE_API")
   ```

5. **Configuration Backend**
   - Mettre à jour l'URL du backend dans `lib/helpers/constant/app_constant.dart`
   ```dart
   static const String baseAPI = 'https://votre-backend.com';
   ```

6. **Permissions**
   
   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Nous avons besoin de votre position pour vous proposer des courses</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>Nous avons besoin de votre position pour le suivi en temps réel</string>
   ```

## 🏃 Lancement

```bash
# Mode développement
flutter run

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📁 Structure du projet

```
lib/
├── models/              # Modèles de données
│   ├── ride_model.dart
│   ├── driver_model.dart
│   ├── payment_model.dart
│   ├── rating_model.dart
│   └── promo_code_model.dart
│
├── services/            # Services
│   ├── auth_service.dart
│   ├── location_service.dart
│   ├── ride_service.dart
│   └── socket_service.dart
│
├── controller/          # Contrôleurs GetX
│   ├── auth/
│   ├── client/
│   ├── driver/
│   └── common/
│
├── views/               # Écrans
│   ├── auth/           # Authentification
│   ├── client/         # App client
│   ├── driver/         # App chauffeur
│   └── common/         # Écrans partagés
│
├── helpers/            # Utilitaires
│   ├── constant/
│   ├── theme/
│   └── my_widgets/
│
└── main.dart           # Point d'entrée
```

## 🎨 Design

L'application utilise un design moderne et intuitif avec:
- **Animations fluides** avec Flutter Animate
- **Transitions** élégantes entre les écrans
- **Thème** clair/sombre
- **UI responsive** avec ScreenUtil
- **Icons** modernes avec Lucide Icons
- **Typographie** Google Fonts

## 🔐 Sécurité

- Authentification Firebase sécurisée
- Tokens JWT pour les API
- Validation côté serveur
- Chiffrement des données sensibles
- HTTPS obligatoire

## 📊 Base de données (Firestore)

### Collections principales

- **users** - Informations utilisateurs
- **drivers** - Profils chauffeurs
- **rides** - Courses
- **payments** - Paiements
- **ratings** - Évaluations
- **promo_codes** - Codes promotionnels
- **notifications** - Notifications

## 🌐 API Backend (À implémenter)

### Endpoints principaux

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/verify-otp

GET    /api/rides
POST   /api/rides
PUT    /api/rides/:id
DELETE /api/rides/:id

POST   /api/payments
GET    /api/payments/:id

POST   /api/ratings
GET    /api/ratings/driver/:id

GET    /api/promo-codes/:code
POST   /api/promo-codes/validate
```

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test
```

## 📱 Déploiement

### Android
1. Configurer le keystore
2. Build: `flutter build apk --release`
3. Upload sur Google Play Console

### iOS
1. Configurer les certificats
2. Build: `flutter build ios --release`
3. Upload sur App Store Connect

## 🤝 Contribution

Ce projet a été développé selon le cahier des charges pour une application de VTC complète.

## 📄 Licence

Propriétaire - Tous droits réservés

## 📞 Support

Pour toute question ou support technique, contactez l'équipe de développement.

## 🎯 Prochaines étapes

- [ ] Intégration complète du backend
- [ ] Tests automatisés complets
- [ ] Optimisation des performances
- [ ] Support multilingue complet
- [ ] Mode hors ligne
- [ ] Analytics et reporting
- [ ] Chat en temps réel
- [ ] Appels VoIP
- [ ] Système de parrainage
- [ ] Programme de fidélité

---

**Version:** 1.0.0  
**Dernière mise à jour:** Mars 2026
