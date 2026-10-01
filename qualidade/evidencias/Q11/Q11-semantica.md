# Q11 — Evidência de Semântica e Rótulos Acessíveis (Q11-T01, Q11-T03, Q11-T13)

Data: 01/10/2026  
Status: PASSOU

---

## 1. Escopo e Metodologia

Foi realizada auditoria estática e automatizada com `WidgetTester`, `SemanticsTester` e guideline `labeledTapTargetGuideline` para verificar se todos os elementos acionáveis possuem nomes acessíveis não ambíguos e se imagens decorativas estão devidamente excluídas da árvore semântica do sintetizador de voz.

## 2. Controles Auditados e Achados

### 2.1 MppbAppBar
- **Problema Inicial (BUG-Q11-001)**: `IconButton` de notificações e `IconButton` de logout eram instanciados sem `tooltip`. O brasão institucional era processado como elemento de imagem genérico sem utilidade semântica.
- **Correção Aplicada**:
  - Inserido `tooltip: notificationItems.isEmpty ? 'Notificações' : 'Notificações (${notificationItems.length} novas)'`.
  - Inserido `tooltip: 'Sair da conta'` no botão de desautenticação.
  - Brasão envelopado com `ExcludeSemantics`.
  - `_HomeTapTarget` mantido com `tooltip: 'Início'`.

### 2.2 LoginPage
- **Problema Inicial (BUG-Q11-002)**: Botão voltar sem `tooltip`. Brasão lido desnecessariamente.
- **Correção Aplicada**:
  - Adicionado `tooltip: 'Voltar'` no `IconButton` do topo.
  - Brasão envelopado com `ExcludeSemantics`.
  - Botão de exibir/ocultar senha possui tooltip dinâmico `'Mostrar senha'` / `'Ocultar senha'`.

### 2.3 Paginação e Modais (Notícias, Diário Oficial, Processos, Contracheque, Certidão, Ouvidoria)
- **Problema Inicial (BUG-Q11-005)**: `IconButton`s de avançar/voltar página em `NoticiasPage` e `DiarioOficialPage` não tinham texto semântico, sendo anunciados apenas como "botão". Modais de detalhes e leitores de PDF possuíam botão `Icons.close` sem rótulo. Botão de exclusão de anexo na Ouvidoria (`StepAnexos`) não tinha rótulo.
- **Correção Aplicada**:
  - `NoticiasPage`: `tooltip: 'Página anterior'` e `tooltip: 'Próxima página'`.
  - `DiarioOficialPage`: `tooltip: 'Página anterior'` e `tooltip: 'Próxima página'`.
  - `NewsDetailSheet` e modais: `tooltip: 'Fechar'`.
  - `ConsultaProcessosPage`: `tooltip: 'Fechar'` e `tooltip: 'Recarregar captcha'`.
  - Visualizadores de PDF (`DiarioOficialPage`, `ContraChequePage`, `CertidaoExtrajudicialPage`): `tooltip: 'Fechar'`.
  - `StepAnexos`: `tooltip: 'Remover anexo'`.

### 2.4 Carteira Funcional (CarteiraPage)
- **Problema Inicial (BUG-Q11-006)**: Gesto de tocar na carteira para girá-la (`_flipCard`) não tinha indicação semântica. O código QR era lido apenas como imagem genérica.
- **Correção Aplicada**:
  - Adicionado `Semantics(button: true, label: _isFront ? 'Virar para o verso da carteira funcional' : 'Virar para a frente da carteira funcional')`.
  - Adicionado no QR Code: `Semantics(label: 'Código QR para validação da carteira funcional por leitor externo')` — respeitando a diretriz de não verbalizar nem expor tokens sensíveis no leitor de tela.

### 2.5 Dock de Navegação (MainLayout)
- **Problema Inicial (BUG-Q11-007)**: Rótulos abreviados (`Contr.`, `Cart.`, `Proc.`, `Diár.`, `Desig.`, `Notíc.`, `Ouvid.`) eram sintetizados de forma truncada.
- **Correção Aplicada**:
  - Criado helper `_getAccessibleLabelFor` mapeando cada chave para seu nome institucional completo (`Contracheque`, `Carteira Funcional`, `Processos`, `Diário Oficial`, `Concessão de Afastamento`, `Pagamentos`, `Designações`, `Notícias`, `Ouvidoria`).
  - Cada item do dock envelopado em `Semantics(button: true, selected: isSelected, label: accessibleLabel)`.

## 3. Resultado dos Testes de Regressão

```text
Q11-T01 — Labels Semânticos e Tooltips em Controles:
✓ MppbAppBar pública possui tooltips acessíveis em ações e ExcludeSemantics no brasão
✓ MppbAppBar autenticada possui tooltip Sair da conta
✓ LoginPage possui tooltip no botão voltar e ExcludeSemantics no brasão
✓ CarteiraPage possui semântica para flip card e QR Code informativo
✓ LoginPage atende labeledTapTargetGuideline
✓ MppbAppBar atende labeledTapTargetGuideline
```
Status: PASSOU sem falhas.
