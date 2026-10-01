# Relatório Final de Auditoria e Validação — Q11 Acessibilidade

Data: 01/10/2026 (Reconciliação e Consolidação Q11-R01)  
Repositório Flutter: `C:\Users\rafae\projetosMPPB\app_mppb_flutter`  
Branch: `qualidade/q11-acessibilidade` (base `f7979b9`)  
Dispositivo Físico: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, serial `RX8RC09H70X`)  
Status Git: Consolidação local em commit único e merge ff-only na master. `pubspec.yaml +69 -> +72` estritamente preservado.  

---

## 1. Resumo Executivo e Resposta ao Objetivo Canônico

A fase **Q11 — Acessibilidade** teve como objetivo central responder à questão canônica:
> *"O aplicativo pode ser utilizado por pessoas com limitações visuais, motoras ou de leitura sem barreiras evitáveis?"*

**Resposta Técnica**:
**Sim**. No escopo das plataformas e fluxos testados, todas as barreiras objetivas detectadas na auditoria técnica foram registradas como bugs formais (BUG-Q11-001 a BUG-Q11-008), devidamente corrigidas sem refatorações estéticas supérfluas e integralmente protegidas por 33 testes de acessibilidade automatizados (`androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`, validação de `TextScaler` até 2.0x portrait e landscape, asserções de semântica e `SemanticsTester`).

---

## 2. Inventário de Componentes e Telas

Foram mapeadas **17 telas e componentes centrais**, categorizados estritamente por nível de evidência:
- **9 Componentes com Nível `TESTADO`** (exercitados diretamente por testes automatizados e guidelines):
  - `MppbAppBar` (Pública e Autenticada);
  - `MainLayout` (Dock inferior);
  - `PublicDashboardPage` (Home Pública);
  - `LoginPage`;
  - `NoticiasPage`;
  - `DiarioOficialPage`;
  - `ConsultaProcessosPage`;
  - `CarteiraPage`;
  - `ContraChequePage`.
- **8 Componentes com Nível `INSPECIONADO`** (auditados estaticamente no código com reutilização de componentes base validados):
  - `NewsDetailSheet` / Modais;
  - `ContatosPage` e seções;
  - `CertidaoExtrajudicialPage`;
  - `StepAnexos` (Ouvidoria);
  - `PerfilPage`;
  - `PagamentosPage`;
  - `DesignacoesPage`.

---

## 3. Registro e Resolução de Bugs (BUG-Q11)

| ID | Tela | Problema Encontrado | Severidade | Correção Aplicada | Teste de Regressão |
|---|---|---|---|---|---|
| **BUG-Q11-001** | `MppbAppBar` | `IconButton`s de notificações e logout sem tooltips/labels; brasão decorativo anunciado por leitor de voz | Média | Adicionados tooltips descritivos com contagem dinâmica e `ExcludeSemantics` no brasão | `MppbAppBar pública possui tooltips...`, `labeledTapTargetGuideline`, `iOSTapTargetGuideline` |
| **BUG-Q11-002** | `LoginPage` | Botões secundários com altura de 42dp-46dp (< 48dp), botão voltar sem tooltip e brasão sem `ExcludeSemantics` | Média | Altura mínima ajustada para 48dp, tooltip 'Voltar' inserido e `ExcludeSemantics` no brasão | `LoginPage atende androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` |
| **BUG-Q11-003** | `PublicDashboardPage` | RenderFlex overflow de 73 pixels no cabeçalho da seção "Notícias" quando renderizada sob `textScaler: 2.0` | Média | Substituição da `Row` rígida por `Wrap` flexível com quebra automática harmônica | `PublicDashboardPage não apresenta overflow com textScaler 2.0`, teste landscape |
| **BUG-Q11-004** | `ConsultaProcessosPage` | Cabeçalho dos filtros com overflow sob `textScaler: 2.0`, botão pesquisar com altura de 44dp e loading spinner sem semântica | Média | Envolvido em `Wrap`, altura de 48dp garantida e `semanticsLabel` no CircularProgressIndicator | `ConsultaProcessosPage não apresenta overflow com textScaler 2.0`, teste landscape |
| **BUG-Q11-005** | `NoticiasPage`, `DiarioOficialPage`, modais, PDF viewers e `StepAnexos` | `IconButton`s de paginação, fechamento de modais/PDFs e remoção de anexo sem rótulo textual | Baixa | Adicionados tooltips acessíveis ('Página anterior', 'Próxima página', 'Fechar', 'Recarregar captcha', 'Remover anexo') | Verificação de Semantics e tooltips na suite Q11 |
| **BUG-Q11-006** | `CarteiraPage` | Gesto de toque para virar frente/verso sem indicação semântica e QR Code lido como imagem genérica | Média | Adicionado `Semantics(button: true, label: ...)` para virar cartão e `Semantics` no QR Code indicando validação externa sem expor dados sensíveis | `CarteiraPage possui semântica para flip card e QR Code informativo` |
| **BUG-Q11-007** | `MainLayout` | Dock com abreviações truncadas ('Contr.', 'Cart.', 'Proc.') gerando anúncio ininteligível | Média | Inserido mapeamento semântico completo expandido por extenso em cada item do dock | Mapeamento semântico validado |
| **BUG-Q11-008** | `LoginPage` | Container de erro dependia apenas de texto/cor sem ícone de apoio visual e sem anúncio assíncrono para o leitor de voz | Média | Adicionado ícone de aviso e `Semantics(liveRegion: true)` para verbalização imediata pelo sintetizador | `Mensagem de erro de login possui ícone, texto e liveRegion` |

---

## 4. Reconciliação dos Critérios Metodológicos

### 4.1 Q11-C19 — Font Scale em Android Físico (PASSOU)
- Procedimento realizado no Samsung Galaxy A52 (`SM-A525M`):
  1. `font_scale = 1.1` original registrado via ADB;
  2. Ajustado para `1.3`;
  3. App homolog reaberto e fluxo mínimo percorrido na tela física: `Home` → `Notícias` → `Home` → `Login` → `Processos`;
  4. Inspeção visual confirmou zero overflow, zero corte de texto e controles plenamente acionáveis (evidências: `q11_home_scale13.png`, `q11_noticias_scale13.png`, `q11_login_scale13.png`, `q11_processos_scale13.png`);
  5. Escala de fonte **obrigatoriamente restaurada para 1.1** e confirmada via `adb shell settings get system font_scale`.

### 4.2 Q11-C20 — Display Size / Density (PARCIAL)
- **Classificação**: `PARCIAL — densidade física original aferida e preservada; variação de display size/density não executada no aparelho pessoal; responsividade complementar coberta por testes de viewport`.
- Densidade física original `420` mantida intacta.

### 4.3 Q11-C30 — Landscape + Text Scaling 2.0x (PASSOU)
- Testes automatizados executados especificamente em viewport landscape (2400×1080) sob `TextScaler.linear(2.0)` em `PublicDashboardPage`, `LoginPage` e `ConsultaProcessosPage`.
- Resultado: 0 overflows, 0 exceções de layout, controles 100% renderizados.

### 4.4 Guidelines de Touch Target (Android e iOS)
- Diretriz Android: `androidTapTargetGuideline` (48×48dp) testada e aprovada.
- Diretriz iOS: `iOSTapTargetGuideline` (44×44pt) testada e aprovada.
- Enquadramento WCAG: **WCAG 2.2 — SC 2.5.8 Target Size (Minimum), Nível AA**. O limiar normativo mínimo é de 24×24 CSS px (com exceções); as diretrizes de 48×48dp (Material) e 44×44pt (iOS) adotadas são mais conservadoras que o mínimo do SC 2.5.8.

### 4.5 Contraste Recalculado e Delimitado (Q11-C13, Q11-C14)
- Razões de contraste espectrais WCAG 2.2:
  - `#D62828 / #FFFFFF ≈ 5.01:1` (atende WCAG AA);
  - `#202322 / #FFFFFF ≈ 15.85:1` (atende WCAG AAA);
  - `#697370 / #FFFFFF ≈ 4.90:1` (atende WCAG AA);
  - `#202322 / #F7F8F6 ≈ 14.88:1` (atende WCAG AAA).
- Delimitação: As combinações de cores institucionais explicitamente auditadas atendem aos limiares registrados; `LoginPage` passou `textContrastGuideline`; gradientes complexos, imagens e elementos com opacidade dinâmica permanecem fora da afirmação global.

### 4.6 TalkBack (Q11-C21)
- **Classificação**: `PARCIAL — roteiro manual definido, não executado com TalkBack ativo`.
- Pacote presente no Galaxy A52; serviço inativo por padrão e não habilitado invasivamente; semântica subjacente validada por testes de widget.

### 4.7 iOS VoiceOver (Q11-C31, Q11-C32)
- Auditoria Estática (`Q11-C31`): `PASSOU — estrutura compartilhada é compatível com os mecanismos Flutter/iOS auditados; comportamento runtime VoiceOver/Dynamic Type não foi aferido em hardware Apple`.
- Runtime VoiceOver (`Q11-C32`): `BLOQUEADO POR LIMITAÇÃO DE AMBIENTE`.

---

## 5. Resumo Estatístico da Matriz Q11

- **PASSOU**: 29
- **PARCIAL**: 2 (C20 Display density; C21 TalkBack)
- **FALHOU**: 0
- **BLOQUEADO**: 1 (C32 Runtime VoiceOver iOS)
- **N/A**: 0
- **Total de Critérios**: **32**

---

## 6. Portões de Regressão e Segurança

- `flutter analyze`: **0 issues** (verde).
- `flutter test`: **220/220 testes passando** (187 legados + 33 novos testes específicos da Q11 em [q11_acessibilidade_test.dart](file:///C:/Users/rafae/projetosMPPB/app_mppb_flutter/test/features/acessibilidade/q11_acessibilidade_test.dart)).
- `secret_scan.sh`: Exit code 0 (verde).
- `security_regression.sh`: Exit code 0 (verde).
- Android build: `app-homolog-debug.apk` compilado com sucesso com flavor homolog (`assembleHomologDebug`).

---

## 7. Declaração Formal de Conclusão e Prontidão

**Q11 DEFINITIVAMENTE ENCERRADA E DOCUMENTALMENTE CONSISTENTE**

**Q11 CONCLUÍDA — ACESSIBILIDADE VALIDADA NO ESCOPO TESTADO**

`Q12 NÃO INICIADA`

`BASE PRONTA PARA Q12`
