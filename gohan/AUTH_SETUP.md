# Configuración de Autenticación — Gohan

Estado y pasos pendientes para terminar el login con Google y Microsoft sobre Supabase.

---

## Datos clave del proyecto

- **Supabase Project URL**: `https://tlninvmikjfngohiahvm.supabase.co`
- **Supabase publishable key**: `sb_publishable_AjqDjaUvPu4LDEP3R3YMdA_JFlLIIis`
- **Callback de Supabase** (la URL que se registra en Google y Azure):
  ```
  https://tlninvmikjfngohiahvm.supabase.co/auth/v1/callback
  ```
- **Deep link móvil** (configurado en `AndroidManifest.xml` e `Info.plist`):
  ```
  gohan://login-callback
  ```
- **Package Android / Bundle iOS**: `com.example.gohan`

---

## Estado actual

### Hecho ✅

- [x] Paquete `supabase_flutter` añadido al `pubspec.yaml`
- [x] `Supabase.initialize(...)` en `main.dart`
- [x] `login_page.dart` usando `signInWithPassword` real + botones Google/Microsoft + link a registro
- [x] `register_page.dart` con email/password/confirmar
- [x] `auth_gate.dart` escucha `onAuthStateChange`
- [x] `profile_page.dart` lee `currentUser` real
- [x] Deep link en `android/app/src/main/AndroidManifest.xml`
- [x] URL scheme en `ios/Runner/Info.plist`
- [x] Registro por email/password probado y funcionando (con email de confirmación del SMTP por defecto de Supabase)
- [x] **Supabase → Authentication → URL Configuration**:
  - Site URL: `gohan://login-callback`
  - Redirect URLs: `gohan://login-callback`

### Pendiente ⬜

- [ ] **Google Cloud**: crear OAuth Client (Web) y pegar credenciales en Supabase
- [ ] **Azure**: registrar app y pegar credenciales en Supabase
- [ ] Probar los dos botones en emulador/dispositivo real
- [ ] (Producción) Configurar SMTP propio (p.ej. Resend) en lugar del de cortesía de Supabase

---

## Fase A — Google Cloud OAuth

### A.1 Crear proyecto

1. https://console.cloud.google.com
2. Selector de proyectos (arriba a la izquierda) → **New Project** → nombre: `gohan` → **Create**
3. Comprueba que el proyecto creado está seleccionado.

### A.2 OAuth consent screen

Menú lateral → **APIs & Services → OAuth consent screen** (en la UI nueva puede llamarse "Branding").

1. **User type**: **External** → **Create**
2. Mínimo a rellenar:
   - **App name**: `Gohan`
   - **User support email**: tu email
   - **Developer contact email**: tu email
3. **Save and Continue** en los siguientes pasos (Scopes y Summary). No añadas scopes.
4. En **Test users** añade tu email para poder probar mientras la app esté en modo "Testing".

### A.3 Crear el OAuth Client ID

Menú lateral → **APIs & Services → Credentials**.

1. **+ Create Credentials → OAuth client ID**
2. **Application type**: ⚠️ **Web application** (NO Android, NO iOS — aunque la app sea móvil, el flujo lo hace Supabase).
3. **Name**: `Gohan – Supabase`
4. **Authorized redirect URIs → + Add URI**:
   ```
   https://tlninvmikjfngohiahvm.supabase.co/auth/v1/callback
   ```
5. **Create**.
6. Copia y guarda:
   - **Client ID** (algo como `1234-xxxx.apps.googleusercontent.com`)
   - **Client Secret**

### A.4 Pegar en Supabase

Dashboard de Supabase → **Authentication → Sign In / Providers → Google**.

1. Activa **Enable Sign in with Google**.
2. Pega:
   - **Client ID (for OAuth)** → el de Google
   - **Client Secret (for OAuth)** → el de Google
3. Confirma que la **Callback URL** que muestra Supabase coincide con la que registraste en Google.
4. **Save**.

---

## Fase B — Azure / Microsoft (Outlook)

### B.1 Abrir el portal

1. https://portal.azure.com → inicia sesión (vale cuenta personal de Outlook).
2. Barra superior → busca **Microsoft Entra ID** (es el nuevo nombre de "Azure Active Directory") y entra.
3. Menú izquierdo → **App registrations**.

### B.2 Registrar la app

1. **+ New registration**
2. **Name**: `Gohan`
3. **Supported account types**: elige
   - **Accounts in any organizational directory (Any Microsoft Entra ID tenant — Multitenant) and personal Microsoft accounts (e.g. Skype, Xbox)**
   - Esto permite entrar tanto con cuentas de empresa como con `@outlook.com` / `@hotmail.com` personales.
4. **Redirect URI**:
   - Plataforma: **Web**
   - URI:
     ```
     https://tlninvmikjfngohiahvm.supabase.co/auth/v1/callback
     ```
5. **Register**.

### B.3 Copiar el Application (client) ID

En la pantalla **Overview** de la app recién creada copia:
- **Application (client) ID**

(El "Directory (tenant) ID" no hace falta si vamos a usar tenant `common` en Supabase, recomendado para multitenant.)

### B.4 Crear el Client Secret

1. Menú izquierdo de la app → **Certificates & secrets**.
2. Pestaña **Client secrets** → **+ New client secret**.
3. **Description**: `Supabase`. **Expires**: 24 months (es el máximo — apúntate la fecha de caducidad para renovarlo).
4. **Add**.
5. ⚠️ **Copia INMEDIATAMENTE el campo `Value`** (no el "Secret ID"). Una vez que recargues la página, Azure ya no te lo vuelve a mostrar.

### B.5 Permisos (verificación rápida)

Menú izquierdo → **API permissions**.
- Debe aparecer ya por defecto `User.Read` (Microsoft Graph). Con eso basta para obtener email + nombre.
- No hace falta tocar nada más, ni pedir consentimiento de admin.

### B.6 Pegar en Supabase

Dashboard de Supabase → **Authentication → Sign In / Providers → Azure (Microsoft)**.

1. Activa el toggle.
2. Pega:
   - **Application (client) ID** → el de Azure
   - **Secret Value** → el "Value" del Client Secret
   - **Azure Tenant URL** (o "Tenant ID"): pon literalmente la palabra
     ```
     common
     ```
     - Si solo querés admitir cuentas de tu organización, pondrías el Tenant ID concreto en lugar de `common`.
3. **Save**.

---

## Probar

Los botones OAuth **solo funcionan en móvil real o emulador**, no en la previsualización de escritorio.

```powershell
flutter pub get
flutter run
```

Pasos esperados al pulsar "Continuar con Google" o "Continuar con Microsoft":

1. Se abre el navegador del sistema con la pantalla de login del proveedor.
2. Te logueás y aceptás los permisos.
3. El navegador redirige a `https://tlninvmikjfngohiahvm.supabase.co/auth/v1/callback`.
4. Supabase intercambia el código, crea la sesión, y redirige a `gohan://login-callback`.
5. El sistema operativo abre la app por el deep link.
6. `AuthGate` detecta la sesión nueva y entra al `/home`.

Comprobá en **Supabase Dashboard → Authentication → Users** que el usuario aparece, con el proveedor correcto en la columna "Providers" (`google` o `azure`).

---

## Errores típicos y cómo arreglarlos

| Error | Causa probable | Arreglo |
|---|---|---|
| `redirect_uri_mismatch` (Google) | La URL en "Authorized redirect URIs" no coincide al carácter con la de Supabase | Repasá `https://`, sin barra final, project ref exacto |
| `AADSTS50011: reply URL does not match` (Microsoft) | Lo mismo en Azure | Lo mismo: editar en Authentication → Redirect URIs |
| Google "App not verified" | Estás en modo Testing y entraste con un usuario que no está en "Test users" | Añadí tu email en Test users, o publicá la app (no hace falta para uso personal) |
| El navegador no vuelve a la app | El deep link no está bien | Revisar `AndroidManifest.xml`: scheme `gohan` + host `login-callback`. En iOS revisar `Info.plist` |
| Sesión OK en logs pero la app no entra al home | `AuthGate` no se está reconstruyendo | Ya está montado con `StreamBuilder` sobre `onAuthStateChange`, debería ir solo |
| `Email rate limit exceeded` al registrarse | Estás usando el SMTP de cortesía de Supabase (3-4 emails/h) | Configurar SMTP propio (Resend recomendado) |

---

## Producción — antes de publicar

- [ ] Configurar SMTP propio en Supabase (Resend, Brevo, SendGrid…)
- [ ] Traducir las plantillas de email al español (**Authentication → Emails → Email Templates**)
- [ ] En Google Cloud, pasar la app de "Testing" a "In production" (si necesitás más de 100 usuarios o quitar el aviso de "App no verificada")
- [ ] Considerar una página web intermedia (ej. `https://gohan.app/confirm`) como Site URL, para que los enlaces de confirmación de email funcionen también si el usuario abre el correo en el ordenador
- [ ] Apuntar la fecha de caducidad del Client Secret de Azure (24 meses) para renovarlo antes de que caduque
- [ ] Cambiar el `applicationId` / Bundle ID de `com.example.gohan` a uno tuyo definitivo, y volver a registrar las redirect URIs si afecta al deep link
