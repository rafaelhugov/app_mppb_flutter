# Q8 — Rastreabilidade Transversal de Qualidade, Integridade e Performance (Q8-R01)

Data: 2026-09-30  
Branch: `qualidade/q8-performance-carga`  
Objetivo: Garantir a rastreabilidade ponta-a-ponta entre os Requisitos Funcionais (RF), Integração Q4, E2E Q5, Integridade Q6, Rede Q7 e as métricas de Performance Q8, incorporando as correções metodológicas da rodada Q8-R01.

---

## 1. Matriz de Rastreabilidade Ponta a Ponta

| Requisito Funcional (RF) | Q4 Integração | Q5 E2E | Q6 Integridade | Q7 Rede / Offline | Q8 Performance & Carga (Q8-R01) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RF-01: Autenticação** | `AuthRepository` + interceptor | Fluxo Login/Logout | Q6-OP-01 (duplo toque), Q6-OP-02 (logout atômico) | Q7-MAT-13 (401 expira), Q7-MAT-14 (403 preserva) | **Q8-OP-15**: Bloqueado para carga ativa (proteção contra brute force / lock de conta em produção) |
| **RF-02: Notícias Públicas** | `NoticiasProvider` + parser | Jornada Home → Notícias | Q6-OP-23 (debouncing refresh) | Q7-MAT-01 (offline), Q7-MAT-04 (retry), Q7-MAT-05 (preserva lista) | **Q8-MAT-02 / Q8-MAT-09**: 3.285 RPS no harness; 125 frames analisados em PROFILE (Galaxy A52) com 0% jank >16,6ms sob scroll contínuo |
| **RF-03: Perfil do Usuário** | `PerfilNotifier` + storage | Tela de Perfil | Q6-OP-14 (isolamento usuário) | Q7-MAT-08 (cache seguro), Q7-MAT-17 (sem leak pós-dispose) | **Q8-OP-03**: Validação de Bearer sob carga de 200 VUs no harness sintético |
| **RF-04: Carteira Funcional** | `CarteiraNotifier` + JCR | Exibição Carteira e QR | Q6-OP-15/16 (dados e foto) | Q7-MAT-09 (renderização offline local) | **Q8-OP-04**: Retorno de payload de carteira em < 1ms no harness sob concorrência |
| **RF-05: Contracheque** | `ContraChequeNotifier` + stream | Seleção e PDF | Q6-OP-17/18/19 (concorrência de ano) | Q7-MAT-10 (timeout), Q7-MAT-11 (download sem corrupção) | **Q8-MAT-14**: Download em streaming direto verificado no código; impacto runtime não medido isoladamente (**PARCIAL**) |
| **RF-06: Pagamentos** | `PagamentosNotifier` + DTO | Seleção de exercício | Q6-OP-20/21 (corrida de anos) | Q7-MAT-10 (receiveTimeout controlado) | **Q8-OP-06/07**: Consulta de exercícios e detalhamento mensal em p95 1,13ms no harness |
| **RF-07: Designações** | `DesignacoesNotifier` | Listagem e filtros | Q6-OP-22 (filtros simultâneos) | Q7-MAT-01 (erro amigável), Q7-MAT-04 (retry) | **Q8-OP-11**: Listagem filtrável com estabilidade sob concorrência |
| **RF-08: Concessões RH** | `ConcessoesNotifier` + MPVirtual | Gestão de afastamentos | Q6-OP-06 a 13 (`RISCO-Q6-001`) | Q7-MAT-12 (sem retry automático), Q7-MAT-19 (503 controlado) | **Q8-OP-12/13**: Consultas isoladas com mocks para proteger MPVirtual corporativo |
| **RF-09: Diário Oficial** | `DiarioOficialNotifier` | Busca e PDF | Q6-OP-24 (filtros concorrentes) | Q7-MAT-01 (busca amigável), Q7-MAT-11 (stream PDF) | **Q8-MAT-11**: Navegação repetida na UI em PROFILE sem vazamento de heap (M0 a M4 estabilizados) |
| **RF-10: Certidão Extrajudicial**| `CertidaoNotifier` | Consulta e emissão | Q6-OP-25 (consulta), Q6-OP-26 (emissão) | Q7-MAT-01 (falha de rede), Q7-MAT-12 (sem auto-retry) | **Q8-OP-22**: Bloqueado para carga ativa para prevenir emissão indevida |
| **RF-11: Ouvidoria** | `OuvidoriaRepository` | Envio de manifestação | Q6-OP-27 (efeito real) | Q7-MAT-12 (preserva formulário em falha) | **Q8-OP-23**: Bloqueado para carga ativa para preservar protocolo institucional |
| **RF-12: Notificações FCM** | `DeviceRegistrationNotifier` | Registro background | Q6-OP-03/04/05 (idempotência no DB) | Q7-MAT-01 (offline não bloqueia startup) | **Q8-OP-24**: Registro concorrente com UUIDs únicos em < 1ms no harness |
| **RF-13: Conectividade / Health**| `ConnectivityNotifier` | Probe de internet | Q6-OP-02/05 | Q7-MAT-06/07 (transição offline/online) | **Q8-OP-01 / Q8-MAT-01**: Health probe responde a 21k RPS sob stress no harness |

---

## 2. Riscos Arquiteturais Mapeados (Q8-R01)

- **`RISCO-Q8-001 — CAPACIDADE DE PRODUÇÃO NÃO AFERIDA`**:
  - *Contexto*: Em conformidade estrita com a regra mandatória de segurança, nenhum tráfego de carga foi direcionado contra a infraestrutura de produção (`https://aplicativo-api.mppb.mp.br`) ou contra serviços corporativos reais (Autenticação, MPVirtual, JCR, Firebase).
  - *Impacto*: A capacidade real de produção, com balanceadores de carga, firewalls, redes corporativas e bancos Oracle/PostgreSQL corporativos não foi aferida.
- **`RISCO-Q8-002 — REPRESENTATIVIDADE DO HARNESS DE CARGA`**:
  - *Contexto*: Os testes de carga, stress, spike e soak foram executados utilizando o servidor controlado `Q8PerformanceServer` (`com.sun.net.httpserver.HttpServer` com Jackson ObjectMapper e 200 threads). O tráfego k6 não passou pela stack real Spring Boot do `mobile-service` (Spring MVC, DispatcherServlet, Tomcat embarcado, Spring Security Filters, interceptors).
  - *Impacto*: As métricas obtidas (21.984 RPS, latência p95 de 2,15 ms) pertencem estritamente ao harness sintético local e **não podem ser extrapoladas como capacidade real do backend Spring Boot nem de produção**.
- **`RISCO-Q7-001` (Preservado — Governança de Timeout Feign)**:
  - *Contexto*: Clientes Feign corporativos necessitam de parametrização explícita de timeouts na stack Spring corporativa.
- **`RISCO-Q6-001` (Preservado — Idempotência MPVirtual)**:
  - *Contexto*: Operações mutáveis corporativas de RH não possuem `Idempotency-Key` no downstream corporativo.

---

## 3. Bugs de Infraestrutura e Ferramental Registrados

- **`BUG-Q8-HARNESS-001 — FALHA DE PARSING NO COLETOR DE MEMÓRIA POWERSHELL`**:
  - *Identificação*: Na rodada inicial da Q8, o coletor PowerShell de `dumpsys meminfo` gerou métricas absurdas (`0.12 MB` para baseline e pós-navegação), enquanto os dumps brutos registravam ~455.453 KB e ~490.022 KB.
  - *Causa Raiz*: Em PowerShell, a sintaxe `$array -match regex` aplicada sobre um array de linhas retorna as linhas correspondentes, mas **não popula** os grupos de captura da variável automática `$Matches` por linha; em vez disso, o script reutilizou indevidamente o valor de `$Matches[1]` pré-existente no escopo (valor 123 do loop de warm start anterior: `123 / 1024 = 0.12 MB`).
  - *Correção*: Implementado parsing determinístico linha a linha com `Select-String -Pattern 'TOTAL PSS:\s*(\d+)' | Select-Object -First 1`, casado explicitamente contra `$linha.Line -match` e adicionada validação de sanidade obrigatória (`if ($val -le 50) { throw "TOTAL PSS inválido" }`).
  - *Classificação*: Bug exclusivo do harness/script de teste, sem impacto no código do aplicativo.
