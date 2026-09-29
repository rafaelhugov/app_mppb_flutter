# Q5 - Relatório Final

Data: 2026-09-29  
Escopo: Testes End-to-End Android (Q5) — Sem Q6.

---

## 1. Resultado Executivo

A etapa Q5 consolidou a automação e validação de testes de ponta a ponta (End-to-End) em ambiente físico Android após superação dos bloqueios de virtualização/emulador Linux enfrentados no checkpoint `589f4a7`.

- **Veredito Oficial**: **Q5 CONCLUÍDA NO ESCOPO EXECUTÁVEL LOCAL/PÚBLICO**
- **Formulação da Jornada**: **JORNADA PÚBLICA PRINCIPAL E2E VALIDADA EM ANDROID FÍSICO — 3/3 PASS**

---

## 2. Ambiente de Execução e Hardware Físico

- **Sistema Operacional Host**: Windows 11 físico;
- **Dispositivo Móvel**: Samsung Galaxy A52 (`SM-A525M`), hardware físico real;
- **Sistema Operacional Alvo**: Android 14 (API 34, `arm64-v8a`);
- **Conexão**: USB física direta com ADB estável;
- **Flutter**: 3.44.3 (canal stable) / Dart 3.12.2.

---

## 3. Semântica do Harness e Correção de Asserção

### A. Diagnóstico da Asserção Anterior
No harness inicial, a validação de Notícias buscava o texto `'min de leitura'`, presente apenas no modal de leitura detalhada (`NewsDetailSheet`), e utilizava condição permissiva de fallback. 

### B. Ajuste Semântico Estrito
O arquivo `integration_test/q5_public_e2e_test.dart` foi ajustado para exigir **evidência positiva inequívoca de carregamento de conteúdo real da API de homologação**:
- Espera explícita pelo identificador `find.byKey(const Key('lista-noticias'))` (timeout de 25s);
- Assertion: `expect(find.byKey(const Key('lista-noticias')), findsOneWidget)`;
- Assertion: `expect(find.text('Abrir'), findsWidgets)`.

### C. Garantia contra Falsos Positivos
- Se a API retornar erro (`NoticiaFailure`), o componente renderiza o estado de erro (`CustomErrorWidget`) com "Não foi possível carregar as notícias" e botão "Tentar novamente". O teste **falha imediatamente** por ausência de `Key('lista-noticias')`.
- Se a API retornar lista vazia, renderiza o texto de estado vazio, e o teste **falha** por ausência dos cards e botões `'Abrir'`.
- Estados de erro ou telas de fallback **não satisfazem** a asserção.

---

## 4. Resultados do Gate E2E (3/3 Consecutivos)

Comando executado:
```powershell
flutter test integration_test/q5_public_e2e_test.dart --flavor homolog -d RX8RC09H70X --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
```

| Execução | Teste / Jornada | Duração | Resultado | Estado ADB |
| :---: | :--- | :---: | :---: | :---: |
| **1** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~13s | **PASS** | `device` |
| **2** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~12s | **PASS** | `device` |
| **3** | Q5-E2E-PUB-01 (Home → Contatos → Home → Notícias → Home) | ~13s | **PASS** | `device` |

Smoke E2E complementar (`integration_test/q5_smoke_home_e2e_test.dart`):
- Execução: **PASS** (~5s) | ADB: `device`.

Logs nativos verificados:
- **0 FATAL EXCEPTION**;
- **0 AndroidRuntime**;
- **0 SIGSEGV**;
- **0 PlatformException**;
- **0 Crash Flutter**.

---

## 5. Matriz de Classificação das Jornadas

| Jornada | Classificação Final | Justificativa Técnica / Institucional |
| :--- | :--- | :--- |
| **Home / Contatos / Notícias** | **PASSOU** | Validada integralmente em 3/3 execuções consecutivas no Android físico com dados reais de homologação. |
| **Diário Oficial** | **NÃO EXECUTADA** | Jornada não implementada no harness de automação nesta rodada. Sem bloqueio técnico externo comprovado. |
| **Processos / Captcha** | **PARCIAL / E2E MANUAL CONTROLADO PENDENTE** | Consulta pública exige validação de Captcha que não deve ser burlado pela automação. |
| **Certidão Extrajudicial** | **BLOQUEADA** | Restrição de segurança para evitar emissão e efeitos externos sem massa descartável em homologação. |
| **Ouvidoria** | **BLOQUEADA** | Restrição de segurança para evitar envio de manifestação com efeito institucional real. |
| **Jornadas Autenticadas** (Login, Perfil, Carteira, Contracheque, etc.) | **BLOQUEADAS** | **BLOQUEADAS POR CREDENCIAL/MASSA HOMOLOG AUTORIZADA** (dependência institucional externa). |
| **FCM Real** | **BLOQUEADA** | Infraestrutura Firebase institucional não configurada para automação local; isolada com `Q5_E2E_DISABLE_FCM=true`. |

---

## 6. Revisões de Código Mantidas

1. **`lib/features/perfil/providers/perfil_provider.dart` (BUG-Q5-001)**:
   - Adicionados guards `if (!ref.mounted) return;` em métodos assíncronos de `PerfilNotifier`.
   - Resolve falha assíncrona comprovada de acesso a provider após descarte (dispose).
   - Não altera regra funcional nem comportamento de negócio.
2. **`lib/features/noticias/ui/noticias_page.dart`**:
   - Adicionado identificador de testabilidade `key: const Key('lista-noticias')`.
   - Não altera layout, comportamento nem regras de negócio.
3. **Pumps do Harness (`integration_test/q5_public_e2e_test.dart`)**:
   - Substituição controlada de `pumpAndSettle` por pumps temporizados (`await tester.pump(...)`) para contornar animação contínua do carrossel (`NewsCarousel`) da Home sem introduzir sleeps excessivos ou flakiness.

---

## 7. Bateria de Regressão

| Gate | Comando | Resultado |
| :--- | :--- | :---: |
| **Flutter Analyze** | `flutter analyze` | **PASS (0 warnings, 0 errors)** |
| **Flutter Tests** | `flutter test` | **PASS (157/157 testes)** |
| **Coverage** | `flutter test --coverage` | **PASS (157/157 testes, lcov gerado)** |
| **Secret Scan** | `bash scripts/security/secret_scan.sh` | **PASS (0 secrets expostos)** |
| **Security Regression** | `bash scripts/security/security_regression.sh` | **PASS (conformidade de segurança mantida)** |
| **Build APK Homolog** | `flutter build apk --debug --flavor homolog -t lib/main.dart` | **PASS (`app-homolog-debug.apk` gerado)** |

---

## 8. Status para Q6

- **Q6 NÃO INICIADA** nesta execução.
- Base técnica: **PRONTA PARA PLANEJAMENTO Q6**.
