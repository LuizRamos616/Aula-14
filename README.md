# app_aula14 — Geolocalização e GPS

Projeto da **Aula 14 — Geolocalização e GPS** da disciplina
Programação para Dispositivos Móveis I.

Aplicativo Flutter que captura a posição atual do dispositivo, exibe latitude,
longitude, precisão e altitude, calcula a distância até a Fatec Matão e permite
rastreamento contínuo com `getPositionStream`.

## Funcionalidades

- Verificação de serviço de GPS habilitado.
- Solicitação e validação de permissões de localização.
- Captura única com `getCurrentPosition`.
- Rastreamento contínuo com `getPositionStream`.
- Chip de precisão (verde < 15m, amarelo 15-50m, vermelho > 50m).
- Cálculo de distância até a Fatec Matão com `Geolocator.distanceBetween`.
- Botão "Abrir no Mapa" usando `url_launcher`.

## Estrutura do projeto

```text
lib/
├── services/
│   └── location_service.dart
├── screens/
│   └── geolocalizacao_screen.dart
└── main.dart
```

## Permissões

Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

iOS (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription`.

## Como executar

```bash
flutter pub get
flutter run
```

Para testar no emulador, defina uma localização antes de capturar:

```bash
adb emu geo fix -48.366 -21.603
```

Verificações:

```bash
flutter analyze
flutter test
```

## Versionamento sugerido

```bash
git init
git add android/app/src/main/AndroidManifest.xml ios/Runner/Info.plist pubspec.yaml lib/services/
git commit -m "feat: configura permissoes de GPS e servico LocationService"
git add lib/screens/ lib/main.dart test/ README.md
git commit -m "feat: constroi interface de check-in com coordenadas e rastreamento em tempo real"
git branch -M main
git remote add origin URL_DO_REPOSITORIO
git push -u origin main
```
