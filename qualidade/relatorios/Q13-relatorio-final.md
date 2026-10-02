# Q13 — Relatório Final: Mutation Testing, Property-Based Testing e Fuzz Testing

**Fase:** Q13 — Mutation Testing, Property-Based Testing e Fuzz Testing  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Data:** 02/10/2026  
**Status da Fase:** **CONCLUÍDA**  
**Próxima Fase:** **Q14 NÃO INICIADA**  

---

## 1. Sumário Executivo

A fase **Q13** submeteu o Frontend Flutter (`app_mppb_flutter`) e o Backend Spring Boot (`spring-boot/restapi`) a três técnicas complementares de verificação avançada:
1. **Mutation Testing (Amostral Controlado):** Avaliou se as suítes de testes automatizados detectam e falham quando falhas semânticas deliberadas de lógica de negócio e segurança são injetadas no código de produção;
2. **Property-Based Testing:** Verificou formalmente que invariantes de serialização, validação de regras de domínio (como módulo 11 de CPF), hashing criptográfico e mapeamento de exceções permanecem verdadeiras sob centenas de combinações geradas dinamicamente;
3. **Fuzz Testing:** Submeteu parsers, desserializadores e handlers de erro a dados anômalos, truncados, malformados e limites de borda para certificar a ausência de crashes ou vazamento de informações sensíveis.

Todo o procedimento foi conduzido em ambiente estritamente local, sem conexão com produção, sem credenciais externas e com isolamento total via worktrees temporários, sem persistir nenhuma mutação no código-fonte final.

---

## 2. Resumo de Mutation Testing

A mutação semântica foi executada em **worktrees temporários dedicados** (`..\app_mppb_flutter_q13_mut` e `..\restapi_q13_mut`). Cada uma das 24 mutações declaradas foi aplicada individualmente, com validação de `git diff`, execução do teste específico, captura da falha de asserção, restauração com `git restore` e confirmação de retorno ao baseline limpo.

O log reproduzível de execução de todas as 24 mutações está registrado em [`qualidade/evidencias/Q13/Q13-mutation-execution-log.md`](file:///c:/Users/rafae/projetosMPPB/app_mppb_flutter/qualidade/evidencias/Q13/Q13-mutation-execution-log.md).

### 2.1 Frontend Flutter (12 Mutações Amostrais)
- **Mutações Executadas:** 12
- **Killed (Baseline):** 9 (`MUT-FLUTTER-01`, `03`, `04`, `05`, `06`, `07`, `10`, `11`, `12`)
- **Survived (Baseline):** 3 (`MUT-FLUTTER-02`, `08`, `09`) — todos classificados como `TEST GAP`
- **Equivalent:** 0
- **Invalid:** 0
- **INITIAL SAMPLED MUTATION SCORE:** **75,0%** (9/12)
- **Sobreviventes Mortos na Rodada Pós-Gap:**
  - `MUT-FLUTTER-02` (invalidação de carteira no logout): morto por `P07` (`q13_fuzz_property_test.dart:335:7`)
  - `MUT-FLUTTER-08` (módulo 11 de CPF da Ouvidoria): morto por `P03` (`q13_fuzz_property_test.dart:174:9`)
  - `MUT-FLUTTER-09` (tamanho de CPF na Ouvidoria): morto por `P03` (`q13_fuzz_property_test.dart:174:9`)
- **POST-GAP SAMPLED MUTATION SCORE:** **100,0%** (12/12 mortas após reexecução contra a suíte ampliada)

### 2.2 Backend Spring Boot (12 Mutações Amostrais)
- **Mutações Executadas:** 12
- **Killed (Baseline):** 9 (`MUT-BACKEND-01`, `02`, `03`, `04`, `05`, `09`, `10`, `11`, `12`)
- **Survived (Baseline):** 3 (`MUT-BACKEND-06`, `07`, `08`) — todos classificados como `TEST GAP`
- **Equivalent:** 0
- **Invalid:** 0
- **INITIAL SAMPLED MUTATION SCORE:** **75,0%** (9/12)
- **Sobreviventes Mortos na Rodada Pós-Gap:**
  - `MUT-BACKEND-06` (faixa 4xx no FeignErrorDecoder): morto por `F07` (`Q13MutationPropertyFuzzTest.java:409`)
  - `MUT-BACKEND-07` (leitura de corpo de resposta no FeignErrorDecoder): morto por `F07` (`Q13MutationPropertyFuzzTest.java:417`)
  - `MUT-BACKEND-08` (hashing SHA-256 no DispositivoFcmService): morto por `P09` (`Q13MutationPropertyFuzzTest.java:233`)
- **POST-GAP SAMPLED MUTATION SCORE:** **100,0%** (12/12 mortas após reexecução contra a suíte ampliada)

> [!NOTE]
> O *Post-Gap Sampled Mutation Score* de 100,0% refere-se estritamente ao conjunto amostral de 24 mutantes selecionados para verificação da eficácia das suítes de teste ampliadas, não constituindo um mutation score exaustivo do produto.

---

## 3. Resumo de Property-Based Testing (Métricas Reconciliadas)

As métricas de Property-Based Testing distinguem rigorosamente **iterações de loop** (*iterations*) de **entradas geradas** (*generated cases*), em especial onde cada iteração avalia múltiplas variações (ex: P03 avalia 1 caso válido e 1 caso corrompido por iteração):

| ID | Alvo / Invariante | Repositório | Seed | Loop Iterations | Generated Cases | Código de Produção Exercitado | Resultado |
|---|---|---|---:|---:|---:|---|---|
| **P01** | Roundtrip DTOs (`UsuarioCarteira`, `PerfilUsuario`) | Flutter | `130013` | 100 | 100 | `UsuarioCarteira.fromJson`, `PerfilUsuario.fromJson` (SIM) | **PASSOU** |
| **P02** | Formatter de Telefone & Validadores com Entradas Extremas | Flutter | `130014` | 200 | 200 | `TelefoneInputFormatter.formatEditUpdate` (SIM) | **PASSOU** |
| **P03** | Invariante de Módulo 11 do CPF da Ouvidoria | Flutter | `130015` | 500 | 1.000 | `OuvidoriaNotifier.nextStep() -> _isValidCPF` (SIM) | **PASSOU** |
| **P04** | Formatter de Telefone Fixo (10) e Móvel (11) | Flutter | `130016` | 500 | 500 | `TelefoneInputFormatter.formatEditUpdate` (SIM) | **PASSOU** |
| **P05** | Geração e Encoding de URI de E-mail | Flutter | `130017` | 200 | 200 | `ServicoLinksExternos.uriEmail` (SIM) | **PASSOU** |
| **P06** | Invariantes de Estado dos Providers (loading/error) | Flutter | Determinístico | N/A | N/A | `NoticiaNotifier`, `CarteiraNotifier` (SIM) | **PASSOU** |
| **P07** | Invariante de Reset Atômico de Sessão | Flutter | Determinístico | N/A | N/A | `sessionResetProvider` (SIM) | **PASSOU** |
| **P08** | Mapeamento de Exceções e Supressão de Trace | Backend | `130013` | 500 | 500 | `ApiExceptionHandler.createProblemDetail` (SIM) | **PASSOU** |
| **P09** | Hash SHA-256 e Normalização de Plataforma FCM | Backend | `130013` | 500 | 500 | `DispositivoFcmService.registrar` (SIM) | **PASSOU** |

- **Property Loop Iterations:** **2.500 iterações** de loop parametrizadas
- **Generated Randomized / Property Cases:** **3.000 casos gerados** (100 + 200 + 1.000 + 500 + 200 + 500 + 500)
- **Cenários Determinísticos:** P06 e P07 validados separadamente como suítes determinísticas de estado de sessão e provider.

---

## 4. Resumo de Fuzz Testing (Contagem Reconciliada)

A contagem de casos de Fuzz Testing totaliza exatamente **1.934 casos anômalos**, não misturados com os casos de Property-Based Testing:

| ID | Alvo de Fuzzing | Repositório | Seed | Casos de Fuzz | Crashes / OOM | Vulnerabilidades |
|---|---|---|---:|---:|---:|---:|
| **F01** | Caches Locais com JSON Corrompido / Truncado | Flutter | Determinístico | 14 | 0 | 0 |
| **F02** | Strings de Entrada Extremas (0 a 4096 caracteres) | Flutter | `130018` | 100 | 0 | 0 |
| **F03** | Unicode Malicioso, Emojis, RTL e Caracteres de Controle | Flutter | `130019` | 120 | 0 | 0 |
| **F04** | Paginação Numérica, Valores Negativos e Overflows | Flutter | `130020` | 200 | 0 | 0 |
| **F05** | Desserialização Jackson de DTOs do Backend | Backend | `130013` | 500 | 0 | 0 |
| **F06** | Fuzzing de Injeção e Sanitização no ApiExceptionHandler | Backend | `130013` | 500 | 0 | 0 |
| **F07** | Fuzzing de Status HTTP e Bodies no FeignErrorDecoder | Backend | `130013` | 500 | 0 | 0 |
| **Total** | **Suíte Consolidada de Fuzzing** | — | — | **1.934** | **0** | **0** |

---

## 5. Acoplamento com Código de Produção (Auditoria)

- **P03 (CPF):** Exercita a implementação real de validação do aplicativo chamando a API pública `OuvidoriaNotifier.updateIdentificacao(...)` e acionando `OuvidoriaNotifier.nextStep()`, alcançando o algoritmo real `_isValidCPF`. (`SIM`)
- **P04 (Telefone):** Exercita o formatador de produção `TelefoneInputFormatter.formatEditUpdate(...)` com 500 entradas dinâmicas de 10 e 11 dígitos. (`SIM`)
- **P05 (E-mail):** Exercita o helper de produção `ServicoLinksExternos.uriEmail(...)` verificando URL encoding, query strings e integridade estrutural `mailto:`. (`SIM`)
- **P09 (SHA-256 FCM):** Exercita o serviço de produção `DispositivoFcmService.registrar(...)`, intercepta o tokenHash recebido pelo repositório e valida sua equivalência bit a bit contra o `MessageDigest` canônico SHA-256. (`SIM`)
- **F07 (FeignErrorDecoder):** Submete 500 requisições simuladas diretamente a `FeignErrorDecoder.decode(...)` de produção, cobrindo 19 códigos de status HTTP (4xx, 5xx e limites fora de faixa) combinados com 5 classes de corpos de resposta (nulo, vazio, texto padrão, payload repetitivo de até 500 caracteres e strings unicode maliciosas). (`SIM`)

---

## 6. Registro de Riscos Reconciliados

| ID | Descrição Neutra | Impacto | Mitigação / Escopo |
|---|---|---|---|
| **RISCO-Q13-001** | Amostragem de Mutação (Sampled Mutation) restrita a 24 alvos críticos de domínio | Não reflete mutações exaustivas em todas as linhas de código do sistema | Alvos concentraram fluxos críticos: autenticação, sessão, FCM, cache e handlers de exceção. 100% reproduzível via log. |
| **RISCO-Q13-002** | Execução de mutação em worktree temporário manual sem plugin permanente no pom/pubspec | Pipeline padrão de CI não executa mutation testing a cada pull request | Preserva o tempo de build do CI. Bateria pode ser acionada em profile dedicado sob demanda. |
| **RISCO-Q13-003** | Fuzzing executado sobre harnesses unitários, parsers e handlers internos da aplicação | Fuzzing da camada TLS/HTTP real, ingress, proxy e infraestrutura não fez parte do escopo desta Q13 e permanece não aferido | Camadas perimetrais e de transporte devem ser submetidas a ferramentas de DAST/fuzzing perimetral em etapa própria de infraestrutura. |

---

## 7. Portões de Regressão Consolidados

- **Flutter Analyze:** `0 issues found!` (`flutter analyze --no-pub`)
- **Flutter Testes:** `242/242 tests passed!` (`flutter test --no-pub`)
- **Security Gates:** `secret_scan.sh` e `security_regression.sh` verdes
- **Backend Testes:** `169/169 tests passed!` (`restapi-common`: 11, `mobile-service`: 158)
- **Backend Pacote:** `mvn package -DskipTests` com BUILD SUCCESS
- **Arquivo Concorrente Histórico:** `Q6ConcorrenciaIntegridadeTest.java` 100% íntegro e sem qualquer alteração

---

## 8. Estado Git e Preservação de Baseline

- **Repositório Flutter:** Branch `qualidade/q13-mutation-property-fuzz`, alteração preexistente em `pubspec.yaml` (`4.0.0+69` $\to$ `4.0.0+72`) rigorosamente preservada fora do escopo.
- **Repositório Backend:** Branch `qualidade/q13-mutation-property-fuzz`, working tree sem mutações residuais.
- **Worktrees Temporários:** Desmontados e removidos (`app_mppb_flutter_q13_mut` e `restapi_q13_mut`).
- **Diretriz de Versionamento:** Nenhum commit, nenhum push, nenhum merge realizado.
