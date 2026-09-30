# Q7 — Inventário de Dependências de Rede, Políticas de Retry e Resiliência Offline

Data: 2026-09-30  
Branch: `qualidade/q7-rede-offline-interrupcoes`  
Objetivo: Mapear todas as integrações de rede do App MPPB e Backend, classificando suas operações quanto a mutabilidade, política de timeouts, comportamento de retry, existência de cache local e tratamento em estado offline ou sob interrupção.

---

## 1. Critérios de Classificação (Q7-T02)

Para cada operação inventariada, foram atribuídas as classificações padronizadas do ciclo Q7:

- **LEITURA SEGURA PARA RETRY**: Consultas idempotentes sem efeitos colaterais. Podem ser repetidas de forma segura após falhas de rede.
- **MUTAÇÃO NÃO RETRY AUTOMÁTICO**: Operações mutáveis de criação/atualização/exclusão (ex: submissões RH, pedidos). O retry automático é estritamente proibido sob risco de duplicação.
- **RETRY CONDICIONAL**: Operações que podem ser repetidas somente sob certas condições ou de forma idempotente controlada (ex: registro FCM, nova tentativa manual pelo usuário com novo captcha).
- **CACHEÁVEL**: Recursos que possuem persistência local (secure storage, cache de imagem, banco local ou estado mantido) e podem ser exibidos ou preservados quando offline.
- **NÃO CACHEÁVEL**: Dados em tempo real, sigilosos ou voláteis que exigem comunicação direta ou cujo cache não foi implementado na arquitetura.
- **DEPENDÊNCIA EXTERNA**: Operações que dependem de sistemas externos ao backend mobile (Auth API institucional, MPVirtual, JCR, Firebase).
- **BLOQUEADA**: Operações institucionais com efeito externo real ou restrição de credencial/captcha cujo disparo arbitrário não é realizado em automação.

---

## 2. Inventário de Dependências de Rede (Q7-T01)

| ID | Fluxo | Endpoint / Dependência | Leitura / Mutação | Timeout | Retry Atual | Cache | Estado Offline / Tratamento | Classificação Q7 |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: | :--- | :--- |
| **Q7-NET-01** | Autenticação | `POST /acesso/autoriza`<br>*(Auth API Institucional)* | Mutação (Sessão) | 15s | Não automático (apenas manual pelo usuário) | Nenhum (apenas armazena token em secure storage após sucesso) | Falha com erro claro de conexão; botão "Entrar" é destravado; sem crash. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-02** | Autenticação | `logout()`<br>*(Local + FCM Delete)* | Mutação | N/A (local) / 15s (FCM) | Retry condicional (descarte de falha remota) | Limpa storage e cache de sessão local | Logout local sempre conclui com sucesso, mesmo sem rede. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, CACHEÁVEL |
| **Q7-NET-03** | Perfil | `GET /api/perfil/dados`<br>*(Mobile API / Perfil)* | Leitura | 15s | Manual via pull-to-refresh ou reload | Secure Storage particionado por username | Se houver cache do mesmo usuário, renderiza dados locais; se ausente, exibe erro e botão de retry. | LEITURA SEGURA PARA RETRY, CACHEÁVEL |
| **Q7-NET-04** | Carteira Funcional | `GET /carteiras-funcionais/dados`<br>*(Mobile API)* | Leitura | 15s | Manual via retry/reload | Secure Storage particionado por username | Renderiza carteira offline com dados locais se existirem; se ausente, exibe erro controlado. | LEITURA SEGURA PARA RETRY, CACHEÁVEL |
| **Q7-NET-05** | Carteira Funcional | `GET /carteiras-funcionais/foto`<br>*(JCR Backend)* | Leitura | 15s | Manual | Cache de imagem em disco/memória | Exibe foto em cache se já baixada; se offline na primeira carga, exibe placeholder institucional. | LEITURA SEGURA PARA RETRY, CACHEÁVEL, DEPENDÊNCIA EXTERNA |
| **Q7-NET-06** | Contracheque | `GET /contracheque/exercicios`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória (durante a sessão) | Exibe estado de erro amigável ("Falha de conexão"), permite retry manual. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-07** | Contracheque | `GET /contracheque/exercicio/{ano}`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória | Exibe mensagem de erro; não trava a navegação de ano; retry manual disponível. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-08** | Contracheque | `GET /contracheque/{ano}/{mes}/pdf`<br>*(Mobile API)* | Leitura (Download) | 15s | Manual | Arquivo temporário sob demanda | Interrupção de rede aborta download; não salva arquivo incompleto; usuário pode tentar novamente. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-09** | Pagamentos | `GET /pagamentos/exercicios`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória | Exibe erro amigável ou lista vazia sem travar loading; permite retry manual. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-10** | Pagamentos | `GET /pagamentos/{ano}`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória | Exibe card de erro; preserva exercícios já listados; retry manual. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-11** | Designações | `GET /designacoes`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória | Exibe mensagem de indisponibilidade com botão de recarregar. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-12** | Recursos Humanos | `GET /recursos-humanos/minhas-concessoes-folga`<br>*(MPVirtual)* | Leitura | 15s | Manual | Em memória | Exibe erro amigável de conexão ou indisponibilidade do MPVirtual; retry manual. | LEITURA SEGURA PARA RETRY, DEPENDÊNCIA EXTERNA |
| **Q7-NET-13** | Recursos Humanos | `GET /recursos-humanos/minhas-ausencias`<br>*(MPVirtual)* | Leitura | 15s | Manual | Em memória | Calendário exibe estado vazio/erro sem crash. | LEITURA SEGURA PARA RETRY, DEPENDÊNCIA EXTERNA |
| **Q7-NET-14** | Recursos Humanos | `POST /recursos-humanos/concessoes/{id}/solicitacoes`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO (Proibido) | Nenhum | Exibe erro na modal/sheet; botão reabilita; proibido retry automático (`RISCO-Q6-001`). | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-15** | Recursos Humanos | `POST /recursos-humanos/solicitacoes/{id}/adiamentos`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro controlado; usuário é alertado; sem reenvio automático. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-16** | Recursos Humanos | `POST /recursos-humanos/solicitacoes/{id}/antecipacoes`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro controlado; sem reenvio automático. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-17** | Recursos Humanos | `POST /recursos-humanos/solicitacoes/{id}/cancelamentos`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro controlado; validação no MPVirtual. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-18** | Recursos Humanos | `POST /recursos-humanos/solicitacoes/{id}/suspensoes-integrais`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro controlado; sem reenvio automático. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-19** | Recursos Humanos | `POST /recursos-humanos/solicitacoes/{id}/suspensoes-parciais`<br>*(MPVirtual)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro controlado; sem reenvio automático. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, DEPENDÊNCIA EXTERNA |
| **Q7-NET-20** | Notícias | `GET /api/public/noticias`<br>*(Mobile API / CMS)* | Leitura | 15s | Manual via pull-to-refresh ou botão | Em memória no provider | Se já há notícias renderizadas, preserva a lista e notifica erro; se primeira carga, exibe erro e botão de retry. | LEITURA SEGURA PARA RETRY, CACHEÁVEL |
| **Q7-NET-21** | Diário Oficial | `GET /diario-oficial/edicoes`<br>*(Mobile API)* | Leitura | 15s | Manual | Em memória | Exibe erro amigável na listagem com opção de nova busca. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-22** | Diário Oficial | Download PDF Edição<br>*(Mobile API / Storage)* | Leitura (Download) | 15s | Manual | Arquivo temporário | Interrupção não gera arquivo corrompido aberto na tela; informa erro ao usuário. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-23** | Processos | `POST /processos/consulta`<br>*(Mobile API + Captcha)* | Leitura / Consulta | 15s | Manual (requer novo Captcha) | Nenhum | Exibe erro de rede; exige nova resolução de Captcha se a conexão cair antes da resposta. | RETRY CONDICIONAL, DEPENDÊNCIA EXTERNA, BLOQUEADA |
| **Q7-NET-24** | Certidão Extrajudicial | `GET /certidao-extrajudicial/consulta`<br>*(Mobile API)* | Leitura | 15s | Manual | Nenhum | Exibe feedback de erro sem crash; usuário pode tentar novamente. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |
| **Q7-NET-25** | Certidão Extrajudicial | `POST /certidao-extrajudicial/emitir`<br>*(Mobile API / Corregedoria)* | Mutação | 15s | NENHUM RETRY AUTOMÁTICO | Nenhum | Erro exibido na UI; operação institucional bloqueada para repetição automática. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, BLOQUEADA |
| **Q7-NET-26** | Ouvidoria | `POST /ouvidoria/manifestacao`<br>*(Mobile API / Ouvidoria)* | Mutação | 30s | NENHUM RETRY AUTOMÁTICO | Formulário em memória | Preserva dados digitados pelo cidadão no formulário para retry manual quando a rede voltar; sem auto-retry. | MUTAÇÃO NÃO RETRY AUTOMÁTICO, BLOQUEADA |
| **Q7-NET-27** | Notificações FCM | `POST /notificacoes/dispositivos`<br>*(Backend Mobile)* | Mutação (Idempotente) | 15s | Automático ou na reconexão | Local (token salvo) | Em caso de falha de rede, não bloqueia a inicialização do app; é reenviado silenciosamente na próxima inicialização. | RETRY CONDICIONAL, CACHEÁVEL |
| **Q7-NET-28** | Notificações FCM | `DELETE /notificacoes/dispositivos/{id}`<br>*(Backend Mobile)* | Mutação (Idempotente) | 15s | Descarte em falha | Nenhum | Se offline, logout local conclui e requisição remota é descartada sem prejudicar o usuário. | RETRY CONDICIONAL |
| **Q7-NET-29** | Conectividade Probe | `GET /api/public/health`<br>*(Probe de Internet)* | Leitura | 4s | Periódico a cada 20s quando offline | Nenhum | Se falhar 3 tentativas, define `connectivityProvider = false`; retesta via timer periódico e eventos de rede. | LEITURA SEGURA PARA RETRY, NÃO CACHEÁVEL |

---

## 3. Síntese Quantitativa

- **Total de Integrações de Rede Mapeadas**: 29
- **Operações de Leitura (Total: 17)**:
  - **Leituras Seguras para Retry (16)**: Perfil, Carteira Dados, Carteira Foto, Contracheque Exercícios, Contracheque Meses, Contracheque PDF, Pagamentos Exercícios, Pagamentos Dados, Designações, RH Concessões, RH Ausências, Notícias, Diário Oficial Edições, Diário Oficial PDF, Certidão Consulta, Conectividade Health Probe.
  - **Leituras com Retry Condicional (1)**: Processos com Captcha (consulta pública cuja repetição é estritamente condicionada à resolução de novo Captcha pelo usuário).
- **Operações de Mutação (Total: 12)**:
  - **Mutações com Retry Automático Proibido (9)**: Login, Solicitar Férias, Adiar Férias, Antecipar Férias, Cancelar Férias, Suspender Férias Integral, Suspender Férias Parcial, Certidão Emitir, Ouvidoria Manifestação Enviar.
  - **Mutações com Retry Condicional / Descarte / Idempotente (3)**: FCM Registrar (idempotente com reenvio em reconexão/startup), FCM Desativar (idempotente com descarte em falha), Logout (limpeza local atômica e descarte gracioso em falha remota).
- **Soma das Categorias de Mutações**: 9 (Proibido) + 3 (Condicional/Descarte) = 12 mutações.
- **Recursos com Cache / Persistência Local**: 7 (Perfil, Carteira Dados, Foto, Notícias em memória, FCM Token local, Formulário Ouvidoria em memória, Logout atômico local).
- **Dependências Externas**: 10 (Auth API Institucional, MPVirtual [7 endpoints], JCR [Foto], CMS/Portal).
- **Operações Bloqueadas para Automação Ativa**: 3 (Processos com Captcha, Certidão Emissão, Ouvidoria Envio).
