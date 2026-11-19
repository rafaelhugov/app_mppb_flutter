# Especificação de Funcionalidade: Ajuste Visual e Padronização com o Design System MPPB+ (`app_mppb_flutter`)

**Branch da Feature**: `feat/ajuste-visual-mensagens`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `001-mensagens-avisos`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Padronização de Cabeçalho e Navegação no `ShellRoute` (`MainLayout`) (Priority: P1)

Como membro ou servidor autenticando no aplicativo **MPPB+**, quero que as telas de **Mensagens e Avisos** utilizem o cabeçalho institucional padrão (`HeroHeaderPublico`) integrado ao `MainLayout` (sem duplicar `AppBar` azul-escuro abaixo da `MppbAppBar`) e respeitem o espaçamento inferior da barra de navegação flutuante (`MainLayout.contentBottomPadding`), para que a experiência visual seja idêntica às demais funcionalidades do app (`Designações Ativas`, `Concessão de Afastamento`, `Pagamentos`).

**Teste Independente**: Abrir `/mensagens` e `/mensagens/painel` dentro do `MainLayout` e verificar a presença única da `MppbAppBar` no topo seguida do `HeroHeaderPublico`, sem segunda `AppBar` escura e sem sobreposição da barra flutuante inferior.

**Critérios de Aceitação**:

1. **Dado** qualquer tela do módulo `mensagens` renderizada dentro do `ShellRoute` (`CaixaMensagensPage`, `MensagemDetalhePage`, `PainelRemetentePage`, `ComporMensagemPage`, `AcompanhamentoMensagemPage`, `GruposPersonalizadosPage`), **Quando** a tela é exibida, **Então** utiliza `HeroHeaderPublico` (com botão circular de voltar e `rightWidget` contextual) em vez de um segundo `AppBar(backgroundColor: Color(0xFF1E293B))`.
2. **Dado** listas ou botões de ação inferiores nas telas de `mensagens`, **Quando** o usuário rola até o fim da tela, **Então** o espaçamento aplica `MainLayout.horizontalPadding(context)` e `MainLayout.contentBottomPadding(context)` para que nenhum card ou botão fique oculto atrás da barra de navegação flutuante do `MainLayout`.

---

### História de Usuário 2 - Paleta de Cores MPPB+, Seletor Segmentado em Pílula e Cards Institucionais (Priority: P1)

Como usuário do **MPPB+**, quero que o fundo das telas, o seletor de filtros (`Todas`, `Não lidas`, `Arquivadas`), os estados vazio/offline, as bolhas de mensagem e os players de mídia sigam estritamente a paleta e a identidade visual do aplicativo (`#F7F8F6` background, `#202322` ink/brand dark, `#697370` muted, `#FFFFFF` surface, `#E9EDF0` border, `#00A86B` verde institucional, `#D62828` vermelho institucional, `#2563EB` azul, `#F97316` laranja), eliminando o fundo esverdeado (`#EFF6EE`), a barra azul-marinho (`#1E293B`) e os chips desalinhados.

**Teste Independente**: Renderizar `CaixaMensagensPage` nos estados carregando, erro/offline, vazio e com mensagens contendo texto, áudio, imagem e ciência pendente, validando cores, tipografia e alvos de toque (≥ 48dp).

**Critérios de Aceitação**:

1. **Dado** a tela `CaixaMensagensPage`, **Quando** exibida, **Então** o fundo é `Color(0xFFF7F8F6)` e os filtros (`Todas`, `Não lidas`, `Arquivadas`) são apresentados no seletor segmentado estilo pílula escura (`Color(0xFF202322)` com indicador ativo branco `BorderRadius.circular(14)`), idêntico ao padrão de `ConcessaoAfastamentoPage`.
2. **Dado** uma falha de rede ou estado offline na listagem, **Quando** exibido o estado de erro, **Então** o componente segue o padrão visual de `DesignacoesPage` (ícone `Icons.wifi_off` em `Color(0xFF202322)`, texto centralizado e botão `Tentar novamente` estilizado com a paleta MPPB+).
3. **Dado** um aviso na lista ou no detalhe (`MensagemBolhaCard`), **Quando** renderizado, **Então** utiliza superfície branca (`#FFFFFF`), borda `Color(0xFFE9EDF0)` (ou destaque na cor da prioridade quando não lido), badges institucionais (`#D62828` Urgente, `#F97316` Importante, `#2563EB` Aviso, `#00A86B` Novo/Ciência Confirmada) e player de áudio/mídia harmonizado com `#00A86B` e `#202322`.

## Requisitos *(obrigatório)*

### Requisitos Funcionais e Visuais

- **FR-001**: Criar `MensagensTheme` (`lib/features/mensagens/ui/widgets/mensagens_theme.dart`) centralizando os tokens de cor, sombras, bordas e estilos de botão do Design System MPPB+ (sem uso de cores roxas/violetas — *Purple Ban*).
- **FR-002**: Substituir `AppBar(backgroundColor: Color(0xFF1E293B))` por `HeroHeaderPublico` em todas as 6 páginas do fluxo autenticadas no `ShellRoute` (`CaixaMensagensPage`, `MensagemDetalhePage`, `PainelRemetentePage`, `ComporMensagemPage`, `AcompanhamentoMensagemPage`, `GruposPersonalizadosPage`).
- **FR-003**: Substituir a barra branca de `ChoiceChip` em `CaixaMensagensPage` por um seletor segmentado em pílula (`Color(0xFF202322)`) alinhado ao padrão visual de `ConcessaoAfastamentoPage`.
- **FR-004**: Aplicar `MainLayout.horizontalPadding(context)` e `MainLayout.contentBottomPadding(context)` nas listas e formulários do módulo `mensagens`, garantindo que ações primárias (como `Novo Aviso` e `Novo Grupo`) fiquem acessíveis no cabeçalho/barra de topo ou acima do `contentBottomPadding` sem colidir com a bottom bar flutuante.
- **FR-005**: Atualizar `MensagemBolhaCard`, `AudioPlayerCard`, `AudioRecorderBar`, `AnexoPreviewWidget` e `SeletorDestinatariosWidget` para utilizar os tokens de `MensagensTheme` mantendo todos os testes de widget verdes e `flutter analyze` com zero problemas.

