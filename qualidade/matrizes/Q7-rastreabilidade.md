# Q7 — Rastreabilidade: Requisitos, Contratos, Integrações, E2E, Integridade e Resiliência de Rede

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  
Objetivo: Garantir a rastreabilidade ponta-a-ponta entre os Requisitos Funcionais (RF), Contratos Q3, Integrações Q4, E2E Q5, Integridade Q6 e o comportamento diante de falhas de rede, indisponibilidade e interrupções em Q7.

---

## 1. Tabela de Rastreabilidade Transversal

| Requisito Funcional (RF) | Q3 Contrato | Q4 Integração | Q5 E2E | Q6 Concorrência & Integridade | Q7 Falha de Rede & Recuperação |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RF-01: Autenticação** | `POST /acesso/autoriza`<br>Token JWT / Refresh | `AuthRepository` + interceptor | Fluxo Login / Logout E2E | Q6-OP-01 (duplo clique login), Q6-OP-02 (logout atômico) | Q7-MAT-13 (401 força logout), Q7-MAT-14 (403 não faz logout indevido), Q7-MAT-01 (erro de conexão sem crash) |
| **RF-02: Notícias Públicas** | `GET /api/public/noticias` | `NoticiasProvider` + parser | Jornada Home → Notícias (Smoke & E2E) | Q6-OP-23 (refresh concorrente / debouncing) | Q7-MAT-01 (offline antes da chamada), Q7-MAT-02 (queda durante request), Q7-MAT-04 (retry seguro), Q7-MAT-05 (preserva lista no refresh com falha), Q7-MAT-16 (JSON malformado) |
| **RF-03: Perfil do Usuário** | `GET /api/perfil/dados` | `PerfilNotifier` + storage | Tela de Perfil autenticada | Q6-OP-14 (isolamento de usuário / dispose) | Q7-MAT-08 (leitura do cache seguro offline), Q7-MAT-17 (sem update pós-dispose) |
| **RF-04: Carteira Funcional** | `GET /carteiras-funcionais/dados`<br>`GET /carteiras-funcionais/foto` | `CarteiraNotifier` + JCR | Exibição de carteira e QR code | Q6-OP-15 (dados), Q6-OP-16 (foto) | Q7-MAT-09 (renderização offline via cache local), Q7-MAT-11 (download interrompido de foto/PDF) |
| **RF-05: Contracheque** | `GET /contracheque/exercicios`<br>`GET /contracheque/exercicio/{ano}`<br>`GET /contracheque/{ano}/{mes}/pdf` | `ContraChequeNotifier` + stream | Seleção de mês e visualização | Q6-OP-17/18/19 (alternância de ano / download simultâneo) | Q7-MAT-10 (timeout de resposta), Q7-MAT-11 (download de PDF interrompido sem arquivo corrompido), Q7-MAT-04 (retry manual) |
| **RF-06: Pagamentos** | `GET /pagamentos/exercicios`<br>`GET /pagamentos/{ano}` | `PagamentosNotifier` + DTO | Seleção de exercício de pagamentos | Q6-OP-20/21 (corrida de exercícios) | Q7-MAT-10 (timeout controlado), Q7-MAT-15 (503 com card de erro amigável), Q7-MAT-04 (retry seguro) |
| **RF-07: Designações** | `GET /designacoes` | `DesignacoesNotifier` | Listagem e filtros | Q6-OP-22 (filtros concorrentes) | Q7-MAT-01 (offline com feedback amigável), Q7-MAT-04 (retry manual) |
| **RF-08: Concessões e Férias (RH)** | `GET /recursos-humanos/...`<br>`POST /recursos-humanos/...` | `ConcessoesNotifier` + MPVirtual | Gestão de férias e afastamentos | Q6-OP-06 a 13 (`RISCO-Q6-001`: ausência de Idempotency-Key) | Q7-MAT-12 (MUTAÇÃO NÃO RETRY AUTOMÁTICO em falha de rede), Q7-MAT-19 (Backend traduz falha do MPVirtual em 503) |
| **RF-09: Diário Oficial** | `GET /diario-oficial/edicoes` | `DiarioOficialNotifier` | Busca e visualização de PDF | Q6-OP-24 (filtros simultâneos) | Q7-MAT-01 (erro controlado de busca), Q7-MAT-11 (download interrompido de edição PDF) |
| **RF-10: Certidão Extrajudicial** | `GET /certidao-extrajudicial/...`<br>`POST /certidao-extrajudicial/emitir` | `CertidaoNotifier` | Consulta pública e emissão | Q6-OP-25 (consulta), Q6-OP-26 (emissão bloqueada) | Q7-MAT-01 (falha de rede na consulta), Q7-MAT-12 (sem retry automático na emissão) |
| **RF-11: Ouvidoria** | `POST /ouvidoria/manifestacao` | `OuvidoriaRepository` | Formulário de manifestação | Q6-OP-27 (envio com efeito real) | Q7-MAT-12 (sem retry automático; preserva campos digitados pelo cidadão em memória) |
| **RF-12: Notificações FCM** | `POST /notificacoes/dispositivos`<br>`DELETE /notificacoes/dispositivos/{id}` | `DeviceRegistrationNotifier` | Registro em background | Q6-OP-03/04/05 (idempotência no DB) | Q7-MAT-01 (offline não bloqueia inicialização; token preservado localmente para posterior envio) |
| **RF-13: Conectividade do App** | `GET /api/public/health` | `ConnectivityNotifier` | Indicador visual de rede (banner/badge) | Q6-OP-02/05 | Q7-MAT-06 (inicialização sem internet), Q7-MAT-07 (reconexão automática com poll periódico) |

---

## 2. Riscos Transversais Identificados

- **`RISCO-Q6-001` (Preservado e Revalidado em Q7)**:
  - *Contexto*: Operações mutáveis de RH delegadas ao MPVirtual (`/solicitacoes`, `/adiamentos`, `/antecipacoes`, `/cancelamentos`, `/suspensoes`) não implementam mecanismo de deduplicação por `Idempotency-Key` no backend nem no MPVirtual.
  - *Impacto em Q7*: Se a conexão de rede for interrompida após o cliente enviar o pacote HTTP mas antes de receber a resposta (ou durante timeout de recebimento), o estado no MPVirtual torna-se incerto.
  - *Mitigação Confirmada*: O App MPPB NÃO implementa nenhum mecanismo de retry automático em operações mutáveis de RH. Qualquer repetição deve ser uma ação consciente do usuário após checagem do status.

- **`RISCO-Q7-001` (Governança de Timeout em Clientes Feign)**:
  - *Contexto*: Os clientes Feign (`AuthServiceClient`, `MPVirtualClient`) não possuem timeout explicitamente governado na configuração da aplicação; portanto, o comportamento depende da configuração/default efetivamente aplicada pela stack utilizada.
  - *Comprovação*: Foi comprovado que, quando uma exceção `RetryableException` de timeout é gerada, o `ApiExceptionHandler` a traduz com segurança em HTTP 503 com ProblemDetail padronizado. No entanto, o tempo real de retenção de socket congelado permanece dependente dos defaults subjacentes.
