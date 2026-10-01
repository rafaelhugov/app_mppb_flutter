# Q11 — Inventário de Acessibilidade

Data de Auditoria: 01/10/2026 (Reconciliado Q11-R01)  
Ambiente: Flutter 3.44.3 (Dart 3.12.2)  
Dispositivo Físico de Referência: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, API 34)

---

## 1. Mapeamento de Telas e Componentes

| ID | Tela/Componente | Interativo | Semantics | Leitor de tela | Escala | Touch target | Nível de Evidência |
|---|---|---|---|---|---|---|---|
| COMP-01 | MppbAppBar (Pública) | Sim | ExcludeSemantics no brasão; Tooltip 'Notificações', 'Início' | Anúncio contextualizado com contagem | Suporta 2.0x sem overflow | >= 48x48dp (Android) e >= 44x44pt (iOS) | TESTADO |
| COMP-02 | MppbAppBar (Autenticada) | Sim | ExcludeSemantics no brasão; Tooltip 'Sair da conta', 'Notificações' | Ações de logout e avisos anunciadas | Suporta 2.0x sem overflow | >= 48x48dp (Android) e >= 44x44pt (iOS) | TESTADO |
| COMP-03 | MainLayout (Dock / BottomNav) | Sim | Semantics customizado mapeando abreviações para nomes por extenso | Rótulos expandidos (Contracheque, Carteira Funcional, etc.) | Responsivo no dock | >= 48x48dp | TESTADO |
| COMP-04 | PublicDashboardPage (Home Pública) | Sim | Cards semânticos de serviços com nome e descrição concatenados; Marca d'água excluída | Rótulos semânticos em cards e headers | Suporta 2.0x portrait e landscape via Wrap | >= 48x48dp | TESTADO |
| COMP-05 | LoginPage | Sim | Labels persistentes em inputs; liveRegion no container de erro; tooltip mostrar/ocultar senha | Leitura sequencial estável e feedback assíncrono de erro | Suporta 2.0x portrait e landscape via ScrollView | >= 48x48dp (Android) e >= 44x44pt (iOS) | TESTADO |
| COMP-06 | NoticiasPage | Sim | Tooltips nos botões de paginação ('Página anterior', 'Próxima página') e fechar sheet | Controles de fluxo anunciados | Textos redimensionáveis sem corte | >= 48x48dp | TESTADO |
| COMP-07 | NewsDetailSheet / Modal Notícia | Sim | Tooltip no botão fechar; ExcludeSemantics em ornamentos | Botão fechar identificado | Rolagem com texto grande | >= 48x48dp | INSPECIONADO |
| COMP-08 | ContatosPage & Seções | Sim | Seções de atendimento com cabeçalhos flexíveis | Foco sequencial linear | Suporta 2.0x via Flexible | >= 48x48dp | INSPECIONADO |
| COMP-09 | DiarioOficialPage | Sim | Paginação com tooltips; Botão fechar PDF com tooltip | Ações de controle de documento anunciadas | Suporta 2.0x | >= 48x48dp | TESTADO |
| COMP-10 | ConsultaProcessosPage | Sim | Tooltip fechar modal, recarregar captcha; Wrap flexível de filtros; Label no spinner | Anúncio de busca e carregamento | Suporta 2.0x portrait e landscape | >= 48x48dp | TESTADO |
| COMP-11 | CarteiraPage (Funcional) | Sim | Semantics de virar frente/verso; Semantics descritivo no QR Code sem expor payload | Mecanismo de validação externa e alternância | Suporta 2.0x | >= 48x48dp | TESTADO |
| COMP-12 | ContraChequePage | Sim | Botão fechar visualizador com tooltip | Controles acessíveis | Suporta 2.0x | >= 48x48dp | TESTADO |
| COMP-13 | CertidaoExtrajudicialPage | Sim | Botão fechar com tooltip | Controles acessíveis | Suporta 2.0x | >= 48x48dp | INSPECIONADO |
| COMP-14 | Ouvidoria (StepAnexos) | Sim | Tooltip 'Remover anexo' no botão de exclusão | Remoção de anexo anunciada | Suporta 2.0x | >= 48x48dp | INSPECIONADO |
| COMP-15 | PerfilPage | Sim | Ações de logout e visualização de dados funcionais | Anúncio de dados e saída | Suporta 2.0x | >= 48x48dp | INSPECIONADO |
| COMP-16 | PagamentosPage | Sim | Listagem de exercícios e parcelas | Navegação linear por foco | Suporta 2.0x | >= 48x48dp | INSPECIONADO |
| COMP-17 | DesignacoesPage | Sim | Cards de atos com período e categoria | Texto sem corte | Suporta 2.0x | >= 48x48dp | INSPECIONADO |

---

## 2. Totais do Inventário
- **Total de Telas/Componentes Mapeados**: 17 componentes centrais.
- **Classificação por Nível de Evidência**:
  - `TESTADO` (coberto diretamente por teste widget automatizado / guideline na Q11): 10 componentes.
  - `INSPECIONADO` (verificado estruturalmente no código com padrões compartilhados validados): 7 componentes.
  - `NÃO AFERIDO`: 0 componentes no escopo da baseline móvel.
