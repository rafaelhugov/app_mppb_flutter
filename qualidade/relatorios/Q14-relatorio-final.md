# Relatório Final — Fase Q14: User Acceptance Testing (UAT) e Aceite Final

**Data de Conclusão da Fase:** 04/10/2026  
**Ciclo:** Qualidade, Confiabilidade e Prontidão do App MPPB  
**Fase:** Q14 — User Acceptance Testing (UAT) e Aceite Final (Última Fase do Ciclo)  
**Status Global:** `Q14 CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO E ACEITE HUMANO INSTITUCIONAL REALIZADO`  
**Status do Ciclo:** `CICLO Q1–Q14 CONCLUÍDO`  
**Prontidão para Store Review:** `NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001`  

---

## Resumo Executivo

A fase Q14 concluiu integralmente suas duas etapas canônicas: o **Pré-UAT Técnico** em dispositivo físico e a **Avaliação Humana Institucional** conduzida pelo analista de negócio designado.

1. **Pré-UAT Técnico:** As 18 jornadas previstas foram tecnicamente executadas no dispositivo físico de referência (Samsung Galaxy A52, Android 14) e classificadas: 13 APROVADAS e 5 APROVADAS COM RESSALVA metodológica/operacional.
2. **Avaliação Humana Institucional:** Percorreu as 18/18 jornadas canônicas pelo responsável institucional (Rafael Vasconcelos, Analista de Desenvolvimento de Sistema — DITEC).
   - Resultado: 15 ACEITAS, 3 ACEITAS COM RESSALVA, 0 NÃO ACEITAS, 0 NÃO AVALIADAS.
   - Decisão Formal do Avaliador: **ACEITO INTEGRALMENTE**.
   - Três observações humanas foram registradas no ambiente UAT (J04, J05, J17), todas classificadas como comportamentos do sandbox/ambiente e declaradas expressamente como não bloqueadoras.
3. **Bugs e Regressão:** Zero bugs confirmados durante o aceite humano. Os 3 bugs técnicos previamente corrigidos (BUG-Q14-001, BUG-Q14-002 e BUG-Q14-003) permanecem validados com 100% de aprovação nos gates automatizados.

---

## 1. Baseline Canônica Consolidada

### 1.1 Aplicação Mobile (Flutter)
- **Diretório:** `C:\Users\rafae\projetosMPPB\app_mppb_flutter`
- **Master HEAD:** `87201fc`
- **Modificações Preservadas:** `pubspec.yaml` (`version: 4.0.0+69 → 4.0.0+72`) mantida fora de qualquer commit da Q14.
- **Estado dos Gates:**
  - `flutter analyze`: **0 issues**
  - `flutter test`: **244 / 244 aprovados (100%)**
  - `secret_scan.sh` e `security_regression.sh`: **Aprovados (exit code 0)**
  - APK Homologação: Compilado, instalado e operacional no dispositivo físico Samsung Galaxy A52.

### 1.2 Backend (Spring Boot REST API)
- **Diretório:** `C:\Users\rafae\projetosMPPB\spring-boot\restapi`
- **Master HEAD:** `2749415`
- **Compilação e Pacote:** `mvn -q -pl restapi-common,mobile-service -DskipTests package` gerou `mobile-service-0.3.25.jar` com JDK 21 Adoptium (**BUILD SUCCESS**).
- **Proveniência do JAR:**
  - Arquivo: `mobile-service\target\mobile-service-0.3.25.jar`
  - Tamanho: `168.358.734 bytes`
  - SHA-256: `DAD1E11CDDFC324A879CB151E202983D363ABBE9CDEB87480E6EA2A94424FD61`
- **Integridade Canônica:** Zero diff nos módulos centrais `restapi-common` e `Q6ConcorrenciaIntegridadeTest.java`.
- **Estado dos Gates (Suíte Canônica Maven):**
  - `restapi-common`: **11** testes (Failures: 0, Errors: 0, Skipped: 0)
  - `mobile-service`: **191** testes (Failures: 0, Errors: 0, Skipped: 0)
  - **TOTAL:** **202** testes (Failures: 0, Errors: 0, Skipped: 0) — 100% de aprovação.
  - Regressões automatizadas específicas Q14 incluídas e aprovadas:
    - BUG-Q14-001 (parsing flexível de datas): PASS
    - BUG-Q14-002 (persistência FCM sintética vs institucional): PASS
    - U17 Autorização por Objeto (cross-object isolation Membro vs Servidor): PASS

---

## 2. Ambiente e Dispositivo Físico

- **Aparelho:** Samsung Galaxy A52 (`SM-A525M`), serial ADB `RX8RC09H70X`.
- **Sistema Operacional:** Android 14 / One UI 6.1 (API 34).
- **Pacote Testado:** `br.mp.mppbapp.app.homolog` (v4.0.0, versionCode 72, minSdk 24, targetSdk 36).
- **Artefato Canônico:** `build\app\outputs\flutter-apk\app-homolog-debug.apk` (SHA-256: `B23096118DFD80E3FC8A687B94B994B8622130E33485A786D0A3BFF674971FA7`).
- **Endpoint do Backend:** Spring Boot local em porta 9003 com profile de homologação sintética ativado (`UAT_SYNTHETIC_USERS_ENABLED=true`), integrado via ADB Reverse `tcp:9003 tcp:9003`.
- **Avaliador Institucional:** Rafael Vasconcelos (Analista de Desenvolvimento de Sistema — DITEC).
- **Data da Avaliação:** 02/10/2026 a 04/10/2026.

---

## 3. Matriz Consolidada das 18 Jornadas

| ID Cenário | Jornada | Evidência Principal | Pré-UAT Técnico | Avaliação Humana | Observações Consolidadas |
|---|---|---|---|---|---|
| **Q14-U01** | Q14-J01 — Primeira Abertura e Inicialização | `android/q14-home.png` | **APROVADO** | **ACEITO** | Inicialização sem falhas, splash institucional exibido, alcance imediato da Home. |
| **Q14-U02** | Q14-J02 — Navegação na Home Pública e Serviços ao Cidadão | `android/q14-home.png` | **APROVADO** | **ACEITO** | Grade de 6 serviços ao cidadão, carrossel de notícias e botões funcionais. |
| **Q14-U03** | Q14-J03 — Notícias (Listagem, Detalhe e Retorno) | `android/q14-noticias.png`, `android/q14-noticia-detalhe.png` | **APROVADO** | **ACEITO** | Notícias consumidas via API, busca, abertura de modal com foto e texto. |
| **Q14-U04** | Q14-J04 — Diário Oficial (Edições e Visualizador PDF) | `android/q14-diario.png`, `android/q14-diario-loaded.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: PDF renderizado. Humano: OBSERVAÇÃO-HUMANA-Q14-001 (mensagem de conexão UAT). |
| **Q14-U05** | Q14-J05 — Consulta Processual e Filtros | `android/q14-processos.png` | **APROVADO COM RESSALVA** | **ACEITO COM RESSALVA** | Técnico: campos validados. Humano: OBSERVAÇÃO-HUMANA-Q14-003 (filtros no UAT). |
| **Q14-U06** | Q14-J06 — Contatos e Atendimento Institucional | `android/q14-contatos.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: handoffs preservados. Humano: informações acessíveis e claras. |
| **Q14-U07** | Q14-J07 — Certidão Extrajudicial (Emissão/Validação) | `android/q14-certidao.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: validação local aferida. Humano: fluxo e interface satisfatórios. |
| **Q14-U08** | Q14-J08 — Registro de Manifestação na Ouvidoria | `android/q14-ouvidoria.png` | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: 5 etapas aferidas. Humano: fluxo bem estruturado e intuitivo. |
| **Q14-U09** | Q14-J09 — Acesso Restrito / Autenticação Institucional | `q14-uat-login-invalido.png`, `q14-uat-membro-dashboard.png`, `q14-uat-servidor-dashboard.png` | **APROVADO** | **ACEITO** | Rejeição 401 de inválidos e login seguro com transição imediata para dashboards. |
| **Q14-U10** | Q14-J10 — Home Autenticada, Dashboard Restrito e Logout | `q14-uat-sessao-persistencia.png`, `q14-uat-membro-dashboard.png`, `q14-uat-logout-home.png` | **APROVADO** | **ACEITO** | Persistência após force-stop e logout seguro com retorno à Home pública. |
| **Q14-U11** | Q14-J11 — Consulta e Visualização do Perfil Funcional | `q14-uat-membro-perfil.png`, `q14-uat-membro-perfil-detalhes.png`, `q14-uat-servidor-perfil.png` | **APROVADO** | **ACEITO** | Dados funcionais de Membro e Servidora exibidos com precisão. |
| **Q14-U12** | Q14-J12 — Visualização da Carteira Funcional Digital | `q14-uat-carteira-membro.png`, `q14-uat-carteira-membro-verso.png`, `q14-uat-carteira-servidor.png` | **APROVADO** | **ACEITO** | Cartões oficiais renderizados com brasão, monogramas e verso antifalsificação. |
| **Q14-U13** | Q14-J13 — Consulta de Contracheques e Exportação PDF | `q14-uat-contracheque.png`, `q14-uat-contracheque-valores.png`, `q14-uat-contracheque-pdf.png`, `q14-uat-contracheque-servidor.png` | **APROVADO** | **ACEITO** | Competências consultadas, controle de privacidade de valores e PDF exportado. |
| **Q14-U14** | Q14-J14 — Consulta de Informações de Pagamentos | `q14-uat-pagamentos.png`, `q14-uat-pagamentos-2025.png`, `q14-uat-pagamentos-servidor.png`, `q14-uat-pagamentos-vazio.png` | **APROVADO** | **ACEITO** | Histórico 2026/2025 e estado vazio informativo para anos sem lançamentos. |
| **Q14-U15** | Q14-J15 — Consulta de Designações Funcionais Ativas | `q14-uat-designacoes-membro.png`, `q14-uat-designacoes-vazio.png` | **APROVADO** | **ACEITO** | Portaria ativa para Membro e estado vazio informativo para Servidora. |
| **Q14-U16** | Q14-J16 — Consulta de Concessões de Folga e Ausências | `q14-uat-concessoes-baseline.png`, `q14-uat-concessoes-saldos.png`, `q14-uat-concessoes-servidor.png` | **APROVADO** | **ACEITO** | Consulta de calendário e aba de saldos de concessões apurados corretamente. |
| **Q14-U17** | Q14-J17 — Operações de Solicitação de Concessões/Folgas | `q14-uat-concessoes-solicitada.png`, `q14-uat-concessoes-detalhes-cancelada.png` | **APROVADO** | **ACEITO COM RESSALVA** | Técnico: agendamento, cancelamento e isolamento cross-object. Humano: OBSERVAÇÃO-HUMANA-Q14-002 (ações no sandbox). |
| **Q14-U18** | Q14-J18 — Diagnóstico e Registro de Notificações Push (FCM) | Log de auditoria backend (`mobile-service`) | **APROVADO COM RESSALVA** | **ACEITO** | Técnico: sandbox FCM com isolamento. Humano: diagnóstico e status aceitos. |

---

## 4. Avaliação Humana e Aceite Institucional

### 4.1 Dados Formais do Avaliador
- **Nome:** Rafael Vasconcelos
- **Cargo/função:** Analista de Desenvolvimento de Sistema
- **Unidade:** DITEC
- **Data da Avaliação:** 04/10/2026
- **Assinatura:** PENDENTE DE FORMALIZAÇÃO, SE EXIGIDA PELO PROCESSO INSTITUCIONAL

### 4.2 Resultados da Avaliação Humana
- **Jornadas Avaliadas:** 18 / 18 (100%)
- **ACEITO:** 15
- **ACEITO COM RESSALVA:** 3 (Q14-J04, Q14-J05, Q14-J17)
- **NÃO ACEITO:** 0
- **NÃO AVALIADO:** 0
- **BUGS CONFIRMADOS DURANTE O ACEITE:** 0

### 4.3 Observações Humanas Registradas (Não Bloqueadoras)
1. **OBSERVAÇÃO-HUMANA-Q14-001 (Q14-J04 — Diário Oficial):** Durante o aceite humano no ambiente UAT, o Diário Oficial apresentou mensagem orientativa ("Não foi possível carregar os diários oficiais. Verifique sua conexão."). Trata-se de observação do ambiente/UAT, não confirmada como bug de produção e não bloqueadora para o aceite final.
2. **OBSERVAÇÃO-HUMANA-Q14-002 (Q14-J17 — Concessões/Folgas):** O cancelamento exibiu mensagem de sucesso mas manteve a solicitação visível; a ação "Interromper" permaneceu disponível e ao executá-la não houve alteração perceptível em tela, gerando percepção de comportamento confuso no sandbox sintético; solicitação exibia situação não informada no ambiente sintético. Tecnicamente, o backend sandbox recebeu e processou as requisições. Trata-se de comportamento pontual do sandbox/massa sintética, não constituindo regressão de código de produção e não bloqueadora para o aceite final.
3. **OBSERVAÇÃO-HUMANA-Q14-003 (Q14-J05 — Consulta Processual):** Falha/lentidão no carregamento dos filtros adicionais no ambiente UAT. Trata-se de observação do ambiente/UAT, não confirmada como bug de produção e não bloqueadora para o aceite final.

### 4.4 Decisão Final Negocial
```text
DECISÃO DO AVALIADOR:
ACEITO INTEGRALMENTE
```
O avaliador institucional manifestou formal e expressamente o **ACEITE INTEGRAL** do produto em conformidade com o Termo de Homologação e Aceite Final (`qualidade/uat/Q14-termo-aceite.md`).

---

## 5. Prontidão para Store Review

```text
GOOGLE/APPLE STORE REVIEW:
NÃO PRONTO — BLOQUEIO-Q14-REVIEW-001
```
Motivos:
1. Contas REVIEW ainda não provisionadas operacionalmente pelas equipes de suporte;
2. Backend externo acessível aos revisores ainda não definido/implantado na infraestrutura de rede;
3. Modo sintético permanece estritamente bloqueado em builds de produção;
4. Estratégia de Store Review constitui frente operacional separada da homologação funcional do aplicativo.

---

## 6. Conclusão e Estado do Ciclo

```text
STATUS DA FASE:
Q14 CONCLUÍDA — PRÉ-UAT TÉCNICO CONSOLIDADO E ACEITE HUMANO INSTITUCIONAL REALIZADO

STATUS DO CICLO DE QUALIDADE:
CICLO Q1–Q14 CONCLUÍDO
```

Com o encerramento da avaliação técnica com 100% de gates aprovados e a manifestação institucional inequívoca de **ACEITO INTEGRALMENTE** pelo responsável da DITEC, a fase **Q14** e o **Ciclo Completo de Qualidade (Q1 a Q14)** encontram-se formalmente concluídos. Não criar fase Q15.
