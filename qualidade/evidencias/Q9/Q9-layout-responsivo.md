# Q9 — Evidência de Layout Responsivo, Resoluções e Temas

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Validado Automatizado / Ressalva de Dark Mode  

---

## 1. Sistema Responsivo do Aplicativo (`MppbResponsive`)

O design responsivo do aplicativo MPPB está centralizado em `lib/core/ui/responsive_layout.dart` e na classe utilitária `MppbResponsive`, que categoriza a largura da janela de exibição em quatro classes:

```dart
enum MppbWindowClass {
  compact,   // < 600 dp (smartphones)
  medium,    // 600 dp - 839 dp (tablets pequenos e dobráveis)
  expanded,  // 840 dp - 1199 dp (tablets em modo paisagem)
  large;     // >= 1200 dp (telas desktop e grandes tablets)
}
```

### 1.1 Métricas Dinâmicas por Breakpoint

| Window Class | Largura (dp) | Padding Horizontal | Max Width Conteúdo | Colunas Grid Geral | Colunas Cards/Serviços |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`compact`** | `< 600` | 20 dp | 760 dp | 2 | 1 |
| **`medium` (retrato)** | `600 - 839` | 28 dp | 760 dp | 2 | 1 |
| **`medium` (paisagem)**| `600 - 839` | 28 dp | 900 dp | 3 | 2 |
| **`expanded`** | `840 - 1199` | 40 dp | 1080 dp | 3 | 2 |
| **`large`** | `>= 1200` | 56 dp | 1240 dp | 4 | 3 |

---

## 2. Testes de Unidade e Widget do Layout Responsivo

Os comportamentos de redimensionamento e transição de breakpoints foram validados através do arquivo de teste dedicado `test/core/ui/responsive_layout_test.dart`:

```dart
group('MppbResponsive', () {
  test('classifica larguras por breakpoint');
  test('mantem layout compacto para celular (390x844)');
  test('amplia grid em tablet paisagem (1024x768)');
  test('mantem tablet medio em layout de leitura no retrato (768x1024)');
  test('usa mais colunas em tablet grande (1366x912)');
});
```
- **Resultado:** **PASSOU NO CONJUNTO DE VIEWPORTS AUTOMATIZADOS**.
- **Delimitação Metodológica:** A aprovação nos testes comprova a ausência de exceções de renderização (`RenderFlex overflow`) e conformidade métrica estritamente nos cenários e resoluções cobertos pela suíte automatizada. Não se declara ausência global irrestrita de overflow em todas as combinações de densidades e resoluções físicas de tela.

---

## 3. Telas Auditadas com Adaptação Responsiva

O uso do `MppbResponsive` foi verificado nas principais telas públicas e autenticadas do sistema:
1. **Dashboard Público (`public_dashboard_page.dart`):** Utiliza padding adaptativo e controle de colunas para carrossel de notícias e botões de atalho.
2. **Dashboard Funcional (`dashboard_page.dart`):** Ajusta viewport fraction do carrossel (`_newsViewportFractionFor`) e padding horizontal.
3. **Notícias (`noticias_page.dart` e `news_carousel.dart`):** Redimensiona cards de notícias e listas conforme a classe de tela.
4. **Diário Oficial (`diario_oficial_page.dart`):** Centraliza formulários de busca através de `MppbResponsiveCenter`.
5. **Pagamentos e Contracheque (`pagamentos_page.dart`, `contra_cheque_page.dart`):** Adapta visualização de tabelas e listas de lançamentos com limitação de largura máxima para leitura confortável.
6. **Contatos Institucionais (`contatos_page.dart`):** Utiliza grids responsivos para cartões de contato.
7. **Central de Notificações (`notification_center_sheet.dart`):** Controla a largura máxima da folha modal inferior para evitar estiramento em tablets.

---

## 4. Áreas Seguras (SafeArea) e Status Bar

- Todas as páginas base implementam `Scaffold` com `SafeArea` ativo ou utilizam o `MppbAppBar` customizado (`lib/core/ui/mppb_app_bar.dart`), que encapsula o recuo da status bar (`MediaQuery.paddingOf(context).top`).
- A navegação inferior (`services_bottom_sheet.dart`) implementa recuo automático da barra de navegação gestual do Android/iOS (`bottom: MediaQuery.paddingOf(context).bottom`).

---

## 5. Auditoria de Temas (Modo Claro vs Modo Escuro)

### 5.1 Configuração Existente em `lib/main.dart`
```dart
MaterialApp.router(
  title: 'MPPB App',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8F2A1D),
    ), // Vermelho escuro/Vinho do MPPB
    useMaterial3: true,
  ),
  // darkTheme: NÃO DEFINIDO
  // themeMode: NÃO DEFINIDO
);
```

### 5.2 Constatação de Compatibilidade
- O aplicativo adota **estritamente Tema Claro** baseado no design institucional do Ministério Público da Paraíba.
- **Ausência de Tema Escuro:** Não há configuração de `darkTheme` nem suporte a alternância dinâmica de `ThemeMode.dark`. Quando o dispositivo do usuário está com o tema escuro ativado no sistema operacional, o Flutter continua renderizando os componentes em fundo claro.
- **Classificação:** Mapeado como **`PARCIAL`** no cenário `Q9-LAY-04` da matriz de compatibilidade.
