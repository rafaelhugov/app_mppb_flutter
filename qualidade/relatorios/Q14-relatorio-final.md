# Relatório Final — Fase Q14: User Acceptance Testing (UAT) e Aceite Final

**Data de Conclusão da Avaliação Técnica:** 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final (Última Fase do Ciclo)  
**Status Global:** `Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO PÚBLICO E AUTENTICADO CONSOLIDADO COM RESSALVAS, ACEITE HUMANO PENDENTE`  
**Prontidão para Store Review:** `NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001`

---

## Resumo Executivo

As 18 jornadas previstas foram tecnicamente executadas e classificadas.

13 foram APROVADAS e 5 APROVADAS COM RESSALVA.

Não foram observadas jornadas tecnicamente reprovadas após o reteste das correções Q14.

---

## 1. Baseline Canônica

### 1.1 Aplicação Mobile (Flutter)
- **Diretório:** `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Branch de Trabalho:** `qualidade/q14-auth-configuravel-uat`
- **Modificações Preservadas:** `pubspec.yaml` (`version: 4.0.0+69 → 4.0.0+72`) mantida rigorosamente fora de qualquer commit da Q14.
- **Estado dos Gates:**
  - `flutter analyze`: **0 issues**
  - `flutter test`: **244 / 244 aprovados (100%)**
  - `secret_scan.sh` e `security_regression.sh`: **Aprovados (exit code 0)**
  - APK Homologação: Compilado, instalado e operacional no dispositivo físico Samsung Galaxy A52.

### 1.2 Backend (Spring Boot REST API)
- **Diretório:** `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- **Branch de Trabalho:** `qualidade/q14-usuarios-sinteticos-uat-review`
- **Compilação e Pacote:** `mvn -q -pl restapi-common,mobile-service -DskipTests package` gerou `mobile-service-0.3.25.jar` com JDK 21 Adoptium (**BUILD SUCCESS**).
- **Proveniência do JAR:**
  - Arquivo: `mobile-service\target\mobile-service-0.3.25.jar`
  - Tamanho: `168.358.734 bytes`
  - SHA-256: `DAD1E11CDDFC324A879CB151E202983D363ABBE9CDEB87480E6EA2A94424FD61`
- **Integridade Canônica:** Zero diff nos módulos centrais `restapi-common` e `Q6ConcorrenciaIntegridadeTest.java`.
- **Estado dos Gates (Suíte Canônica Maven):**
  - `restapi-common`: **11** testes (Failures: 0, Errors: 0, Skipped: 0)
  - `mobile-service`: **191** testes (Failures: 0, Errors: 0, Skipped: 0)
  - **TOTAL:** **202** testes (Failures: 0, Errors: 0, Skipped: 0) — 100% de sucesso.
  - Regressões automatizadas específicas Q14 incluídas e aprovadas:
    - BUG-Q14-001 (parsing flexível de datas): PASS
    - BUG-Q14-002 (persistência FCM sintética vs institucional): PASS
    - U17 Autorização por Objeto (cross-object isolation Membro vs Servidor): PASS

---

## 2. Ambiente e Dispositivo Físico

- **Aparelho:** Samsung Galaxy A52 (`SM-A525M`), serial ADB `RX8RC09H70X`.
- **Sistema Operacional:** Android 14 / One UI 6.1 (API 34).
- **Pacote Testado:** `br.mp.mppbapp.app.homolog` (v4.0.0, versionCode 72, minSdk 24, targetSdk 36).
- **Artefato Canônico:** `build\app\outputs\flutter-apk\app-homolog-debug.apk` (SHA-256: `B23096118DFD80E3FC8A687B94B994B8622130E33485A786D0A3BFF674971FA7`).
- **Endpoint do Backend:** Spring Boot local em porta 9003 com profile de homologação sintética ativado (`UAT_SYNTHETIC_USERS_ENABLED=true`), integrado via ADB Reverse `tcp:9003 tcp:9003`.
- **Executor dos Testes:** `TÉCNICO` (Avaliação estritamente objetiva de engenharia; não classificado como Usuário Real).
- **Data da Execução:** 02/10/2026 (Público) e 04/10/2026 (Autenticado).

---

## 3. Jornadas Públicas (8 Jornadas Canônicas Q14-U01 a Q14-U08)

Todas as 8 jornadas públicas foram avaliadas no dispositivo físico com evidências versionadas em `qualidade/evidencias/Q14/android/`:

| ID Cenário | Jornada | Evidência Principal | Executor | Resultado Técnico | Ressalvas / Observações |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Primeira Abertura e Inicialização | `android/q14-home.png` | TÉCNICO | **APROVADO** | Inicialização sem falhas; splash institucional exibido; alcance imediato da Home pública. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | TÉCNICO | **APROVADO** | Grade de 6 serviços ao cidadão, carrossel dinâmico de notícias e botões de ação íntegros. |
| **Q14-U03** | Q14-J03 — Notícias (Listagem, Detalhe e Retorno) | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | TÉCNICO | **APROVADO** | Notícias consumidas via API, busca, abertura em modal de detalhe com foto e texto, retorno limpo à lista e à Home. |
| **Q14-U04** | Q14-J04 — Diário Oficial (Edições e Visualizador PDF) | `android/q14-diario.png`, `android/q14-diario-loaded.png` | TÉCNICO | **APROVADO** | Edições recentes listadas com destaque para Última Edição (Nº 3160); renderização in-app completa do documento PDF no visualizador sem travamentos. |
| **Q14-U05** | Q14-J05 — Consulta Processual e Filtros | `android/q14-processos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, filtros e validação de submissão aferidos; consulta com processo conhecido e resultado positivo não aferida por ausência de processo de teste homologado. |
| **Q14-U06** | Q14-J06 — Contatos e Atendimento Institucional | `android/q14-contatos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Presença visual e renderização dos botões 'Ligar' e 'Mapa', telefone, endereço, horários e ouvidoria aferidas na tela física; handoffs reais para discador e mapa não disparados para evitar ligações ou aberturas externas espúrias. |
| **Q14-U07** | Q14-J07 — Certidão Extrajudicial (Emissão/Validação) | `android/q14-certidao.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface e validações locais aferidas (mensagens visuais de CPF/Nome obrigatórios); emissão/validação positiva contra base real não executadas por integridade. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, fluxo de identificação em 5 passos (Identif., Classif., Relato, Anexos, Revisão), alternância de manifestação anônima e validação de formulário aferidas; submissão e geração de protocolo oficial deliberadamente omitidas por segurança operacional. |

**Total Público:** 8 executados (100%), 4 aprovados sem ressalva, 4 aprovados com ressalva metodológica (U05, U06, U07, U08), 0 reprovados, 0 bloqueados.

---

## 4. Jornadas Autenticadas (10 Jornadas Canônicas Q14-U09 a Q14-U18)

Todas as 10 jornadas autenticadas foram executadas integralmente no Samsung Galaxy A52 com massa sintética autorizada e evidências arquivadas em `qualidade/evidencias/Q14/android/`:

| ID Cenário | Jornada | Evidência Principal | Executor | Resultado Técnico | Detalhes da Validação |
|---|---|---|---|---|---|
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional | `q14-uat-login-invalido.png`, `q14-uat-membro-dashboard.png`, `q14-uat-servidor-dashboard.png` | TÉCNICO | **APROVADO** | Rejeição 401 de credencial espúria validada; login bem-sucedido para `uat.membro` e `uat.servidor` com transição imediata para os dashboards personalizados. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | `q14-uat-sessao-persistencia.png`, `q14-uat-membro-dashboard.png`, `q14-uat-logout-home.png` | TÉCNICO | **APROVADO** | Persistência validada através de force-stop e reabertura do aplicativo com sessão preservada; logout manual validado com retorno à Home pública desautenticada. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | `q14-uat-membro-perfil.png`, `q14-uat-membro-perfil-detalhes.png`, `q14-uat-servidor-perfil.png` | TÉCNICO | **APROVADO** | Visualização completa de perfil para Membro (Lucas Almeida Monteiro, Promotor Substituto) e Servidora (Mariana Costa Ribeiro, Analista Ministerial). |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | `q14-uat-carteira-membro.png`, `q14-uat-carteira-membro-verso.png`, `q14-uat-carteira-servidor.png` | TÉCNICO | **APROVADO** | Cartão oficial renderizado: modelo Membro (vermelho) e Servidor (bege/dourado); verso inspecionado contendo marca d'água de proteção contra falsificação funcional. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | `q14-uat-contracheque.png`, `q14-uat-contracheque-valores.png`, `q14-uat-contracheque-pdf.png`, `q14-uat-contracheque-servidor.png` | TÉCNICO | **APROVADO** | Listagem de competências, alternador de privacidade de valores e geração de documento PDF com marca d'água de UAT sintético. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | `q14-uat-pagamentos.png`, `q14-uat-pagamentos-2025.png`, `q14-uat-pagamentos-servidor.png`, `q14-uat-pagamentos-vazio.png` | TÉCNICO | **APROVADO** | Detalhamento de pagamentos para 2026 e 2025; tratamento robusto de exercício sem lançamentos através de mensagem orientativa de estado vazio. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | `q14-uat-designacoes-membro.png`, `q14-uat-designacoes-vazio.png` | TÉCNICO | **APROVADO** | Designação ativa (Portaria 101/2025) exibida para Membro; estado vazio amigável ("Nenhuma designação ativa encontrada") exibido para Servidora. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | `q14-uat-concessoes-baseline.png`, `q14-uat-concessoes-saldos.png`, `q14-uat-concessoes-servidor.png` | TÉCNICO | **APROVADO** | Consulta de calendário e aba de saldos de concessões apurados corretamente para Membro (15 dias disp.) e Servidora (30 dias disp.). |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | `q14-uat-concessoes-solicitada.png`, `q14-uat-concessoes-detalhes-cancelada.png` | TÉCNICO | **APROVADO** | Ciclo operacional completo: seleção de data inicial, sugestão de término calculada via API, submissão com sucesso, cancelamento com atualização imediata para status 'Cancelada'. Isolamento de leitura e operação entre datasets comprovado (tentativa cruzada rejeitada com HTTP 403 e preservação de estado da solicitação de Lucas). |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | Log de auditoria backend (`mobile-service`) | TÉCNICO | **APROVADO COM RESSALVA** | registro e desativação FCM validados em sandbox; entrega de push real não aferida. |

**Total Autenticado:** 10 executados (100%), 9 aprovados sem ressalva (U09 a U17), 1 aprovado com ressalva (U18), 0 reprovados, 0 bloqueados.

---

## 5. Bugs Identificados e Corrigidos na Fase (BUG-Q14)

1. **BUG-Q14-001 — Parsing de Data na Sugestão de Concessões:**
   - *Descrição:* Ao acionar a seleção da data inicial em `Marcar gozo`, o backend retornava erro de desserialização na chamada de sugestões de data de término.
   - *Correção:* Ajustada a desserialização e manipulação temporal no serviço de concessões e storage de sandbox para aceitar formato `yyyy-MM-dd` estrito, ISO local com timestamp e fallback seguro sem HTTP 500. Regressão automatizada coberta por teste canônico `test31_regressaoBugQ14_001_parsingDataSugestoesConcessao` (PASS).
2. **BUG-Q14-002 — Registro de Dispositivo FCM em Modo Sintético:**
   - *Descrição:* A tentativa de registro de token de notificação push pelo app causava falha ao tentar persistência relacional sem registro prévio do usuário sintético no banco principal.
   - *Correção:* O serviço `DispositivoFcmService` foi adaptado para armazenar o token em memória de sandbox durante o perfil de UAT/Review, respondendo com HTTP 200 e emitindo diagnósticos estruturados nos logs de auditoria, sem invocar repositório relacional e preservando o fluxo institucional normal. Regressão automatizada coberta por teste canônico `test32_regressaoBugQ14_002_persistenciaFcmSinteticaVsInstitucional` (PASS).
3. **BUG-Q14-003 — Falha de Estado Pós-Dispose em OuvidoriaNotifier (`Ref._throwIfInvalidUsage`):**
   - *Causa:* Ao carregar combos iniciais via microtask (`_initCombos()`), se o container/provider for descartado antes do retorno assíncrono (ex.: teardown de testes ou navegação), a tentativa de atualizar `state` dentro do bloco `catch`/`try` sem verificar `ref.mounted` lançava exceção não tratada do Riverpod.
   - *Reprodução:* Execução da suíte canônica de testes (`test/features/qualidade/q13_fuzz_property_test.dart`, P03), onde o descarte rápido do container disparava erro assíncrono pós-conclusão.
   - *Impacto:* Falha na suíte de testes de regressão (queda de 244 para 243 aprovados).
   - *Correção Mínima:* Adicionadas guardas `if (!ref.mounted) return;` em `_initCombos` e demais métodos assíncronos de `OuvidoriaNotifier`, alinhando-o ao padrão já existente em todos os outros notifiers do projeto.
   - *Teste de Regressão:* Execução de `test/features/qualidade/q13_fuzz_property_test.dart` (P03) e suíte canônica completa (244/244 PASS).
4. **Cross-Object Authorization U17 (Isolamento de Leitura e Operação):**
   - *Cenário:* Validação em que o perfil Servidor tenta cancelar ou adiar solicitação criada pelo Membro.
   - *Resultado:* Rejeição imediata com HTTP 403 Forbidden e estado da solicitação preservado sem qualquer alteração. Coberto por teste canônico `test33_crossObjectAuthorizationU17_isolamentoOperacoesEntreMembroEServidor` (PASS).

---

## 6. Observações Registradas (OBS-Q14)

- **OBS-Q14-001 — Fornecimento de Credenciais para Homologação do Escopo Autenticado:**
   Para a etapa subsequente de Aceite Humano por avaliadores institucionais reais, o MPPB poderá disponibilizar credenciais de teste em homologação ou utilizar a mesma infraestrutura sintética validada nesta rodada.
- **BLOQUEIO-Q14-REVIEW-001 — Prontidão para Store Review:**
   - Contas REVIEW ainda não provisionadas operacionalmente;
   - Backend externo acessível aos revisores ainda não definido/implantado;
   - Modo sintético permanece bloqueado em produção;
   - Estratégia de Store Review será definida após o aceite institucional.
   Não enfraquecer a proteção de produção.

---

## 7. Regressão Técnica e Integridade dos Gates

- **Flutter Analyze:** **0 issues** encontrados.
- **Flutter Test:** **244 / 244** testes aprovados (100%).
- **Security Gates:** `secret_scan.sh` e `security_regression.sh` aprovados com código 0.
- **Backend Test:** **202 / 202** testes aprovados (11 restapi-common, 191 mobile-service, executados com JDK 21).
- **Backend Package:** Concluído com sucesso (BUILD SUCCESS, JAR SHA-256: `DAD1E11CDDFC324A879CB151E202983D363ABBE9CDEB87480E6EA2A94424FD61`).
- **Integridade de Versão:** `pubspec.yaml` preservado com modificação não comitada (`4.0.0+69 → 4.0.0+72`).
- **Repositórios Git:** Zero commits, zero pushes, zero merges efetuados.

---

## 8. Resultado Pré-UAT Técnico

```text
PRÉ-UAT TÉCNICO:
APROVADO COM RESSALVAS
```
*Classificação Técnica:*
- 18 jornadas classificadas: 13 APROVADAS e 5 APROVADAS COM RESSALVA (U05, U06, U07, U08, U18).
- Escopo Autenticado: Q14-U09 a U17 APROVADOS; Q14-U18 APROVADO COM RESSALVA.
- 0 REPROVADO, 0 BLOQUEADO técnico.

---

## 9. Resultado UAT Humano

```text
AVALIAÇÃO HUMANA = NÃO EXECUTADA
ACEITE HUMANO = PENDENTE
```
A avaliação com usuários reais de negócio **NÃO FOI EXECUTADA** nesta rodada técnica, estando o roteiro (`qualidade/uat/Q14-roteiro-avaliador.md`) e o modelo do termo (`qualidade/uat/Q14-termo-aceite.md`) devidamente prontos para aplicação formal pelo órgão.

---

## 10. Prontidão para Store Review

```text
GOOGLE/APPLE STORE REVIEW:
NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001
```
Motivo:
- Contas REVIEW ainda não provisionadas operacionalmente;
- Backend externo acessível aos revisores ainda não definido/implantado;
- Modo sintético permanece bloqueado em produção;
- Estratégia de Store Review será definida após o aceite institucional.
Não enfraquecer a proteção de produção.

---

## 11. Pendências

1. Convocação do avaliador humano representativo para aplicação do roteiro Q14;
2. Preenchimento e assinatura do Termo de Homologação e Aceite Final (`Q14-termo-aceite.md`);
3. Definição da estratégia e infraestrutura de Store Review pós-aceite institucional.

---

## 12. Decisão Final

```text
STATUS DA FASE:
Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO PÚBLICO E AUTENTICADO CONSOLIDADO COM RESSALVAS, ACEITE HUMANO PENDENTE

STATUS DO CICLO DE QUALIDADE:
CICLO Q1–Q13 CONCLUÍDO / Q14 AGUARDANDO ACEITE HUMANO
```

As 18 jornadas previstas foram tecnicamente executadas e classificadas. 13 foram APROVADAS e 5 APROVADAS COM RESSALVA. Não foram observadas jornadas tecnicamente reprovadas após o reteste das correções Q14. Aguardando exclusivamente a realização do aceite humano institucional para a assinatura definitiva. Não criar fase Q15.
