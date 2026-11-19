# Plano de Implementação: Reposicionamento do Botão Painel (`003-ajuste-botao-painel-mensagens`)

**Branch**: `feat/ajuste-painel-mensagens` | **Data**: 2026-11-19 | **Spec**: [spec.md](file:///home/rafaelhugo/projetosMPPB/app_mppb_flutter/specs/003-ajuste-botao-painel-mensagens/spec.md)

## Arquivos Afetados

- `lib/features/mensagens/ui/pages/caixa_mensagens_page.dart`:
  - `HeroHeaderPublico.rightWidget` passa a conter somente `MensagensHeaderIconButton(icon: Icons.refresh_rounded)`.
  - Abaixo de `MensagensSegmentedPillBar`, quando `podeEnviar == true`, renderiza `_PainelAdminBanner` (card branco `MensagensColors.surface`, borda `MensagensColors.border`, ícone em destaque `MensagensColors.red`, título `"Painel de Envio de Avisos"`, subtítulo `"Enviar comunicados, gerenciar grupos e acompanhar leituras"`, seta `Icons.chevron_right_rounded`, `onTap: () => context.push('/mensagens/painel')`).
- `lib/features/mensagens/ui/pages/grupos_personalizados_page.dart`:
  - Move o botão `Novo Grupo` para baixo do `HeroHeaderPublico`, evitando sobreposição do título `"Grupos Personalizados"`.
- `test/features/mensagens/caixa_mensagens_test.dart`:
  - Adiciona teste validando a exibição de `"Painel de Envio de Avisos"` quando `podeEnviarMensagensProvider` é `true` e sua ausência quando `false`.
