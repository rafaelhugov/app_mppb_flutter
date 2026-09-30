# Q6 — Matriz de Rastreabilidade Vertical de Qualidade

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Ciclo: Qualidade, Confiabilidade e Prontidão do App MPPB  

---

## 1. Visão Geral de Rastreabilidade

Esta matriz conecta os Requisitos Funcionais (RF) fundamentais do App MPPB através de todas as camadas de validação consolidadas no ciclo de qualidade:

```text
Requisito Funcional (RF)
  └── Q2: Teste de Componente / Unitário / Widget
        └── Q3: Contrato de API / DTOs
              └── Q4: Integração Controlada
                    └── Q5: End-to-End em Dispositivo Físico
                          └── Q6: Concorrência, Idempotência e Integridade
```

---

## 2. Rastreabilidade por Requisito Funcional

| RF | Descrição | Q2 (Componente) | Q3 (Contrato) | Q4 (Integração) | Q5 (E2E) | Q6 (Concorrência / Idempotência / Integridade) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **RF-01** | Autenticação de Usuário e Gestão de Sessão | `auth_provider_test.dart` | `POST /acesso/autoriza` | `testAcessoAutorizaSuccess` | Validação de credenciais / Guards públicos | **Q6-CEN-01**: Prevenção de duplo clique via `state.isLoading`; **Q6-CEN-06**: Logout com request em trânsito; **Q6-CEN-07**: Troca de usuário e purga de cache seguro. |
| **RF-02** | Registro e Gestão de Notificações FCM | `device_registration_provider_test.dart` | `POST /api/notificacoes/dispositivos` | `testRegistroDispositivoSuccess` | Inicialização FCM e delegates push | **Q6-CEN-02**: Identificador estável `UUIDv4`; **Q6-CEN-08**: Deduplicação de push por `messageKey`; **Q6-CEN-12**: Registro concorrente atômico; **Q6-CEN-13**: Desativação idempotente; **Q6-CEN-15**: Constraint por `tokenHash`. |
| **RF-03** | Carteira Funcional do Membro/Servidor | `carteira_provider_test.dart` | `GET /carteiras-funcionais/dados` | Contrato DTO Carteira Funcional | Visualização de dados e cache offline | **Q6-CEN-03**: Requisições simultâneas sem duplicação; **Q6-CEN-06**: Sem vazamento pós-logout; **Q6-CEN-11**: Concorrência de leitura isolada. |
| **RF-04** | Perfil do Usuário e Dados Cadastrais | `perfil_provider_test.dart` | `GET /api/perfil/dados` | `testBuscarPerfilSuccess` | Card e sheet de Perfil | **Q6-CEN-05**: Sem exceção em dispose (`ref.mounted`); **Q6-CEN-07**: Purga de cache no logout; **Q6-CEN-16**: Múltiplas threads de leitura no backend. |
| **RF-05** | Consulta de Pagamentos e Transparência | `pagamentos_provider_test.dart` | `GET /pagamentos/{ano}` | `testBuscarPagamentosSuccess` | Navegação na lista de pagamentos | **Q6-CEN-04**: Respostas fora de ordem não corrompem ano selecionado; **Q6-CEN-16**: Concorrência de leitura com CPFs distintos no backend. |
| **RF-06** | Consulta de Contracheque e Emissão PDF | `contra_cheque_provider_test.dart` | `GET /contracheque/{ano}/{mes}/pdf` | Contrato PDF Contracheque | Download e visualização de PDF | **Q6-CEN-09**: Downloads simultâneos de PDF retornam streams íntegros sem corrupção de bytes. |
| **RF-07** | Notícias Institucionais do MPPB | `noticia_provider_test.dart` | `GET /api/public/noticias` | Feed de notícias integradas | Jornada E2E Física `Home -> Notícias -> Home` | **Q6-CEN-10**: Filtros concorrentes e buscas rápidas convergem para o último termo digitado. |
| **RF-08** | Solicitação e Gestão de Férias (RH) | `concessao_afastamento_provider_test.dart` | `POST /recursos-humanos/concessoes/...` | Proxy MPVirtual | Ações nas sheets de concessão | **Q6-CEN-17**: Bloqueio de duplo clique na UI (`_isSubmitting`); Idempotência externa documentada em `RISCO-Q6-001`. |

---

## 3. Avaliação de Cobertura

- Todas as 8 jornadas críticas possuem cobertura de componente (Q2), contrato (Q3), integração (Q4) e concorrência/integridade (Q6).
- Os cenários públicos principais contam adicionalmente com validação E2E automatizada em hardware físico Android (Q5).
- A rastreabilidade vertical comprova que as correções mínimas implementadas em Q6 (`PagamentosNotifier`, `CarteiraNotifier`, `PerfilNotifier`, `AuthNotifier`) fortaleceram os requisitos funcionais sem alterar contratos existentes.
