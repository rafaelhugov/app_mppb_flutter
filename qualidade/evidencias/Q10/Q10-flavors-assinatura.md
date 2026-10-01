# Evidência Q10-T09 a Q10-T11 — Flavors, Assinatura e Artefatos de Build

Data: 01/10/2026  
Repositório: `app_mppb_flutter`  
Dispositivo de Validação: Samsung Galaxy A52 (SM-A525M, Android 14 / API 34)

---

## 1. Isolamento de Flavors (Q10-T09)

O projeto define formalmente no Gradle (`android/app/build.gradle.kts`):

```kotlin
flavorDimensions += "ambiente"

productFlavors {
    create("producao") {
        dimension = "ambiente"
        manifestPlaceholders["appLabel"] = "MPPB+"
    }

    create("homolog") {
        dimension = "ambiente"
        applicationIdSuffix = ".homolog"
        manifestPlaceholders["appLabel"] = "MPPB+ Homolog"
    }
}
```

### Comprovação Dinâmica no Dispositivo Físico:
No dispositivo Galaxy A52, a coexistência de ambos os pacotes foi comprovada via `dumpsys`:

1. **Pacote de Produção (`br.mp.mppbapp.app`)**:
   - Package de produção instalado separadamente no dispositivo.
   - `versionCode=71 minSdk=32 targetSdk=36, versionName=4.0.0`
   - UID do Android: Atribuído de forma independente pelo sistema operacional.

2. **Pacote de Homologação (`br.mp.mppbapp.app.homolog`)**:
   - Pacote de homologação instalado e atualizado via bateria Q10.
   - `versionCode=72 minSdk=24 targetSdk=36, versionName=4.0.0`
   - UID do Android: `u0_a373` (isolado pelo Linux kernel do Android).

**Conclusão de Isolamento**:
- Os identificadores de aplicação são completamente distintos (`.homolog` vs sem sufixo).
- Os diretórios de sandbox no Android (`/data/user/0/...`) possuem proprietários Linux distintos.
- Homologação e Produção coexistem no mesmo aparelho sem sobreposição de armazenamento privado, colisões de intents ou conflito de rotas.

---

## 2. Auditoria de Assinatura (Q10-T10)

No arquivo `android/app/build.gradle.kts`:
- A configuração `signingConfigs.release` consome as propriedades de `rootProject.file("key.properties")`:
  - `keyAlias`
  - `keyPassword`
  - `storeFile`
  - `storePassword`
- Se `key.properties` não existir no ambiente local/CI:
  - Todas as variáveis recebem `null`.
  - Builds do tipo **debug** utilizam o `debug.keystore` padrão gerado pelo SDK do Android.
  - Builds do tipo **release** (ex: `flutter build appbundle --flavor homolog`) falham durante a tarefa `:app:signHomologReleaseBundle` com `NullPointerException` ao tentar invocar o `BundleToolRunnable` com parâmetros nulos de assinatura.

Essa condição foi documentada no risco `RISCO-Q10-001`. Nenhum contorno inseguro (como commitar keystore ou senhas) foi realizado.

---

## 3. Geração de Artefatos APK e AAB (Q10-T11)

1. **APK Debug Homolog**:
   ```powershell
   flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
   ```
   - **Resultado**: Sucesso (`Exit code 0`).
   - Artefato gerado: `build/app/outputs/flutter-apk/app-homolog-debug.apk` (tamanho: 220.343.957 bytes na v72, 181.504.117 bytes na v69).
   - Instalação e execução validadas no Galaxy A52.

2. **AppBundle (AAB) Homolog Release**:
   ```powershell
   flutter build appbundle --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
   ```
   - **Resultado**: **NÃO GERADO** (Falha controlada no Gradle: `Execution failed for task ':app:signHomologReleaseBundle' -> NullPointerException`).
   - **Classificação Metodológica**: **PARCIAL** (ou Bloqueado por Configuração de Assinatura Release).
   - **Causa Raiz**: Ausência de `android/key.properties` nesta estação de desenvolvimento.
   - **Impacto**: Não foi validada nesta estação a geração do AAB release assinável para distribuição. Trata-se de uma pendência objetiva de prontidão para publicação, embora seja boa prática não versionar credenciais no repositório.
