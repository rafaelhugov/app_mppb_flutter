# Relatório Final — Fase Q14: User Acceptance Testing (UAT) e Aceite Final

**Data de Conclusão da Avaliação:** 02/10/2026 (Atualizado em 03/10/2026)  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final (Última Fase do Ciclo)  
**Status Global:** Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO, ACEITE HUMANO PENDENTE  

---

## 1. Baseline Canônica

### 1.1 Aplicação Mobile (Flutter)
- **Diretório:** `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Branch de Trabalho:** `qualidade/q14-correcao-residual-pre-uat`
- **Commit Base (HEAD):** `be8f26f`
- **Modificações Preservadas:** `pubspec.yaml` (`version: 4.0.0+69 → 4.0.0+72`) mantida rigorosamente fora de qualquer commit da Q14.
- **Estado dos Gates:**
  - `flutter analyze`: **0 issues**
  - `flutter test`: **242 / 242 aprovados (100%)**
  - `secret_scan.sh` e `security_regression.sh`: **Verdes (exit code 0)**
  - APK Homologação: Compilado, instalado e operacional no dispositivo físico de teste.

### 1.2 Backend (Spring Boot REST API)
- **Diretório:** `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- **Branch de Trabalho:** `master`
- **Commit Base (HEAD):** `12ebbe7` (`12ebbe7a3d047601102622e296052d568b8d156c`)
- **Estado dos Gates:**
  - Maven tests: **169 / 169 aprovados (100%)**
  - Maven package: **BUILD SUCCESS**
  - Working tree: Limpo (sem alterações locais pendentes).

---

## 2. Ambiente e Dispositivo Físico

- **Aparelho:** Samsung Galaxy A52 (`SM-A525M`), serial ADB `RX8RC09H70X`.
- **Sistema Operacional:** Android 14 / One UI 6.1 (API 34).
- **Pacote Testado:** `br.mp.mppbapp.app.homolog` (v4.0.0, versionCode 72, minSdk 24, targetSdk 36).
- **Artefato Canônico:** `build\app\outputs\flutter-apk\app-homolog-debug.apk` (SHA-256: `E8568216B139C5DFE13FD17D40A5AE471708D19B4851BECE1D6E776D8FADC81A`).
- **Endpoint Canônico do Backend:** Homologação oficial do MPPB (`https://aplicativo-mppb-homolog.mppb.mp.br`).
  - *Auditoria de Proveniência Canônica:* Comprovada a configuração em `scripts/build/build_apk.sh` (linhas 21-22), `scripts/build/build_aab.sh`, `lib/core/network/api_client.dart` e relatórios históricos Q5, Q8, Q10, Q11 e Q13. A menção simplificada `https://app-homolog.mppb.mp.br` decorreu exclusivamente de abreviação textual em relatórios descritivos, mantendo-se a infraestrutura técnica imutável.
- **Data da Auditoria em Dispositivo:** 02/10/2026 e 03/10/2026.

---

## 3. Jornadas Públicas (8 Jornadas Canônicas)

Todas as 8 jornadas públicas foram avaliadas com evidências versionadas em `qualidade/evidencias/Q14/android/`:

| ID Cenário | Jornada | Evidência Principal | Executor | Resultado Técnico | Ressalvas / Observações |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Primeira Abertura e Inicialização | `android/q14-home.png` | TÉCNICO | **APROVADO** | Inicialização sem falhas; splash institucional exibido; alcance imediato da Home pública. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | TÉCNICO | **APROVADO** | Grade de 6 serviços ao cidadão, carrossel dinâmico de notícias e botões de ação íntegros. |
| **Q14-U03** | Q14-J03 — Notícias (Listagem, Detalhe e Retorno) | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | TÉCNICO | **APROVADO** | Notícias consumidas via API, busca, abertura em modal de detalhe com foto e texto, retorno limpo à lista e à Home. |
| **Q14-U04** | Q14-J04 — Diário Oficial (Edições e Visualizador PDF) | `android/q14-diario.png`, `android/q14-diario-loaded.png` | TÉCNICO | **APROVADO** | Edições recentes listadas com destaque para Última Edição (Nº 3160); renderização in-app completa do documento PDF no visualizador sem travamentos. |
| **Q14-U05** | Q14-J05 — Consulta Processual e Filtros | `android/q14-processos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, filtros e validação de submissão aferidos; consulta com processo conhecido e resultado positivo não aferida por ausência de massa UAT autorizada. |
| **Q14-U06** | Q14-J06 — Contatos e Atendimento Institucional | `android/q14-contatos.png` | TÉCNICO | **APROVADO COM RESSALVA** | Presença visual e renderização dos botões 'Ligar' e 'Mapa', telefone, endereço, horários e ouvidoria aferidas na tela física; handoffs para discador e mapa não executados nesta rodada residual por indisponibilidade momentânea de conexão física do aparelho no host. Nenhuma chamada ou navegação real foi iniciada. |
| **Q14-U07** | Q14-J07 — Certidão Extrajudicial (Emissão/Validação) | `android/q14-certidao.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface e validações locais aferidas (mensagens visuais de CPF/Nome obrigatórios); emissão/validação positiva contra registro real não executadas nesta bateria técnica. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | TÉCNICO | **APROVADO COM RESSALVA** | Interface, fluxo de identificação em 5 passos (Identif., Classif., Relato, Anexos, Revisão), alternância de manifestação anônima e validação de formulário aferidas; submissão e geração de protocolo oficial deliberadamente omitidas por segurança operacional. |

**Total Público:** 8 executados (100%), 4 aprovados sem ressalva, 4 aprovados com ressalva metodológica, 0 reprovados, 0 bloqueados.

---

## 4. Jornadas Autenticadas (10 Jornadas Canônicas)

Os 10 módulos restritos foram avaliados quanto à interface e dependências institucionais:

| ID Cenário | Jornada | Evidência Principal | Executor | Resultado Técnico | Justificativa Objetiva |
|---|---|---|---|---|---|
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional | `android/q14-login.png` | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Interface de login validada visualmente (Usuário, Senha com toggle de visibilidade, ACESSAR, Cancelar); submissão bloqueada sem credencial institucional de homologação. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Dependente de U09. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer usuário logado com dados cadastrais em homologação. |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer sessão autenticada para dados funcionais e foto oficial. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer perfil funcional com competências ativas de folha de pagamento. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer histórico financeiro atribuído ao usuário na base de testes. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer vínculo com portarias vigentes em homologação. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer saldo de concessões e histórico de ausências usufruídas. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer fluxo de requerimento administrativo no RH. |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | EVIDÊNCIA HERDADA | TÉCNICO | **BLOQUEADO** | Bloqueado por ausência de massa/credencial de UAT. Requer autenticação para registro da matrícula no backend mobile. |

**Total Autenticado:** 10 cenários bloqueados estritamente por ausência de credencial institucional autorizada de homologação (`OBS-Q14-001`).

---

## 5. Bugs Identificados (BUG-Q14)

- **Total de Bugs Encontrados:** 0
- Nenhum travamento, crash, tela congelada, ANR ou exceção não tratada foi verificada durante a execução das jornadas no dispositivo físico Samsung Galaxy A52.

---

## 6. Observações Registradas (OBS-Q14)

- **OBS-Q14-001 — Fornecimento de Credenciais para Homologação do Escopo Autenticado:**
  Para viabilizar a conclusão do aceite institucional pelo usuário final nos 10 módulos autenticados, é necessária a disponibilização prévia de 2 (duas) credenciais de teste em ambiente de homologação (perfis Membro/Promotor e Servidor Técnico/Administrativo) com dados previamente descaracterizados.

---

## 7. Regressão Técnica e Integridade dos Gates

- **Flutter Analyze:** **0 issues** encontrados.
- **Flutter Test:** **242 / 242** testes aprovados (100%).
- **Security Gates:** `secret_scan.sh` e `security_regression.sh` aprovados com código 0.
- **Backend Test:** **169 / 169** testes aprovados (executados com JDK 21).
- **Backend Package:** Concluído com sucesso (BUILD SUCCESS).
- **Integridade de Versão:** `pubspec.yaml` preservado com modificação não comitada (`4.0.0+69 → 4.0.0+72`).

---

## 8. Resultado Pré-UAT Técnico

```text
PRÉ-UAT TÉCNICO APROVADO COM RESSALVAS
```
*Ressalva Técnica:* O escopo público (8 jornadas) encontra-se validado tecnicamente no aparelho físico, com ressalvas operacionais de integridade sem falha técnica nos fluxos de processo, contatos, certidão e ouvidoria; os fluxos autenticados (10 jornadas) permanecem formalmente bloqueados exclusivamente pela ausência de credenciais institucionais autorizadas para teste em homologação.

---

## 9. Resultado UAT Humano

```text
ACEITE HUMANO PENDENTE
```
A avaliação com usuários reais de negócio **NÃO FOI EXECUTADA** nesta rodada técnica, estando o roteiro (`qualidade/uat/Q14-roteiro-avaliador.md`) e o modelo do termo (`qualidade/uat/Q14-termo-aceite.md`) devidamente prontos para aplicação formal pelo órgão.

---

## 10. Pendências

1. Disponibilização institucional de credenciais de teste em homologação pelo MPPB;
2. Convocação do avaliador humano representativo para aplicação do roteiro Q14;
3. Preenchimento e assinatura do Termo de Homologação e Aceite Final (`Q14-termo-aceite.md`).

---

## 11. Decisão Final

```text
STATUS DA FASE:
Q14 NÃO CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO, ACEITE HUMANO PENDENTE

STATUS DO CICLO DE QUALIDADE:
CICLO Q1–Q13 CONCLUÍDO / Q14 AGUARDANDO ACEITE HUMANO
```

O aplicativo encontra-se **apto para prosseguir conforme o escopo validado**, aguardando exclusivamente a realização do aceite humano institucional para a assinatura definitiva. Não criar fase Q15.
