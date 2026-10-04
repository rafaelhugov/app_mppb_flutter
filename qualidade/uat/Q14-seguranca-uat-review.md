# Q14 — Segurança e Isolamento da Infraestrutura UAT e Store Review

- **Fase:** Q14 — Qualidade e Homologação
- **Atividade:** Q14-R03-R03 — Hardening Final de Segurança e Isolamento
- **Data:** 03/10/2026
- **Status:** Hardening Validado; 30/30 Testes de Segurança Aprovados

---

## 1. Princípios de Segurança Mandatórios

A infraestrutura de usuários sintéticos foi projetada com base no princípio de **defesa em profundidade**, impedindo qualquer criação acidental de backdoor ou vazamento de dados funcionais reais:

1. **Feature Explicitamente Desabilitada por Padrão (`default = false`):**
   A configuração `uat.synthetic-users.enabled` inicia como `false`. Sem uma declaração ativa em configuração de ambiente, toda a infraestrutura sintética é inerte.

2. **Ciclo de Vida Condicionado via `@ConditionalOnProperty`:**
   Todos os 7 componentes sintéticos (`AutenticacaoSinteticaController`, `SyntheticSecurityConfig`, `SyntheticTokenAuthenticationProvider`, `AutenticadorUsuarioSintetico`, `AuditoriaUsuarioSintetico`, `SyntheticDataService`, `SyntheticSandboxStorage`) possuem anotação `@ConditionalOnProperty(name = "uat.synthetic-users.enabled", havingValue = "true")`.
   Com a feature desligada, nenhum bean sintético é instanciado no Spring ApplicationContext e a rota `/acesso/autoriza` resulta em 404 Not Found no `mobile-service`.

3. **Zero Proxy Institucional:**
   O `AutenticacaoSinteticaController` não realiza encaminhamento de credenciais para o `AuthServiceClient`.
   - Com feature ativa e usuário sintético conhecido: autentica localmente com 200 + token sintético.
   - Com feature ativa e usuário desconhecido: rejeita imediatamente com 401 Unauthorized.
   - `AuthServiceClient` possui zero interações em qualquer tentativa de autenticação sintética.

4. **Bloqueio Fatal em Produção (Fail-Fast em `prod`):**
   O validador de inicialização segura (`ValidadorConfiguracaoSegura.java`) foi reforçado: se o perfil ativo do Spring contiver `prod` ou `production` e `uat.synthetic-users.enabled` for avaliada como `true`, a aplicação **aborta imediatamente o startup**, lançando `IllegalStateException`.
   > Não se depende apenas de disciplina operacional: o próprio código impede a subida da aplicação.

5. **Nenhuma Senha ou Segredo Operacional Versionado no Git:**
   - As senhas das 6 identidades sintéticas e o segredo de assinatura JWT são lidos estritamente de variáveis de ambiente do sistema operacional ou Secret Manager:
     - `UAT_SYNTHETIC_JWT_SECRET`
     - `UAT_MEMBER_PASSWORD`
     - `UAT_SERVER_PASSWORD`
     - `GOOGLE_REVIEW_MEMBER_PASSWORD`
     - `GOOGLE_REVIEW_SERVER_PASSWORD`
     - `APPLE_REVIEW_MEMBER_PASSWORD`
     - `APPLE_REVIEW_SERVER_PASSWORD`
   - O repositório contém apenas referências externas no `application.yml` com defaults vazios:
     ```yaml
     uat:
       synthetic-users:
         enabled: ${UAT_SYNTHETIC_USERS_ENABLED:false}
         jwt-secret: ${UAT_SYNTHETIC_JWT_SECRET:}
         passwords:
           uat-membro: ${UAT_MEMBER_PASSWORD:}
           uat-servidor: ${UAT_SERVER_PASSWORD:}
           google-review-membro: ${GOOGLE_REVIEW_MEMBER_PASSWORD:}
           google-review-servidor: ${GOOGLE_REVIEW_SERVER_PASSWORD:}
           apple-review-membro: ${APPLE_REVIEW_MEMBER_PASSWORD:}
           apple-review-servidor: ${APPLE_REVIEW_SERVER_PASSWORD:}
     ```

6. **Rotatividade e Sigilo Operacional de Segredos:**
   - Todas as credenciais efêmeras utilizadas em smokes anteriores foram formalmente rotacionadas e consideradas expiradas;
   - Em sessões futuras de execução, novas credenciais são geradas efemeramente sem qualquer eco em transcripts, logs ou arquivos de documentação Markdown.

7. **Fail-Fast de Configuração Incompleta e Proteção de Ambiente:**
   - Se `uat.synthetic-users.enabled=true` e qualquer senha obrigatória ou `jwt-secret` estiver ausente/vazio, a aplicação **recusa o startup** (`ValidadorConfiguracaoSegura.java`).
   - Se os perfis contiverem `prod`, `production`, `prd` ou perfil desconhecido fora da allowlist (`homolog`, `uat`, `review`, `test`, `dev`, `local`), a aplicação **recusa o startup**.

8. **Proteção Contra Ataques de Timing:**
   A validação de senha no `AutenticadorUsuarioSintetico.java` utiliza comparação segura em tempo constante (`MessageDigest.isEqual`), mitigando completamente ataques de análise de tempo de resposta por força bruta.

---

## 2. Isolamento de Sessão e Tokens Sintéticos

- **Formato Estruturado e Criptográfico:**
  Tokens emitidos para usuários sintéticos possuem o formato estruturado:
  `UAT-SYNTH.<base64UrlHeader>.<base64UrlPayload>.<hmacSha256Signature>`
- **Conteúdo e Integridade do Payload:**
  - `sub`: login sintético;
  - `identificador`: identificador único;
  - `origem`: enum de origem (`UAT`, `REVIEW_GOOGLE`, `REVIEW_APPLE`);
  - `perfil`: enum funcional (`MEMBRO`, `SERVIDOR`);
  - `matricula`: matrícula sintética;
  - `jti`: UUID criptográfico aleatório gerado a cada emissão;
  - `iat`: timestamp de emissão;
  - `exp`: timestamp de expiração (TTL de 8 horas).
- **Esclarecimento Mandatório sobre `jti` e Prevenção de Replay:**
  - O claim `jti` **identifica unicamente o token** para fins de auditoria e rastreabilidade;
  - O mecanismo sintético opera de forma **stateless** (sem estado persistente em banco ou cache) e **não mantém blacklist de jti consumidos**;
  - Portanto, o `jti` **NÃO impede replay** de um token sintético capturado antes da expiração de sua janela de 8 horas. Esta limitação é aceita e documentada para o escopo de testes UAT controlados.

---

## 3. Isolamento Total de Mutações (Sandbox)

Todas as ações realizadas por contas UAT, Google Review ou Apple Review que normalmente modificariam bancos de dados institucionais são rigorosamente confinadas ao sandbox em memória (`SyntheticSandboxStorage`):

| Operação | Comportamento no Fluxo Real | Comportamento no Sandbox Sintético |
|---|---|---|
| **Solicitação de Férias** | Envio de protocolo ao MPVirtual e RH | Registrado apenas na memória volátil do sandbox |
| **Adiamento / Cancelamento de Folga** | Alteração em base de dados institucional | Alterado apenas no mapa em memória do sandbox |
| **Registro de Token FCM** | Persistência na tabela `dispositivo_fcm` e push | Salvo no repositório em memória do sandbox; zero push enviado |
| **Desativação de Dispositivo** | Atualização de status no banco de produção | Desativado no mapa em memória do sandbox |

Testes automatizados comprovam zero interações com repositórios e clientes externos institucionais (`AuthServiceClient`, etc.).

---

## 4. Auditoria Estruturada

O componente `AuditoriaUsuarioSintetico.java` registra em log todas as interações com a massa de dados sintética de forma estruturada:

```text
INFO mppb.restapi.mobile.feature.synthetic.audit.AuditoriaUsuarioSintetico -- usuarioSintetico=true origem=UAT perfil=MEMBRO operacao=CONSULTA_CARTEIRA
INFO mppb.restapi.mobile.feature.synthetic.audit.AuditoriaUsuarioSintetico -- usuarioSintetico=true origem=REVIEW_GOOGLE perfil=MEMBRO operacao=VALIDACAO_TOKEN_SUCESSO
WARN mppb.restapi.mobile.feature.synthetic.audit.AuditoriaUsuarioSintetico -- usuarioSintetico=true loginTentado=uat.membro resultado=REJEITADO motivo=SENHA_INVALIDA
```

**Regras de Sigilo na Auditoria:**
- Senhas nunca são logadas;
- Tokens completos nunca são logados;
- Payloads de requisição com dados sensíveis nunca são impressos nos logs.

---

## 5. Matriz de Evidências de Segurança Automatizadas (30 Testes)

A suíte `Q14UsuariosSinteticosUatReviewTest.java` executou e aprovou as 30 verificações de segurança e integração obrigatórias:

| Item | Teste | Cenário Avaliado | Resultado |
|---|---|---|---|
| 1 | `test01_featureDisabled` | `uat.synthetic-users.enabled=false` retorna 401 sem proxy institucional e provider repassa | APROVADO |
| 2 | `test02_usuarioUatMembro` | Login `uat.membro` com senha correta emite token sintético válido | APROVADO |
| 3 | `test03_usuarioUatServidor` | Login `uat.servidor` com senha correta emite token sintético válido | APROVADO |
| 4 | `test04_googleMembro` | Login `review.google.membro` emite token com origem `REVIEW_GOOGLE` | APROVADO |
| 5 | `test05_googleServidor` | Login `review.google.servidor` emite token com origem `REVIEW_GOOGLE` | APROVADO |
| 6 | `test06_appleMembro` | Login `review.apple.membro` emite token com origem `REVIEW_APPLE` | APROVADO |
| 7 | `test07_appleServidor` | Login `review.apple.servidor` emite token com origem `REVIEW_APPLE` | APROVADO |
| 8 | `test08_senhaInvalida` | Senha errada ou vazia rejeita com HTTP 401 e log de auditoria | APROVADO |
| 9 | `test09_origemAuditoria` | Origens UAT, Google e Apple registradas com precisão na auditoria | APROVADO |
| 10 | `test10_perfilMembro` | Consulta de perfil retorna dados sintéticos de Promotor de Justiça | APROVADO |
| 11 | `test11_perfilServidor` | Consulta de perfil retorna dados sintéticos de Analista Ministerial | APROVADO |
| 12 | `test12_carteiraFuncional` | Carteira funcional digital, foto JPEG e consulta por hash sintético | APROVADO |
| 13 | `test13_contracheques` | Contracheques com múltiplas competências, detalhes e PDF binário sintético | APROVADO |
| 14 | `test14_pagamentos` | Pagamentos para múltiplos exercícios e empty state para anos sem registros | APROVADO |
| 15 | `test15_designacoes` | Designações ativas e históricas para Membro; lista vazia para Servidor | APROVADO |
| 16 | `test16_concessoes` | Consulta de saldo e marcação de férias em sandbox sem tocar no MPVirtual | APROVADO |
| 17 | `test17_operacoesSandbox` | Adiamento e cancelamento de folga mutáveis operando no sandbox em memória | APROVADO |
| 18 | `test18_fcmSandbox` | Registro e desativação de token FCM em memória sem envio de push real | APROVADO |
| 19 | `test19_nenhumAcessoAIntegracaoReal` | Zero interações com repositórios e serviços externos corporativos | APROVADO |
| 20 | `test20_bloqueioEmProfileProd` | Perfil `prod` com feature ativa recusa startup fatalmente | APROVADO |
| 21 | `test21_tokenTamperingAssinaturaEPayloadRejeitados` | Token adulterado na assinatura ou com payload fraudado é rejeitado | APROVADO |
| 22 | `test22_tokenExpiradoRejeitado` | Token sintético expirado é rejeitado na cadeia de autenticação | APROVADO |
| 23 | `test23_zeroProxyLoginDesconhecidoNaoEncaminhaAuthService` | Zero proxy institucional: login desconhecido retorna 401 sem chamar AuthServiceClient | APROVADO |
| 24 | `test24_configuracaoIncompletaStartupRecusado` | Enabled com senhas ausentes ou `jwt-secret` ausente recusa startup | APROVADO |
| 25 | `test25_protecaoAmbientePerfisProibidos` | Perfis `prd`, `production` ou fora da allowlist recusam startup fatalmente | APROVADO |
| 26 | `test26_httpMockMvcAutenticacaoESecurityFilterChain` | Integração HTTP real via MockMvc: autenticação, perfil e carteira com zero chamadas externas | APROVADO |
| 27 | `test27_lifecycleBeansCondicionados` | Ciclo de vida condicionado dos beans sintéticos: ausentes quando off, presentes quando on | APROVADO |
| 28 | `test28_servicosNormaisPreservadosComFeatureOff` | Serviços normais (perfil, carteira, contracheque, etc.) usam integrações normais quando feature off | APROVADO |
| 29 | `test29_featureLigadaZeroInteracoesAuthServiceClient` | Feature ligada: uat.membro/servidor 200, desconhecido/inválido 401, zero chamadas AuthServiceClient | APROVADO |
| 30 | `test30_producaoSemEndpointSinteticoZeroInteracoes` | Produção sem endpoint sintético: POST /acesso/autoriza resulta em 404 e zero chamadas externas | APROVADO |
