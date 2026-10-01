# Q11 — Evidência de Runtime em Android Físico (Q11-T06, Q11-T07, Q11-C19, Q11-C20)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, serial `RX8RC09H70X`)  
Status: PASSOU (C19) / PARCIAL (C20)

---

## 1. Escopo e Diretriz de Não Invasão

O protocolo da fase Q11 exige que, ao avaliar configurações de sistema como escala de fonte (`font_scale`) e densidade de tela (`density`), os valores originais sejam previamente registrados e obrigatoriamente restaurados ao término dos testes, sem deixar qualquer configuração pessoal do aparelho modificada.

## 2. Coleta de Baseline do Sistema

Comandos executados via ADB:
```powershell
adb devices
# RX8RC09H70X  device

adb shell settings get system font_scale
# Retorno original: 1.1

adb shell wm density
# Retorno original: Physical density: 420
```

## 3. Q11-C19 — Validação de Font Scale no Dispositivo Físico (Status: PASSOU)

1. **Registro Inicial**: `font_scale = 1.1`.
2. **Definição Controlada**: `adb shell settings put system font_scale 1.3`.
3. **Reinicialização da Aplicação Homolog**:
   ```powershell
   adb shell am force-stop br.mp.mppbapp.app.homolog
   adb shell monkey -p br.mp.mppbapp.app.homolog -c android.intent.category.LAUNCHER 1
   ```
4. **Execução do Fluxo Mínimo de Navegação**:
   - `Home Pública`: renderização íntegra da grade de serviços e cabeçalho "Notícias" adaptado com `Wrap` (evidência: [q11-home-font-scale-1.3.png](android/q11-home-font-scale-1.3.png));
   - `Notícias`: navegação para lista de notícias e inspeção de botões de paginação e cards (evidência: [q11-noticias-font-scale-1.3.png](android/q11-noticias-font-scale-1.3.png));
   - `Retorno à Home`: transição limpa via keyevent 4;
   - `Login`: abertura da tela de acesso restrito através do botão "Entrar" na AppBar; campos "Usuário", "Senha" e botões com layout íntegro sem truncamento (evidência: [q11-login-font-scale-1.3.png](android/q11-login-font-scale-1.3.png));
   - `Consulta Processual`: abertura do formulário de processos com cabeçalho adaptado e captcha (evidência: [q11-processos-font-scale-1.3.png](android/q11-processos-font-scale-1.3.png)).

   Evidências visuais do runtime Android em font_scale=1.3 versionadas junto aos artefatos canônicos da Q11.
5. **Inspeção Visual**:
   - Nenhum `RenderFlex overflow` visível;
   - Nenhum clipping de texto ou títulos;
   - Controles e botões com área de toque preservada e acionáveis;
   - Nenhuma sobreposição de elementos na interface.
6. **Restauração Obrigatória e Confirmação**:
   ```powershell
   adb shell settings put system font_scale 1.1
   adb shell settings get system font_scale
   # Retorno confirmado: 1.1
   ```
**Resultado C19**: `PASSOU`.

## 4. Q11-C20 — Display Size / Density (Status: PARCIAL)

- **Classificação**: `PARCIAL — densidade física original aferida e preservada; variação de display size/density não executada no aparelho pessoal; responsividade complementar coberta por testes de viewport`.
- Densidade original `420` mantida intacta sem alterações invasivas no sistema pessoal do usuário.

## 5. Compilação e Instalação do Pacote Android Homolog

- Build executado com:
  ```powershell
  flutter build apk --debug --flavor homolog -t lib/main.dart --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br
  ```
- Instalação no Galaxy A52 via:
  ```powershell
  adb install -r build\app\outputs\flutter-apk\app-homolog-debug.apk
  # Success
  ```
