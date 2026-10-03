# Q14 — Registro de Bugs e Observações

**Data da Auditoria:** 02/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final

---

## 1. Registro de Bugs Funcionais (BUG-Q14)

Nenhum bug funcional, crash, travamento de tela (ANR) ou defeito impeditivo foi identificado durante a execução dos cenários de teste técnico no dispositivo físico Samsung Galaxy A52 (`SM-A525M`, Android 14).

| ID | Jornada | Severidade | Estado | Descrição |
|---|---|---|---|---|
| — | — | — | — | **Nenhum bug identificado na bateria Q14** |

---

## 2. Registro de Observações e Apontamentos de Processo (OBS-Q14)

### OBS-Q14-001 — Necessidade de Credencial Institucional para Homologação do Escopo Restrito
- **Classificação:** Processo / Dependência de Infraestrutura e Massa de Teste
- **Contexto:** Os 10 módulos de Acesso Restrito (Q14-J09 a Q14-J18: Login, Home Autenticada, Perfil Funcional, Carteira Funcional Digital, Contracheques, Informações de Pagamentos, Designações Ativas, Consulta de Concessões/Folgas, Solicitação de Concessões/Folgas e Notificações Push FCM) dependem de credenciais institucionais ativas no serviço de autenticação do MPPB (`auth-api.mppb.mp.br`) com permissões em base de homologação.
- **Impacto no UAT:** Sem credenciais de teste previamente cadastradas e autorizadas pela administração do órgão, a validação desses fluxos por um usuário final humano fica suspensa, impossibilitando a declaração de Aceite Humano integral nesta rodada.
- **Recomendação Institucional:** Para a sessão de homologação final com os usuários de negócio, recomenda-se a criação de 2 (duas) contas funcionais dedicadas exclusivamente a testes em homologação (1 para Membro do Ministério Público e 1 para Servidor Técnico/Administrativo), com dados previamente descaracterizados.

---

## 3. Diretriz de Não Alteração Cosmética

Em conformidade com a seção 36 do protocolo Q14:
> *Q14 é gate de produto e aceite final, não uma nova fase de refatorações ou ajustes de preferência cosmética. Somente bugs funcionais comprovados ou problemas impeditivos de aceite justificam alteração de código de produção.*

Como nenhum bug funcional foi constatado, o código funcional e de interface de ambos os repositórios (Flutter e Backend) permaneceu estritamente preservado.
