# Matriz de Rastreabilidade — Q11

Data: 01/10/2026 (Reconciliado Q11-R01)  
Status Global: VALIDADO NO ESCOPO TESTADO

---

## 1. Rastreabilidade Requisitos Funcionais × Acessibilidade

| RF | Tela/Componente | Teste Automatizado | Critério de Acessibilidade | Evidência | BUG-Q11 |
|---|---|---|---|---|---|
| RF01 (Autenticação) | LoginPage | `LoginPage possui tooltip no botão voltar e ExcludeSemantics no brasão`, `LoginPage atende androidTapTargetGuideline e labeledTapTargetGuideline`, `LoginPage atende iOSTapTargetGuideline` | WCAG 2.2 — SC 2.5.8 Target Size (Minimum), nível AA (guideline Flutter/Material de 48x48dp e iOS de 44x44pt mais conservadoras que o mínimo de 24x24 CSS px), SC 4.1.2 (Name/Role/Value), SC 1.1.1 (Non-text Content) | `Q11-semantica.md`, `Q11-touch-targets.md` | BUG-Q11-002 |
| RF01 (Autenticação) | LoginPage | `Campos de login possuem labels persistentes e foco sequencial correto` | WCAG 2.2 — SC 3.3.2 (Labels or Instructions), SC 2.4.3 (Focus Order) | `Q11-formularios.md` | — |
| RF01 (Autenticação) | LoginPage | `Botão mostrar/ocultar senha possui tooltip dinâmico` | WCAG 2.2 — SC 4.1.2 (Name, Role, Value) | `Q11-semantica.md` | — |
| RF01 (Autenticação) | LoginPage | `Mensagem de erro de login possui ícone, texto e liveRegion` | WCAG 2.2 — SC 3.3.1 (Error Identification), SC 4.1.3 (Status Messages), SC 1.4.1 (Use of Color) | `Q11-formularios.md` | BUG-Q11-008 |
| RF01 (Autenticação) | LoginPage | `LoginPage atende textContrastGuideline em seus elementos mensuráveis` | WCAG 2.2 — SC 1.4.3 (Contrast Minimum) | `Q11-contraste.md` | — |
| RF01 (Autenticação) | LoginPage | `LoginPage não apresenta overflow com textScaler 1.0, 1.3, 1.5, 2.0`, `LoginPage em landscape com TextScaler 2.0 não apresenta overflow` | WCAG 2.2 — SC 1.4.4 (Resize Text), SC 1.3.4 (Orientation) | `Q11-text-scaling.md` | — |
| RF02 (Navegação Global) | MppbAppBar | `MppbAppBar pública e autenticada possuem tooltips acessíveis e ExcludeSemantics no brasão` | WCAG 2.2 — SC 4.1.2 (Name/Role/Value), SC 1.1.1 (Non-text Content) | `Q11-semantica.md` | BUG-Q11-001 |
| RF02 (Navegação Global) | MppbAppBar | `MppbAppBar atende androidTapTargetGuideline, iOSTapTargetGuideline e labeledTapTargetGuideline` | WCAG 2.2 — SC 2.5.8 Target Size (Minimum), nível AA (48x48dp Android, 44x44pt iOS), SC 4.1.2 (Name/Role/Value) | `Q11-touch-targets.md` | BUG-Q11-001 |
| RF02 (Navegação Global) | MainLayout (Dock) | `MainLayout mapeia abreviações visuais para termos expandidos em Semantics` | WCAG 2.2 — SC 4.1.2 (Name/Role/Value) | `Q11-semantica.md` | BUG-Q11-007 |
| RF03 (Home Cidadão) | PublicDashboardPage | `PublicDashboardPage não apresenta overflow com textScaler 1.0, 1.3, 1.5, 2.0`, `PublicDashboardPage em landscape com TextScaler 2.0 não apresenta overflow` | WCAG 2.2 — SC 1.4.4 (Resize Text), SC 1.3.4 (Orientation) | `Q11-text-scaling.md` | BUG-Q11-003 |
| RF04 (Notícias) | NoticiasPage | `NoticiasPage paginação anterior/próxima e fechar modal` | WCAG 2.2 — SC 4.1.2 (Name, Role, Value) | `Q11-semantica.md` | BUG-Q11-005 |
| RF05 (Contatos) | ContatosPage | Seções com `Flexible` e responsividade em escala 2.0x | WCAG 2.2 — SC 1.4.4 (Resize Text) | `Q11-text-scaling.md` | — |
| RF06 (Diário Oficial) | DiarioOficialPage | `DiarioOficialPage não apresenta overflow com textScaler 1.0, 1.3, 1.5, 2.0` | WCAG 2.2 — SC 1.4.4 (Resize Text), SC 4.1.2 (Name/Role/Value) | `Q11-text-scaling.md`, `Q11-semantica.md` | BUG-Q11-005 |
| RF07 (Processos) | ConsultaProcessosPage | `ConsultaProcessosPage não apresenta overflow com textScaler 1.0, 1.3, 1.5, 2.0`, `ConsultaProcessosPage em landscape com TextScaler 2.0 não apresenta overflow` | WCAG 2.2 — SC 1.4.4 (Resize Text), SC 2.5.8 Target Size (Minimum), SC 4.1.2 (Name/Role/Value), SC 1.3.4 (Orientation) | `Q11-text-scaling.md`, `Q11-semantica.md` | BUG-Q11-004 |
| RF08 (Carteira Funcional) | CarteiraPage | `CarteiraPage possui semântica para flip card e QR Code informativo` | WCAG 2.2 — SC 1.1.1 (Non-text Content), SC 4.1.2 (Name/Role/Value) | `Q11-semantica.md` | BUG-Q11-006 |
| RF09 (Contracheque) | ContraChequePage | `ContraChequePage não apresenta overflow com textScaler 1.0, 1.3, 1.5, 2.0` | WCAG 2.2 — SC 1.4.4 (Resize Text), SC 4.1.2 (Name/Role/Value) | `Q11-text-scaling.md`, `Q11-semantica.md` | BUG-Q11-005 |
| RF10 (Certidão) | CertidaoExtrajudicialPage | Inspeção semântica do visualizador e botão fechar com tooltip | WCAG 2.2 — SC 4.1.2 (Name/Role/Value) | `Q11-semantica.md` | BUG-Q11-005 |
| RF11 (Ouvidoria) | StepAnexos | Inspeção de botão de exclusão de anexo com tooltip descritivo | WCAG 2.2 — SC 4.1.2 (Name/Role/Value) | `Q11-semantica.md` | BUG-Q11-005 |
