# Especificação de Funcionalidade: Padronização e Elegância dos Botões de Composição de Aviso (`app_mppb_flutter`)

**Branch da Feature**: `feat/ajuste-botoes-compor-mensagens`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `003-ajuste-botao-painel-mensagens`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Grade Uniforme 2x2 para Mídias e Anexos (Priority: P1)

Como remetente autorizado no **Painel de Avisos**, ao compor um novo comunicado, quero que as opções de anexar mídia (**Áudio**, **Foto**, **Vídeo**, **Documento**) sejam apresentadas em uma **grade uniforme 2x2** com cards de mesmo tamanho, espaçamento e hierarquia visual elegante, substituindo os botões desalinhados e de larguras diferentes.

**Teste Independente**: Abrir `ComporMensagemPage` e verificar a presença dos 4 cards uniformes (`Áudio`, `Foto`, `Vídeo`, `Documento`) com altura e largura proporcionais e toque mínimo ≥ 48dp. Ao acionar `Áudio`, o gravador inline (`AudioRecorderBar`) entra no estado de gravação e pré-visualização.

### História de Usuário 2 - Cartão Agrupado de Agendamento e Expiração (Priority: P1)

Como remetente autorizado, quero que as opções **Agendar envio** e **Definir expiração** sejam apresentadas em um único bloco agrupado estilo configurações (com ícone, título, valor atual ou `"Imediato"` / `"Sem expiração"` e ação limpar/editar), eliminando a repetição de botões grandes empilhados.

**Teste Independente**: Renderizar `ComporMensagemPage` e verificar o bloco agrupado `"Agendamento e Validade"` com as linhas `"Agendar envio"` e `"Expiração do aviso"` e o botão primário único `"Enviar Aviso Agora"`.

## Requisitos *(obrigatório)*

- **FR-001**: Refatorar `AudioRecorderBar` (`lib/features/mensagens/ui/widgets/audio_recorder_bar.dart`) para aceitar um `GlobalKey<AudioRecorderBarState>` ou callback/builder de controle externo, exibindo o painel de gravação/pré-visualização inline quando ativo e integrando o gatilho no card uniforme **Áudio** da grade 2x2.
- **FR-002**: Substituir a lista irregular de botões (`Gravar mensagem de áudio`, `Foto`, `Vídeo`, `Documento (...)`) em `ComporMensagemPage` por uma grade 2x2 de cards uniformes (`_MidiaActionTile`) com ícone em badge colorido (`MensagensColors.green`, `blue`, `orange`, `red`), título curto e subtítulo descritivo.
- **FR-003**: Substituir os dois botões largos (`Agendar envio` e `Definir expiração`) por um único cartão agrupado (`_OpcoesAgendamentoCard`) com duas linhas padronizadas separadas por `Divider`, mantendo o único botão CTA primário em destaque no rodapé do formulário (`Enviar Aviso Agora` / `Confirmar Agendamento`).
- **FR-004**: Garantir `flutter analyze` sem problemas e `flutter test test/features/mensagens` com 100% de aprovação (incluindo teste de widget para `ComporMensagemPage`).
