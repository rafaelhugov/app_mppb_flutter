# Evidência Q12 — Ciclo de Vida e Recuperação no Android Físico

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R01 — Reconciliação Metodológica e Validação Definitiva  
**Aparelho:** Samsung Galaxy A52 (`SM-A525M`, Android 14 / One UI 6.1, API 34)  
**Serial ADB:** `RX8RC09H70X`  
**Package:** `br.mp.mppbapp.app.homolog`

---

## 1. Q12-T07: Ciclo de Vida do Aplicativo (Background, Foreground e App Switch)

### Procedimento Executado
1. Inicialização do app em homologação:
   - Foco confirmado: `br.mp.mppbapp.app.homolog/br.mp.mppbapp.MainActivity`
2. Envio do app para background:
   - Comando: `adb shell input keyevent KEYCODE_HOME`
   - Estado: App pausado/parado em segundo plano pelo SO.
3. Retomada para primeiro plano:
   - Relançamento imediato via intent de launcher.
4. Alternância rápida de aplicativos:
   - Comando: `adb shell input keyevent KEYCODE_APP_SWITCH`
   - Retorno imediato ao App MPPB.

### Resultados e Validações
- **Preservação de Foco:** O aplicativo retomou o estado ativo instantaneamente na `MainActivity`.
- **Ausência de Erros:** Inspeção de `logcat` durante toda a transição de ciclo de vida confirmou:
  - `0` FATAL exceptions na JVM ou engine Flutter;
  - `0` ocorrências de ANR (*Application Not Responding*);
  - `0` vazamentos de listeners ou recarregamento em loop.
- **Calibração Metodológica (Q12-R01):** O escopo físico comprovado contempla background, foreground e alternância de aplicativos (app switch). O bloqueio/desbloqueio de tela (screen lock) não foi exercitado nesta bateria e foi removido das afirmações.
- **Status:** **PASSOU**

---

## 2. Q12-T08: Morte Forçada do Processo (`force-stop`) e Reinício

### Procedimento Executado
1. Encerramento forçado abrupto do processo de homologação:
   ```powershell
   adb shell am force-stop br.mp.mppbapp.app.homolog
   ```
2. Verificação de processo:
   - `pidof br.mp.mppbapp.app.homolog` retornou vazio (processo finalizado com sucesso).
3. Relançamento limpo da aplicação:
   ```powershell
   adb shell monkey -p br.mp.mppbapp.app.homolog -c android.intent.category.LAUNCHER 1
   ```
4. Verificação de inicialização:
   - Novo processo spawned: `PID 2036`.
   - Foco reestabelecido: `br.mp.mppbapp.app.homolog/br.mp.mppbapp.MainActivity`.

### Resultados e Validações
- O aplicativo reiniciou a partir da função `main()` sem resíduos ou estados zumbis.
- Não houve qualquer solicitação de reinstalação ou crash de inicialização.
- O mecanismo de Secure Storage / Android KeyStore permaneceu operacional, sem falhas de decodificação criptográfica. Conforme padrão canônico estabelecido na Q10, valores funcionais específicos não foram comparados/aferidos nesta bateria.
- **Status:** **PASSOU**

---

## 3. Q12-T09: Morte do Processo em Background (`am kill`)

### Procedimento Executado
1. App colocado em background via tecla HOME.
2. Eliminação do processo em background simulando liberação agressiva de memória pelo SO:
   ```powershell
   adb shell am kill br.mp.mppbapp.app.homolog
   ```
3. Confirmação de encerramento do processo:
   - `pidof` retornou vazio.
4. Novo acionamento pelo launcher do dispositivo:
   - Novo processo criado: `PID 3739`.
   - Retomada limpa da interface inicial sem travamentos.

### Resultados e Validações
- A eliminação em background não corrompeu arquivos locais da aplicação.
- A aplicação relançou no estado inicial de forma consistente. O mecanismo de KeyStore permaneceu operacional; valores lógicos específicos de sessão não foram aferidos nesta bateria.
- **Status:** **PASSOU**
