# Q9 — Evidência de Compatibilidade de Dependências

**Fase:** Q9 — Compatibilidade  
**Data:** 01/10/2026  
**Status:** Auditado Estaticamente / Sem Atualização de Pacotes  

---

## 1. Princípio Metodológico

Em estrita consonância com as regras da fase Q9:
> *“Verificar as dependências Flutter usadas pelo projeto e identificar somente problemas concretos relacionados a compatibilidade... Não atualizar dependências nesta fase.”*

Nenhum arquivo `pubspec.yaml` ou `pubspec.lock` foi alterado para forçar atualizações de pacotes.

Distingue-se fundamentalmente o **Suporte do Pacote** (a disponibilidade de código multiplataforma fornecido pelo plugin no ecossistema Flutter) da **Configuração no Aplicativo** (a presença efetiva de credenciais, manifests e arquivos de projeto necessários para uso funcional do recurso).

---

## 2. Auditoria Detalhada dos 22 Pacotes de Produção

| Pacote | Versão | Suporte Pacote Android | Suporte Pacote iOS | Configuração no App MPPB | Avaliação de Compatibilidade |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `cupertino_icons` | `^1.0.8` | Sim | Sim | Configurado | **Compatível**. Recursos visuais Cupertino (Dart puro). |
| `flutter_riverpod` | `^3.3.2` | Sim | Sim | Configurado | **Compatível**. Gerência de estado sem dependências nativas. |
| `go_router` | `^17.3.0` | Sim | Sim | Configurado | **Compatível**. Roteador declarativo multiplataforma. |
| `dio` | `^5.9.2` | Sim | Sim | Configurado | **Compatível**. Cliente HTTP com interceptors e timeouts. |
| `flutter_secure_storage` | `^10.3.1` | Sim | Sim | Configurado | **Compatível**. Android KeyStore e iOS Keychain funcionais. |
| `qr_flutter` | `^4.1.0` | Sim | Sim | Configurado | **Compatível**. Desenho em Canvas de QR Code. |
| `url_launcher` | `^6.3.0` | Sim | Sim | Parcial (iOS sem queries) | **Compatível em Android**; Requer adição de `LSApplicationQueriesSchemes` em iOS (ver `GAP-Q9-IOS-01`). |
| `intl` | `^0.20.2` | Sim | Sim | Configurado | **Compatível**. Internacionalização pt_BR. |
| `google_fonts` | `^6.2.1` | Sim | Sim | Configurado | **Compatível**. Fontes dinâmicas com cache local. |
| `flutter_svg` | `^2.0.10` | Sim | Sim | Configurado | **Compatível**. Renderizador SVG. |
| `font_awesome_flutter` | `^11.0.0` | Sim | Sim | Configurado | **Compatível**. Ícones tipográficos vetoriais. |
| `local_auth` | `^3.0.2` | Sim | Sim | Configurado | **Compatível**. `local_auth_android` e `local_auth_darwin` presentes. |
| `connectivity_plus` | `^7.2.0` | Sim | Sim | Configurado | **Compatível**. Monitoramento de rede nativo. |
| `cached_network_image` | `^3.4.1` | Sim | Sim | Configurado | **Compatível**. Gerenciamento de cache de imagens remotas. |
| `just_the_tooltip` | `^0.0.12` | Sim | Sim | Configurado | **Compatível**. Overlay de tooltip para acessibilidade. |
| `pdf` | `^3.11.1` | Sim | Sim | Configurado | **Compatível**. Construção de documentos PDF em memória. |
| `printing` | `^5.13.4` | Sim | Sim | Configurado | **Compatível**. Integração com spooler nativo de impressão. |
| `html` | `^0.15.4` | Sim | Sim | Configurado | **Compatível**. Sanitização de tags HTML em notícias. |
| `file_picker` | `^8.1.4` | Sim | Sim | Configurado | **Compatível**. Seletor nativo de documentos. |
| `share_plus` | `^12.0.2` | Sim | Sim | Configurado | **Compatível**. Compartilhamento nativo (com aviso KGP no build Android). |
| `firebase_core` | `^4.14.0` | Sim | Sim | Parcial (iOS sem plist) | **Compatível em Android**; iOS sem configuração (`UnsupportedError`). Emite aviso KGP. |
| `firebase_messaging` | `^16.6.0` | Sim | Sim | Parcial (desativado no iOS) | **Compatível em Android**; Restrito por design ao Android no app MPPB. |

---

## 3. Risco de Depreciação Futura: Kotlin Gradle Plugin (KGP)

Durante a execução da compilação do APK (`flutter build apk --debug --flavor homolog`), a ferramenta de build emitiu o seguinte alerta oficial do ecossistema Flutter:

```text
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): firebase_core, share_plus
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.

Please check the changelogs of these plugins and upgrade to a version that supports Built-in Kotlin.
```

- **Impacto Atual:** Nenhum impacto impeditivo na versão atual (Flutter 3.44.3). O build concluiu com sucesso em 43.8s.
- **Risco Técnico:** Versões futuras maiores do Flutter descontinuarão a injeção do KGP em favor do Built-in Kotlin do Flutter Gradle Plugin.
- **Recomendação:** Avaliar atualização para versões compatíveis com Built-in Kotlin em ciclo próprio de atualização de dependências pós-ciclo de qualidade.
- **Classificação:** Mapeado como **`PARCIAL`** no cenário `Q9-DEP-02`.
