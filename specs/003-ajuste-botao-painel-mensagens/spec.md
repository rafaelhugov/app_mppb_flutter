# Especificação de Funcionalidade: Reposicionamento e Clareza do Acesso ao Painel Administrativo de Avisos (`app_mppb_flutter`)

**Branch da Feature**: `feat/ajuste-painel-mensagens`  
**Criado em**: 2026-11-19  
**Status**: Aprovado para Implementação  
**Subprojeto**: `app_mppb_flutter`  
**Feature Base**: `002-ajuste-visual-mensagens`

## Cenários de Usuário e Testes *(obrigatório)*

### História de Usuário 1 - Acesso Claro ao Painel de Envio Sem Sobrepor o Título no Cabeçalho (Priority: P1)

Como usuário administrador (`androidmppb.mensagens.admin`), ao abrir **Mensagens e Avisos**, quero que o cabeçalho `HeroHeaderPublico` exiba o título **"Mensagens e Avisos"** de forma limpa (sem que o botão **Painel** invada ou cubra o texto) e que o acesso ao painel seja apresentado em um **card/banner dedicado e autoexplicativo** abaixo dos filtros, deixando claro que ali é possível **enviar comunicados, gerenciar grupos e acompanhar leituras**.

**Teste Independente**: Renderizar `CaixaMensagensPage` com `podeEnviarMensagensProvider` retornando `true` e verificar:
1. O `HeroHeaderPublico` contém apenas o botão de voltar, o título centralizado `"Mensagens e Avisos"` e o ícone circular de atualizar — sem nenhum botão largo sobrepondo o título.
2. Abaixo da barra segmentada (`Todas`, `Não lidas`, `Arquivadas`), é exibido um card institucional clicável com o título `"Painel de Envio de Avisos"`, subtítulo explicativo `"Enviar comunicados, gerenciar grupos e acompanhar leituras"` e indicador visual de navegação (`Icons.chevron_right_rounded`).
3. Ao tocar no card, navega para `/mensagens/painel`.
4. Quando `podeEnviarMensagensProvider` retorna `false`, o card administrativo **não** é exibido.

### História de Usuário 2 - Consistência no Cabeçalho de Grupos Personalizados (Priority: P2)

Como administrador, quero que `GruposPersonalizadosPage` também mantenha o `HeroHeaderPublico` limpo (sem botão largo `Novo Grupo` competindo com o título `"Grupos Personalizados"`), exibindo o botão `"Novo Grupo"` em área dedicada abaixo do cabeçalho.

**Teste Independente**: Renderizar `GruposPersonalizadosPage` e verificar a presença do botão `"Novo Grupo"` abaixo do `HeroHeaderPublico`, mantendo o título sem sobreposição.

## Requisitos *(obrigatório)*

- **FR-001**: Remover o botão `Painel` do `rightWidget` de `HeroHeaderPublico` em `CaixaMensagensPage`, mantendo apenas `MensagensHeaderIconButton(icon: Icons.refresh_rounded)` no `rightWidget`.
- **FR-002**: Adicionar um card institucional dedicado (`_PainelAdminBanner`) logo abaixo da `MensagensSegmentedPillBar` em `CaixaMensagensPage` quando `podeEnviar == true`, respeitando `MainLayout.horizontalPadding(context)` e a paleta `MensagensColors`.
- **FR-003**: Remover o botão largo `Novo Grupo` do `rightWidget` de `HeroHeaderPublico` em `GruposPersonalizadosPage`, movendo-o para uma barra de ação dedicada abaixo do cabeçalho.
- **FR-004**: Atualizar `test/features/mensagens/caixa_mensagens_test.dart` cobrindo a exibição do banner administrativo para usuários autorizados e sua ocultação para destinatários comuns.
