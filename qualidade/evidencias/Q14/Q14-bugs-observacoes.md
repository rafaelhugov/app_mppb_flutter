# Q14 — Registro de Bugs e Observações

**Data da Auditoria:** 02/10/2026 a 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final (Pré-UAT Técnico Consolidado)

---

## 1. Registro de Bugs Funcionais e Técnicos (BUG-Q14)

Durante os ciclos de execução técnica e regressão da fase Q14, foram identificados e corrigidos 3 (três) apontamentos:

| ID | Jornada / Escopo | Severidade | Estado | Descrição Resumida |
|---|---|---|---|---|
| **BUG-Q14-001** | Q14-J17 / Concessões | Média | **CORRIGIDO / VALIDADO** | Falha de parsing de data no backend em sugestões de término de concessão |
| **BUG-Q14-002** | Q14-J18 / Notificações | Média | **CORRIGIDO / VALIDADO** | Falha de persistência relacional de token FCM em modo sintético |
| **BUG-Q14-003** | Q14-J08 / Regressão Q13 | Média | **CORRIGIDO / VALIDADO** | Mutação de estado pós-dispose em `OuvidoriaNotifier` (`Ref._throwIfInvalidUsage`) |

### Detalhamento dos Bugs e Resoluções

#### BUG-Q14-001 — Parsing de Data em Sugestões de Concessão de Folga
- **Causa:** Falha de desserialização temporal no backend (`SyntheticSandboxStorage`) ao receber formato ISO-8601 estrito (`yyyy-MM-dd`) ou formato local com timestamp no endpoint `/api/concessoes/sugestoes-datas-finais`.
- **Impacto:** Impossibilidade de calcular dinamicamente sugestões de término para gozo de folgas compensatórias/férias (HTTP 500).
- **Correção:** Implementação de parser flexível resiliente (`parseFlexibleDate`) em `SyntheticSandboxStorage`, suportando `yyyy-MM-dd`, formato local ISO com timestamp e fallback seguro sem lançamento de `DateTimeParseException`.
- **Validação:** Teste automatizado de regressão canônica `test31_regressaoBugQ14_001_parsingDataSugestoesConcessao` (PASS) e reteste físico no Samsung Galaxy A52 na jornada Q14-U17.
- **Estado:** `CORRIGIDO / VALIDADO`

#### BUG-Q14-002 — Persistência FCM Sintética vs Institucional
- **Causa:** Chamada para registrar token FCM pelo app móvel tentava persistência em repositório relacional sem chave primária prévia do usuário sintético no banco principal, gerando falha de integridade referencial.
- **Impacto:** Erro ao registrar dispositivo push durante o ciclo de vida da sessão em modo UAT sintético.
- **Correção:** O serviço `DispositivoFcmService` foi adaptado para armazenar o identificador de dispositivo em sandbox em memória quando `UAT_SYNTHETIC_USERS_ENABLED=true`, respondendo HTTP 200 OK com diagnóstico completo no log de auditoria, preservando zero chamadas a repositório relacional e sem alterar o fluxo de banco institucional normal.
- **Validação:** Teste automatizado de regressão canônica `test32_regressaoBugQ14_002_persistenciaFcmSinteticaVsInstitucional` (PASS, confirmando `chamadasFindByTokenHash == 0`) e auditoria de log na jornada Q14-U18.
- **Estado:** `CORRIGIDO / VALIDADO`

#### BUG-Q14-003 — Falha de Estado Pós-Dispose em OuvidoriaNotifier (`Ref._throwIfInvalidUsage`)
- **Causa:** `OuvidoriaNotifier.build()` agenda `Future.microtask(_initCombos)`. Quando o `ProviderContainer` ou o `Ref` do notifier é descartado antes da resolução assíncrona da chamada HTTP de combos, a execução do bloco `catch` (ou de sucesso) tenta executar `state = state.copyWith(...)`. Como o Riverpod proíbe mutação de estado em `Notifier` descartado, a biblioteca lança `Ref._throwIfInvalidUsage: Cannot use the Ref of NotifierProvider<OuvidoriaNotifier, OuvidoriaState> after it has been disposed.` fora da zona síncrona do teste, quebrando a asserção após o encerramento do teste.
- **Impacto:** Falha na suíte de testes de regressão automatizada (queda de 244 para 243 aprovados).
- **Correção:** Inseridas guardas `if (!ref.mounted) return;` antes das mutações assíncronas de `state` em `_initCombos` e demais métodos assíncronos de `OuvidoriaNotifier`, alinhando-o ao padrão já existente em todos os outros notifiers do projeto.
- **Validação:** Q13 fuzz/property (`test/features/qualidade/q13_fuzz_property_test.dart`, P03) permaneceu sem diff e passou; suíte completa Flutter atingiu 244/244; `flutter analyze` = 0 issues; security gates verdes.
- **Estado:** `CORRIGIDO / VALIDADO`

---

## 2. Registro de Observações e Apontamentos de Processo (OBS-Q14)

### OBS-Q14-001 — Necessidade de Credencial Institucional para Homologação do Escopo Restrito
- **Classificação:** Processo / Dependência de Infraestrutura e Massa de Teste
- **Contexto:** Os 10 módulos de Acesso Restrito (Q14-J09 a Q14-J18: Login, Home Autenticada, Perfil Funcional, Carteira Funcional Digital, Contracheques, Informações de Pagamentos, Designações Ativas, Consulta de Concessões/Folgas, Solicitação de Concessões/Folgas e Notificações Push FCM) dependem de credenciais institucionais ativas no serviço de autenticação do MPPB (`auth-api.mppb.mp.br`) com permissões em base de homologação.
- **Impacto no UAT:** Sem credenciais de teste previamente cadastradas e autorizadas pela administração do órgão, a validação desses fluxos por um usuário final humano fica suspensa, impossibilitando a declaração de Aceite Humano integral nesta rodada.
- **Recomendação Institucional:** Para a sessão de homologação final com os usuários de negócio, recomenda-se a criação de 2 (duas) contas funcionais dedicadas exclusivamente a testes em homologação (1 para Membro do Ministério Público e 1 para Servidor Técnico/Administrativo), com dados previamente descaracterizados.

### BLOQUEIO-Q14-REVIEW-001 — Prontidão para Store Review
- **Classificação:** Distribuição / Loja de Aplicativos (Google Play Console e Apple App Store Connect)
- **Motivo do Bloqueio:**
  - Contas REVIEW ainda não provisionadas operacionalmente;
  - Backend externo acessível aos revisores ainda não definido/implantado;
  - Modo sintético permanece bloqueado em produção;
  - Estratégia de Store Review será definida após o aceite institucional.
  Não enfraquecer a proteção de produção.

---

## 3. Diretriz de Não Alteração Cosmética

Em conformidade com a seção 36 do protocolo Q14:
> *Q14 é gate de produto e aceite final, não uma nova fase de refatorações ou ajustes de preferência cosmética. Somente bugs funcionais comprovados ou problemas impeditivos de aceite justificam alteração de código de produção.*

Os 3 apontamentos registrados acima foram os únicos que demandaram intervenção técnica pontual e estritamente mínima para restabelecimento da integridade dos gates de qualidade.
