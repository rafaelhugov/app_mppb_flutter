# Especificação de Funcionalidade: UX estilo Mensageiro (WhatsApp/Telegram) + Formatação + Correções Visuais (`app_mppb_flutter`)

**Branch da Feature**: `feat/ux-mensageiro-compor-avisos`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `004-padronizacao-botoes-compor-mensagens`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Correção de Espaçamento, Overflow do Gravador de Áudio e Tema do Calendário/Relógio (Priority: P1)

Como remetente no **Painel de Avisos**, ao gravar ou pré-visualizar um áudio e ao escolher data/hora de agendamento ou expiração:
1. O gravador de áudio deve ter espaçamento inferior (`12px`) para não colar nos cards abaixo, texto de tempo sem quebra indesejada e botões (`Descartar` e `Anexar áudio`) com `Expanded` para **zero overflow** em telas estreitas.
2. Os seletores `showDatePicker` e `showTimePicker` devem aplicar o tema oficial **MPPB+** (`#202322` / `#FFFFFF` / `#F7F8F6` / `#00A86B`), eliminando o tom amarronzado/rosado herdado do tema padrão.

### História de Usuário 2 - Formatação de Texto (Markdown) no Compositor e na Bolha de Mensagem (Priority: P1)

Como remetente, quero uma barra de formatação no campo de mensagem (**Negrito**, **Itálico**, **Tachado**, **Lista**, **Link** e alternância **Pré-visualizar**) para estruturar comunicados institucionais com clareza, e quero que o destinatário veja essa formatação renderizada dentro da bolha de mensagem (`MarkdownBody`).

### História de Usuário 3 - Layout estilo Mensageiro Moderno (WhatsApp/Telegram) Adaptado ao MPPB+ (Priority: P1)

Como usuário do **MPPB+**, quero que a tela de composição de avisos e os cards de mensagem tenham fluidez visual inspirada em mensageiros modernos (WhatsApp/Telegram) usando a identidade visual do **MPPB+**:
- Barra de composição limpa com campo de mensagem + barra de formatação + bandeja compacta de anexos em 4 colunas uniformes (`Áudio`, `Foto`, `Vídeo`, `Arquivo` com ícones circulares/squircle coloridos).
- Toggle de **"Confirmar ciência"** redesenhado como cartão moderno (ícone `verified_user_outlined`, descrição clara e `Switch` estilizado em `#00A86B`), integrado ao bloco de configurações de envio junto com Agendamento e Expiração.
- Bolhas de mensagem (`MensagemBolhaCard`) com visual mais leve e conversacional (cabeçalho do remetente limpo, conteúdo Markdown formatado, mídias inline e rodapé discreto com horário e duplo check de leitura).

## Requisitos *(obrigatório)*

- **FR-001**: Corrigir `AudioRecorderBar` (`lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`) adicionando `margin: EdgeInsets.only(bottom: 12)` e botões `Descartar` / `Anexar áudio` com `Expanded` (sem `RenderFlex overflow`).
- **FR-002**: Aplicar tema MPPB+ (`ColorScheme.light(primary: MensagensColors.brandDark, secondary: MensagensColors.green, surface: MensagensColors.surface, onSurface: MensagensColors.ink)`) no `builder` de `showDatePicker` e `showTimePicker` em `ComporMensagemPage`.
- **FR-003**: Substituir o `SwitchListTile` padrão por um cartão estilizado de confirmação de ciência integrado ao bloco de configurações de envio.
- **FR-004**: Adicionar barra de formatação Markdown (`B`, `I`, `S`, `Lista`, `Link`, `Prévia`) em `ComporMensagemPage` e renderizar `mensagem.conteudo` com `MarkdownBody` em `MensagemBolhaCard`.
- **FR-005**: Reorganizar a bandeja de anexos em linha uniforme de 4 ações estilo mensageiro (`Áudio`, `Foto`, `Vídeo`, `Arquivo`) e refinar a estética de `ComporMensagemPage` e `MensagemBolhaCard` mantendo `flutter analyze` com 0 erros e `flutter test test/features/mensagens` 100% aprovado.
