# Q9 — Evidência de Compatibilidade Android

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Auditado Estaticamente / Evidência Dinâmica Herdada da Q8-R01 / Bloqueio de Reexecução Q9  

---

## 1. Configurações de SDK e Compilação

A inspeção do arquivo `android/app/build.gradle.kts` e do manifesto consolidado (`build/app/intermediates/merged_manifests/homologDebug/processHomologDebugManifest/AndroidManifest.xml`) evidenciou os seguintes parâmetros:

- **compileSdk:** `36` (Android 16 / Vanilla Ice Cream Preview)
- **minSdk:** `24` (Piso de instalação configurado em Android 7.0 / API 24. A indicação de minSdk comprova exclusivamente o nível mínimo de API aceito pelo package manager para instalação; não comprova funcionamento em todas as versões intermediárias de Android 7 a 16 sem testes dinâmicos específicos).
- **targetSdk:** `36` (Android 16) — **CONFORME COM O REQUISITO ATUAL DA GOOGLE PLAY** para novos aplicativos e atualizações móveis em 01/10/2026 (`targetSdk >= 36`).
- **Source & Target Compatibility:** `JavaVersion.VERSION_17`
- **Kotlin JVM Target:** `JVM_17`
- **Gradle Distribution:** `gradle-9.1.0-all`
- **Android Gradle Plugin (AGP):** Integrado via Flutter Gradle Plugin.

---

## 2. Permissões Declaradas e Comportamento em Runtime

### 2.1 Permissões Declaradas pelo Aplicativo
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 2.2 Permissões Injetadas por Plugins (Merged Manifest)
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### 2.3 Análise de Comportamento em Runtime por Nível de API
1. **`POST_NOTIFICATIONS`:**
   - **Android 13+ (API 33+):** Requer solicitação explícita ao usuário em runtime. O app utiliza o plugin `firebase_messaging` para gerenciar a requisição através de `FirebaseMessaging.instance.requestPermission()`.
   - **Android 12 ou inferior (API <= 32):** Permissão concedida automaticamente na instalação.
2. **`USE_BIOMETRIC`:**
   - Acionada sob demanda através do plugin `local_auth` na tela de Carteira Funcional. O sistema operacional exibe o `BiometricPrompt` nativo gerenciado pelo Android Framework (leitura de digital ou reconhecimento facial). Não exige dialog prévio de permissão de runtime.
   - Para versões anteriores ao Android 9 (API 28), o fallback via `USE_FINGERPRINT` atua através do `FingerprintManagerCompat`.
3. **`INTERNET` e `ACCESS_NETWORK_STATE`:**
   - Permissões do tipo Normal, concedidas no momento da instalação pelo Google Play / package manager.

---

## 3. Visibilidade de Pacotes (Android 11+ / API 30+)

Para cumprir a política restritiva de Package Visibility do Android 11+, o `AndroidManifest.xml` declara explicitamente os seletores em `<queries>`:
```xml
<queries>
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="https" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:scheme="http" />
    </intent>
    <intent>
        <action android:name="android.intent.action.SENDTO" />
        <data android:scheme="mailto" />
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW" />
        <data android:mimeType="application/pdf" />
    </intent>
    <intent>
        <action android:name="android.intent.action.GET_CONTENT" />
        <data android:mimeType="*/*" />
    </intent>
</queries>
```
Isso assegura que chamadas `canLaunchUrl(Uri.parse('https://...'))`, `canLaunchUrl(Uri.parse('mailto:...'))` e seleção de arquivos na Ouvidoria (`file_picker`) funcionem corretamente no Android 11, 12, 13, 14 e superiores.

---

## 4. Política de Tráfego de Rede (Cleartext)

O atributo `android:usesCleartextTraffic="false"` está explicitamente definido na tag `<application>`.
- **Efeito:** O Android Network Security Config bloqueia qualquer requisição HTTP não criptografada em nível de sistema operacional no aplicativo compilado.
- **Rastreabilidade:** Conforme validado no teste de segurança `test/security/android_cleartext_manifest_test.dart` (aprovado na regressão).

---

## 5. Auditoria de Hardware e Validação em Runtime

### 5.1 Evidência Dinâmica Herdada da Q8-R01
Na fase imediatamente anterior (Q8-R01), o aplicativo MPPB foi executado e medido dinamicamente em dispositivo físico real:
- **Aparelho:** Samsung Galaxy A52 (`SM-A525M`), serial ADB `RX8RC09H70X`.
- **Sistema Operacional:** Android 14 / API 34.
- **Arquitetura:** `arm64-v8a`.
- **Modo do Build:** **PROFILE** (`app-homolog-profile.apk`).
- **Comportamento Comprovado:**
  - Instalação e cold start (1.939 ms em 5 amostras válidas);
  - Warm start (107 ms em 5 amostras válidas);
  - Navegação entre telas principais (Home → Notícias → voltar);
  - 125 frames analisados via SurfaceFlinger BLAST (0% jank > 16,6 ms);
  - Memória temporal M0 a M4 estabilizada sem leak.
- **Delimitação:** Esta evidência comprova o funcionamento no **Android 14 / arm64-v8a**. Ela **não é extrapolada** para as demais versões da faixa API 24 a 36.

### 5.2 Bloqueio de Reexecução na Q9
- **Tentativa de Execução:** Durante a abertura da Q9, foram executadas sondagens via `adb devices -l` e inspeção do subsistema PnP do Windows (`Get-PnpDevice`).
- **Diagnóstico:**
  - O subsistema USB do Windows reportou `Present: False` para as interfaces Samsung (`SAMSUNG Android ADB Interface`, `SAMSUNG Mobile USB Modem`).
  - O daemon ADB não detectou o dispositivo conectado.
  - Tentativas de verificação física pelo operador não restabeleceram a comunicação de dados no barramento USB do host Windows.
- **Classificação:** O cenário de reexecução na Q9 foi classificado estritamente como **`BLOQUEADO POR LIMITAÇÃO DE AMBIENTE`**, em conformidade com as regras metodológicas da Q9.
