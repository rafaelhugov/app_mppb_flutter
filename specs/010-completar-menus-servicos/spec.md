# Spec 010 — Completar Menus Públicos e Logados no ServicesBottomSheet

## Contexto
Ao abrir o modal **Serviços** (`+` na barra inferior) em `ServicesBottomSheet`, faltavam atalhos para módulos já existentes no roteador (`app_router.dart`):
- **Modo Público**: faltavam `Notícias` (`/noticias`), `Diário` (`/diario_oficial`), `Processos` (`/processos`) e `Contatos` (`/contatos`).
- **Modo Logado**: faltavam `Avisos` (`/mensagens`) e `Contatos` (`/contatos`).

## Requisitos Funcionais
- **RF-01 (Público)**: Exibir todos os 8 atalhos públicos: `Notícias`, `TV MPPB`, `Diário`, `Certidão`, `Processos`, `Ouvidoria`, `Contatos` e `Área Restrita`.
- **RF-02 (Logado)**: Exibir todos os 11 atalhos de serviços logados (além da barra inferior `Início`, `Contr.`, `Cart.`, `Afast.`): `Notícias`, `TV MPPB`, `Diário`, `Certidão`, `Pagamentos`, `Designações`, `Processos`, `Avisos`, `Contatos`, `Perfil` e `Ouvidoria`.
- **RF-03**: Manter o layout em grade de 4 colunas (`Wrap`) com largura calculada responsivamente e sem duplicação de código.

