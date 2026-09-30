# Q6 - Inventário de Operações Suscetíveis a Concorrência, Idempotência e Integridade

Data: 2026-09-29  
Branch: `qualidade/q6-concorrencia-integridade`  
Objetivo: Mapeamento de todas as operações e fluxos do App MPPB e Backend quanto a mutabilidade, repetibilidade, efeitos externos, mecanismos de proteção existentes e riscos de integridade.

---

## 1. Classificação das Operações

Critérios formais:
- **IDEMPOTENTE**: Operações cuja execução repetida N vezes produz o mesmo efeito no sistema que uma única execução.
- **NÃO IDEMPOTENTE**: Operações cuja repetição pode duplicar registros, gerar cobranças/solicitações indevidas ou corromper o estado de negócio.
- **IDEMPOTÊNCIA DESCONHECIDA**: Operações dependentes de sistemas legados ou terceiros cuja garantia de idempotência não é formalmente documentada ou governada.
- **SOMENTE LEITURA**: Operações que não modificam estado no servidor (consultas seguras).
- **BLOQUEADO**: Operações institucionais com efeito externo real ou restrições de credencial/captcha cujo disparo real não é autorizado em automação.

---

## 2. Matriz de Inventário de Concorrência

| ID | Fluxo / Módulo | Operação | Mutável? | Pode Repetir? | Efeito Externo? | Proteção Atual | Classificação | Risco Concorrencial |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| **Q6-OP-01** | Autenticação | Login (`POST /acesso/autoriza`) | Sim (sessão) | Não | Sim (Auth API) | UI: `authState.isLoading` desabilita botão "Entrar" | IDEMPOTÊNCIA DESCONHECIDA | Duplo clique rápido antes do primeiro frame de loading; concorrência de múltiplos logins simultâneos |
| **Q6-OP-02** | Autenticação | Logout (`logout()`) | Sim (local/FCM) | Sim | Sim (Desativa FCM) | Limpeza atômica local em secure storage e reset de estado | IDEMPOTENTE | Logout executado enquanto requisição autenticada assíncrona está em trânsito |
| **Q6-OP-03** | Notificações FCM | Registro Dispositivo (`POST /notificacoes/dispositivos`) | Sim (DB) | Sim | Não | Backend: `findByTokenHash` reutiliza registro existente; chave única de identificador | IDEMPOTENTE | Múltiplas threads registrando o mesmo token ou identificador em simultâneo |
| **Q6-OP-04** | Notificações FCM | Desativação Dispositivo (`DELETE /notificacoes/dispositivos/{id}`) | Sim (DB) | Sim | Não | Backend: `UPDATE ... SET ativo = FALSE` (idempotente por SQL) | IDEMPOTENTE | Desativação de dispositivo já desativado ou concorrente com rotação de token |
| **Q6-OP-05** | Notificações FCM | Diagnóstico (`POST /notificacoes/dispositivos/diagnostico`) | Não (apenas log) | Sim | Não | Endpoint assíncrono que apenas registra telemetria | SOMENTE LEITURA | Sobrecarga de chamadas em falha repetitiva de token |
| **Q6-OP-06** | Recursos Humanos | Solicitação de Gozo de Férias (`POST /recursos-humanos/concessoes/{id}/solicitacoes`) | Sim | Não | Sim (MPVirtual) | UI: `_isSubmitting` no card de concessão; Backend: proxy simples sem `Idempotency-Key` | NÃO IDEMPOTENTE | Duplo clique na UI ou retry de rede pode duplicar solicitação se o MPVirtual não travar |
| **Q6-OP-07** | Recursos Humanos | Adiamento de Férias (`POST /recursos-humanos/solicitacoes/{id}/adiamentos`) | Sim | Não | Sim (MPVirtual) | UI: `_isExecuting` na sheet de ações; Backend: proxy simples | NÃO IDEMPOTENTE | Repetição de adiamento de solicitação já adiada ou concorrente |
| **Q6-OP-08** | Recursos Humanos | Antecipação de Férias (`POST /recursos-humanos/solicitacoes/{id}/antecipacoes`) | Sim | Não | Sim (MPVirtual) | UI: `_isExecuting` na sheet de ações; Backend: proxy simples | NÃO IDEMPOTENTE | Repetição de antecipação concorrente |
| **Q6-OP-09** | Recursos Humanos | Cancelamento de Férias (`POST /recursos-humanos/solicitacoes/{id}/cancelamentos`) | Sim | Sim | Sim (MPVirtual) | UI: `_isExecuting`; MPVirtual valida se solicitação já está cancelada | NÃO IDEMPOTENTE | Corrida entre cancelamento e processamento do RH |
| **Q6-OP-10** | Recursos Humanos | Suspensão Integral (`POST /recursos-humanos/solicitacoes/{id}/suspensoes-integrais`) | Sim | Não | Sim (MPVirtual) | UI: `_isExecuting`; Backend: proxy simples | NÃO IDEMPOTENTE | Concorrência de envio duplicado |
| **Q6-OP-11** | Recursos Humanos | Suspensão Parcial (`POST /recursos-humanos/solicitacoes/{id}/suspensoes-parciais`) | Sim | Não | Sim (MPVirtual) | UI: `_isExecuting`; Backend: proxy simples | NÃO IDEMPOTENTE | Concorrência de envio duplicado com datas parciais |
| **Q6-OP-12** | Recursos Humanos | Listar Concessões (`GET /recursos-humanos/minhas-concessoes-folga`) | Não | Sim | Sim (MPVirtual) | Consulta via GET com autenticação | SOMENTE LEITURA | Sobrescrita de lista desatualizada se requests concorrentes responderem fora de ordem |
| **Q6-OP-13** | Recursos Humanos | Listar Ausências Calendário (`GET /recursos-humanos/minhas-ausencias`) | Não | Sim | Sim (MPVirtual) | Consulta via GET com mês/ano | SOMENTE LEITURA | Alternância rápida de meses responder fora de ordem |
| **Q6-OP-14** | Perfil | Carregar Perfil (`GET /api/perfil/dados`) | Não | Sim | Não | Armazena em secure storage com identificação de username | SOMENTE LEITURA | Resposta tardia sobrescrever estado após logout ou troca de usuário |
| **Q6-OP-15** | Carteira Funcional | Carregar Carteira (`GET /carteiras-funcionais/dados`) | Não | Sim | Não | Armazena em secure storage com identificação de username | SOMENTE LEITURA | Ausência de checagem pós-dispose e sobrescrita pós-logout |
| **Q6-OP-16** | Carteira Funcional | Foto Funcional (`GET /carteiras-funcionais/foto`) | Não | Sim | Não | Cache de imagem | SOMENTE LEITURA | Concorrência de múltiplos downloads simultâneos da mesma imagem |
| **Q6-OP-17** | Contracheque | Listar Exercícios (`GET /contracheque/exercicios`) | Não | Sim | Não | Consulta via GET | SOMENTE LEITURA | Concorrência de inicialização |
| **Q6-OP-18** | Contracheque | Listar Meses (`GET /contracheque/exercicio/{ano}`) | Não | Sim | Não | Consulta via GET | SOMENTE LEITURA | Alternância rápida de anos responder fora de ordem |
| **Q6-OP-19** | Contracheque | Download PDF (`GET /contracheque/{ano}/{mes}/pdf`) | Não | Sim | Não | Retorna bytes PDF | SOMENTE LEITURA | Duplo clique no download gerar downloads paralelos e corromper arquivo local |
| **Q6-OP-20** | Pagamentos | Listar Exercícios (`GET /pagamentos/exercicios`) | Não | Sim | Não | Consulta via GET | SOMENTE LEITURA | Concorrência de inicialização |
| **Q6-OP-21** | Pagamentos | Dados de Pagamentos (`GET /pagamentos/{ano}`) | Não | Sim | Não | Consulta via GET | SOMENTE LEITURA | Alternância rápida de anos (`mudarExercicio`/`selecionarExercicio`) responder fora de ordem |
| **Q6-OP-22** | Designações | Listar Designações (`GET /designacoes`) | Não | Sim | Não | Consulta via GET | SOMENTE LEITURA | Filtros rápidos aplicados em simultâneo |
| **Q6-OP-23** | Notícias | Listar Notícias (`GET /api/public/noticias`) | Não | Sim | Não | Consulta pública via GET | SOMENTE LEITURA | Duplo refresh simultâneo ou paginação/busca concorrente |
| **Q6-OP-24** | Diário Oficial | Listar Edições (`GET /diario-oficial/...`) | Não | Sim | Não | Consulta pública via GET | SOMENTE LEITURA | Requisições paralelas com filtros de data |
| **Q6-OP-25** | Certidão Extrajudicial | Consulta de Código (`GET /certidao-extrajudicial/...`) | Não | Sim | Não | Consulta pública via GET | SOMENTE LEITURA | Duplo clique em "Consultar" |
| **Q6-OP-26** | Certidão Extrajudicial | Emissão PDF (`POST /certidao-extrajudicial/emitir`) | Sim | Não | Sim | Operação institucional com efeito externo | BLOQUEADO | Emissão com efeito institucional real |
| **Q6-OP-27** | Ouvidoria | Enviar Manifestação (`POST /ouvidoria/manifestacao`) | Sim | Não | Sim | Operação institucional com efeito externo | BLOQUEADO | Envio real com efeito institucional externo |
| **Q6-OP-28** | Processos | Consulta com Captcha | Não | Sim | Sim | Requer validação de Captcha | BLOQUEADO | Bypass automatizado de Captcha |

---

## 3. Síntese Quantitativa

- **Total de Operações Inventariadas**: 28
- **Mutáveis**: 10 (FCM Registrar, FCM Desativar, Login, Logout, Solicitar Férias, Adiar, Antecipar, Cancelar, Suspender Int., Suspender Parc.)
- **Somente Leitura**: 15 (Notícias, Pagamentos Exercícios/Dados, Contracheque Exercícios/Meses/PDF, Carteira Dados/Foto, Perfil, Concessões, Ausências, Designações, Diário, Certidão Consulta, FCM Diagnóstico)
- **Idempotentes Comprovadas**: 3 (FCM Registrar, FCM Desativar, Logout)
- **Não Idempotentes**: 6 (Solicitar Férias, Adiar, Antecipar, Cancelar, Suspender Integral, Suspender Parcial)
- **Idempotência Desconhecida / Não Governada**: 1 (Login no Auth API externo)
- **Bloqueadas por Efeito Externo / Captcha**: 3 (Certidão Emissão, Ouvidoria Enviar, Processos Captcha)
