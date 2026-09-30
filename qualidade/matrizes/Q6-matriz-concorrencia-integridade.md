# Q6 — Matriz de Concorrência, Idempotência e Integridade

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Ciclo: Fase Q6 — Concorrência, Idempotência e Integridade  

---

## 1. Critérios de Avaliação

- **PASSOU**: Comportamento concorrente/idempotente comprovado por teste automatizado determinístico.
- **FALHOU**: Falha comprovada com inconsistência ou quebra de integridade.
- **PARCIAL**: Proteção local existente na camada cliente/proxy, mas sem garantia formal ponta-a-ponta de idempotência institucional no sistema legado de destino (documentado como risco).
- **BLOQUEADO**: Operação institucional com efeito real ou restrição de captcha fora do escopo de automação.
- **N/A**: Não aplicável ao cenário.

---

## 2. Matriz de Testes e Cenários

| ID | Fluxo | Cenário | Esperado | Resultado | Proteção | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **Q6-CEN-01** | Autenticação | Duplo toque rápido no login (`POST /acesso/autoriza`) | Loading imediato bloqueia segundo envio; exatamente 1 chamada HTTP disparada | 1 requisição disparada, loading bloqueia segundo toque concorrente | `AuthNotifier.login` valida `state.isLoading` | **PASSOU** |
| **Q6-CEN-02** | Notificações FCM | Duplo registro de dispositivo cliente quase simultâneo | Reutilização do identificador único estável da instalação (`UUIDv4`) sem criar novos devices | Mesmo identificador reutilizado nas requisições consecutivas | `DeviceRegistrationStore.getOrCreateInstallationId` | **PASSOU** |
| **Q6-CEN-03** | Carteira Funcional | Duas requisições simultâneas de carregamento de carteira | Ambas convergem para os dados corretos sem duplicação de entidades | Estado final íntegro, sem concorrência destrutiva | `CarteiraNotifier.fetchCarteira` | **PASSOU** |
| **Q6-CEN-04** | Pagamentos | Respostas fora de ordem (exercício 2024 responde depois de 2023) | Resposta tardia fora de ordem de 2024 não sobrescreve a escolha mais recente (2023) | Estado final exibe dados estritamente do exercício 2023 | Guard `state.exercicioAtual == exercicioRequisitado` | **PASSOU** |
| **Q6-CEN-05** | Perfil / Auth | Dispose de provider/widget durante requisição ou inicialização em trânsito | Resposta tardia/leitura tratada sem exceção `Ref after dispose` ou crash | Operações finalizam sem exceção ou vazamento pós-dispose | `if (!ref.mounted) return;` em `PerfilNotifier` e `AuthNotifier` (BUG-Q6-004) | **PASSOU** |
| **Q6-CEN-06** | Autenticação / Carteira | Logout efetuado enquanto request autenticada estava em trânsito | Dados da sessão deslogada não aparecem no estado público | `state.data` nulo e `isAuthenticated == false` | Guard de validação de token atual no retorno da API | **PASSOU** |
| **Q6-CEN-07** | Sessão | Troca de Usuário A -> Logout -> Usuário B | Cache do usuário A purgado; sem vazamento de dados confidenciais para B | Cache purgado no storage seguro; isolamento total | `AuthNotifier.logout` e `_limparDadosLocaisSeTrocarUsuario` | **PASSOU** |
| **Q6-CEN-08** | Notificações FCM | Duplicação de notificação push recebida/aberta | Apenas uma ação de navegação disparada para a mesma notificação | Navegação executada uma única vez; segundo evento ignorado | `PushNavigationService._markOpenedMessageAsPending` | **PASSOU** |
| **Q6-CEN-09** | Contracheque | Download de PDF em requisições concorrentes | Ambos os fluxos recebem os bytes íntegros sem corrupção | Bytes idênticos e corretos em ambas as respostas | Download stateless via Dio sem colisão de buffer | **PASSOU** |
| **Q6-CEN-10** | Notícias | Filtros rápidos concorrentes digitados em sequência rápida | O estado final converge para o último termo digitado | Termo final 'concurso' aplicado sem efeito fora de ordem | State mutation síncrona/reativa no notifier | **PASSOU** |
| **Q6-CEN-11** | Concorrência de Leitura | Múltiplas leituras paralelas de perfil e carteira com tokens distintos | Cada requisição mantém seu próprio token nos cabeçalhos | Tokens e respostas isolados por requisição | Instâncias locais e headers isolados via Options | **PASSOU** |
| **Q6-CEN-12** | Backend FCM | Múltiplas threads registrando mesmo dispositivo/token concorrentemente | Registros convergem de forma atômica para 1 registro ativo no banco | 1 registro ativo mantido, ambos recebem resposta 200 | Transação + busca por tokenHash/identificador | **PASSOU** |
| **Q6-CEN-13** | Backend FCM | Desativação repetida de dispositivo | Primeira desativação desativa; segunda é idempotente e segura | Retorna `false` sem exceção; entidade permanece inativa | `UPDATE ... WHERE ativo = TRUE` | **PASSOU** |
| **Q6-CEN-14** | Backend FCM | Falha no fluxo transacional de registro (dados inválidos) | Operação falha atomicamente sem deixar registros corrompidos/órfãos | Exceção capturada; zero registros órfãos no banco | `@Transactional` em `DispositivoFcmService` | **PASSOU** |
| **Q6-CEN-15** | Backend FCM | Constraints de unicidade (token já existente para novo device) | Reativação/atualização lógica do registro sem violação de constraint | Registro reativado/atualizado sem erro de chave duplicada | Regra de unicidade por hash e identificador | **PASSOU** |
| **Q6-CEN-16** | Backend Leitura | Concorrência de leitura simultânea em Perfil e Pagamentos | Threads concorrentes com usuários distintos não misturam dados | Respostas 100% isoladas para cada usuário/exercício | Stateless services e repositórios thread-safe | **PASSOU** |
| **Q6-CEN-17** | Recursos Humanos | Solicitação de férias/adiamento/antecipação no MPVirtual | Prevenção de duplicação por retries de rede ou duplo clique | UI bloqueia duplo envio (`_isSubmitting`), backend proxy sem header de idempotência | Bloqueio na UI cliente; Risco institucional formalizado | **PARCIAL** |
| **Q6-CEN-18** | Ouvidoria / Certidão | Envio de manifestação e emissão institucional com efeito real | Requer credencial / captcha / autorização especial | Não executado com credenciais reais em automação | Automação bloqueada por governança de segurança | **BLOQUEADO** |

---

## 3. Síntese dos Resultados

- **Total de Cenários Avaliados**: 18
- **PASSOU**: 16 (88.9%)
- **PARCIAL**: 1 (5.5% — Operações de RH dependentes do MPVirtual legado)
- **BLOQUEADO**: 1 (5.5% — Manifestação Ouvidoria / Emissão Certidão com efeito real)
- **FALHOU**: 0 (0.0%)
