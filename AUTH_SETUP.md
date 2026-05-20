# Configuración de Google Sign-In

El backend FastAPI sigue siendo la autoridad de auth: el frontend obtiene un
`id_token` de Google con el SDK nativo y lo manda a `POST /api/auth/google/`.
El backend valida el token contra Google y emite **su propio JWT** (el mismo
que el login email/password).

## Datos clave

- **Package Android / Bundle iOS**: `com.example.gohan` (cambiar antes de
  publicar a algo propio).
- **No usamos deep links** porque el flujo es nativo, no por navegador.

## Lo que tenés que hacer una sola vez

### 1. Google Cloud Console

Si no tenés un proyecto, creá uno en https://console.cloud.google.com.

#### 1.1 OAuth consent screen

`APIs & Services → OAuth consent screen`.

- **User type**: External → Create
- **App name**: `Gohan`
- **User support email** / **Developer contact email**: tu email
- **Test users**: agregá tu email mientras la app esté en Testing

#### 1.2 Crear OAuth Client IDs (UNO por plataforma)

`APIs & Services → Credentials → + Create Credentials → OAuth client ID`.

Vas a crear **tres** clients distintos. Cada plataforma usa el suyo.

##### a) Web (lo usa el backend para validar)

- Application type: **Web application**
- Name: `Gohan — backend validator`
- **Authorized redirect URIs**: ninguna (no se usa para redirect, solo como
  audience válida)
- Guardar el **Client ID** → lo necesita el backend.

##### b) Android

- Application type: **Android**
- Name: `Gohan — Android`
- Package name: `com.example.gohan` (o el que tengas en
  `android/app/build.gradle.kts`)
- SHA-1: ejecutá lo siguiente y pegá el SHA1 de debug:

  ```powershell
  cd gohan/android
  ./gradlew signingReport
  ```

  Buscá la línea `SHA1` debajo de `Variant: debug`.

##### c) iOS

- Application type: **iOS**
- Name: `Gohan — iOS`
- Bundle ID: `com.example.gohan`
- Guardar el **iOS URL scheme** que muestra (es el `REVERSED_CLIENT_ID`).

### 2. Backend

Setear la env var con TODOS los client IDs (separados por coma):

```powershell
# PowerShell (sesión actual)
$env:GOOGLE_OAUTH_CLIENT_IDS = "WEB_CLIENT_ID.apps.googleusercontent.com,ANDROID_CLIENT_ID.apps.googleusercontent.com,IOS_CLIENT_ID.apps.googleusercontent.com"
```

Para persistirla, agregala al `.env` que ya carga `python-dotenv` (si lo usás)
o al system env. **No commitees** los client IDs al repo público.

### 3. Android

Generalmente con solo configurar el Client ID Android en Google Cloud alcanza
(el SDK nativo lo resuelve por package + SHA1, no hace falta poner el ID en
ningún archivo).

### 4. iOS

Agregá en `gohan/ios/Runner/Info.plist`, dentro del `<dict>` raíz:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplazar por el "iOS URL scheme" que te da Google Cloud
                 al crear el OAuth Client de iOS (es el REVERSED_CLIENT_ID). -->
            <string>com.googleusercontent.apps.IOS_CLIENT_ID</string>
        </array>
    </dict>
</array>
<key>GIDClientID</key>
<string>IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

### 5. Probar

```powershell
cd gohan
flutter pub get
flutter run
```

Apretá **"Continuar con Google"** en login o register. Debería abrir el
selector nativo de Google, devolver un id_token, y entrar a `/home`.

## Cuando NO funcione

| Síntoma | Causa probable |
|---|---|
| `Token de Google inválido` en el snackbar | El `aud` del id_token no está en `GOOGLE_OAUTH_CLIENT_IDS` del backend. Revisar que el ID correcto esté en la env var. |
| `Login con Google no configurado en el servidor` (503) | Falta la env var `GOOGLE_OAUTH_CLIENT_IDS` en el backend. |
| Google selector aparece pero no devuelve nada | En Android: el SHA1 del OAuth Client no coincide con el de tu keystore de debug. |
| `Google no devolvió un id_token` | En iOS: falta el `GIDClientID` en `Info.plist`. |

## Cuándo no te alcanza esto

- **Producción**: pasar la app de Testing a "In production" en Google Cloud
  para que cualquier usuario pueda entrar (no solo los que agregaste como
  Test Users).
- **Otra plataforma**: si querés correr en web/desktop, hay que crear más
  OAuth Clients y agregarlos a `GOOGLE_OAUTH_CLIENT_IDS`.
