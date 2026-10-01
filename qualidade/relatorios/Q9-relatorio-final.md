# Relatório Final — Q9: Compatibilidade do Aplicativo MPPB

**Fase:** Q9 — Compatibilidade  
**Data de Conclusão:** 01/10/2026  
**Status da Fase:** Concluída e Congelada  
**Branch:** `qualidade/q9-compatibilidade`  
**Próxima Fase:** **Q10 NÃO INICIADA**  

---

## 1. Origem Canônica e Escopo

A fase **Q9 — Compatibilidade** foi executada com base no mapeamento originário da fase Q1:
- **Origem Canônica:** `qualidade/relatorios/Q1-relatorio-final.md` (Linha 67, item Q9):
  > *| Q9 | Matriz Android/iOS/web, resolucoes, orientacao, PDF/compartilhamento nativo. |*
- **Rastreabilidade Funcional:** `RF-001`, `RF-009`, `RF-012` e `RF-019` em `qualidade/matrizes/Q1-rastreabilidade-funcional.md`.
- **Escopo Canônico Auditado:**
  1. Configuração e integridade Android (SDKs, arquiteturas, permissões, queries, segurança, empacotamento e runtime);
  2. Auditoria estática iOS (deployment target, Info.plist, capacidades, biometria, armazenamento seguro, Firebase e gaps);
  3. Plataforma Web (análise de escopo do produto móvel);
  4. Layout responsivo (breakpoints `MppbResponsive`, viewports automatizados, safe areas, rotação de tela e temas);
  5. Recursos nativos (abertura/manipulação de PDF e compartilhamento nativo de links/textos);
  6. Auditoria de compatibilidade das 22 dependências do projeto;
  7. Neutralidade de plataforma dos contratos REST com o backend.

---

## 2. Ambiente de Execução e Ferramental

| Componente | Especificação Local |
| :--- | :--- |
| **Sistema Operacional do Host** | Windows 11 Pro 64-bit (Build 26100) |
| **Flutter SDK** | 3.44.3 • channel [user-branch] (Framework revision `e1fd963c6f`, Engine `97bcd50733ba`) |
| **Dart SDK** | 3.12.2 |
| **Java Runtime** | OpenJDK 17 (`JavaVersion.VERSION_17`) / JBR Android Studio |
| **Android Build Tools / SDK** | `compileSdk = 36`, `targetSdk = 36`, `minSdk = 24` |
| **Gradle Wrapper** | 9.1.0-all |
| **Ambiente Apple / macOS** | **Inexistente no host local** (sem Xcode, CocoaPods ou simuladores iOS) |

---

## 3. Dispositivos e Cobertura de Runtime

| Plataforma | Alvo / Especificação | Status de Runtime na Q9 | Justificativa Objetiva |
| :--- | :--- | :--- | :--- |
| **Android (Físico)** | Samsung Galaxy A52 (`SM-A525M`), Android 14 / API 34, `arm64-v8a` (`RX8RC09H70X`) | **BLOQUEADO POR LIMITAÇÃO DE AMBIENTE (NOVA EXECUÇÃO)** | **EVIDÊNCIA HERDADA Q8-R01**: Android 14 / arm64 físico validado em modo PROFILE (Galaxy A52).<br>**Q9**: Nova execução física bloqueada por indisponibilidade de sinal de dados USB/ADB no host Windows (`Present: False` no subsistema PnP). Não se extrapola para API 24–36. |
| **Android (Emulador)** | AVD local | **BLOQUEADO POR LIMITAÇÃO DE AMBIENTE** | Não há imagens de sistema Android (`system-images`) instaladas no Android SDK local. |
| **iOS (Físico / Simulador)** | iPhone / iPad / iOS Simulator | **NÃO AFERIDO POR LIMITAÇÃO DE AMBIENTE** | Ferramental de runtime iOS requer macOS e Xcode, indisponíveis no ambiente Windows 11. |

---

## 4. Versões Efetivamente Cobertas

- **Android:**
  - `minSdk = 24` (Piso de instalação configurado em Android 7.0 / API 24).
  - `compileSdk = 36` / `targetSdk = 36` (Android 16): **Conforme com o requisito atual da Google Play** para novos aplicativos e atualizações em 01/10/2026 (`targetSdk >= 36`).
- **iOS:**
  - `IPHONEOS_DEPLOYMENT_TARGET = 13.0`: Deployment target configurado em iOS 13.0. A compatibilidade real depende das versões de iOS suportadas por cada modelo; runtime iOS não foi aferido na Q9.

---

## 5. Resumo da Matriz de Compatibilidade (22 Cenários)

```text
======================================================================
  RESUMO DA MATRIZ Q9 — COMPATIBILIDADE (CONTAGEM EXATA)
======================================================================
  [PASSOU]     13 cenários ( 59,1%)
  [PARCIAL]     6 cenários ( 27,3%)
  [BLOQUEADO]   2 cenários (  9,1%)
  [N/A]         1 cenário  (  4,5%)
  [FALHOU]      0 cenários (  0,0%)
======================================================================
  TOTAL        22 cenários (100,0%)
======================================================================
```

### Detalhamento por Domínio:
1. **Android (Estático & Build):** `PASSOU` em SDKs (`Q9-AND-01`), arquiteturas (`Q9-AND-02`), permissões/queries (`Q9-AND-03`), build APK homolog debug (`Q9-AND-04`), redimensionamento de teclado (`Q9-AND-06`) e bloqueio de cleartext HTTP (`Q9-AND-07`).
2. **Android (Runtime):** `BLOQUEADO` para nova execução na Q9 (`Q9-AND-05`), com registro da evidência dinâmica herdada da Q8-R01 no Galaxy A52 (Android 14 / arm64).
3. **iOS (Estático):** `PASSOU` em deployment target (`Q9-IOS-01`) e plugins de segurança/biometria (`Q9-IOS-05`). `PARCIAL` em permissões/queries schemes (`Q9-IOS-02`) e Firebase/FCM (`Q9-IOS-03`).
4. **iOS (Runtime):** `BLOQUEADO / NÃO AFERIDO` por ausência de ambiente macOS/Xcode (`Q9-IOS-04`).
5. **Web:** `N/A` (`Q9-WEB-01`) por não ser plataforma suportada pelo produto mobile.
6. **Layout Responsivo:** `PASSOU` em breakpoints (`Q9-LAY-01`), orientação retrato/paisagem (`Q9-LAY-02`) e ausência de overflows no conjunto de viewports automatizados (`Q9-LAY-03`). `PARCIAL` em suporte a temas (`Q9-LAY-04` — ausência de dark theme).
7. **Recursos Nativos:** `PARCIAL` em manipulação de PDF (`Q9-NAT-01`) e compartilhamento nativo (`Q9-NAT-02`) por possuírem arquitetura e configuração validadas estaticamente, mas sem aferição de runtime nativo em ambas as plataformas.
8. **Dependências:** `PASSOU` em suporte dos 22 pacotes (`Q9-DEP-01`), distinguindo suporte de ecossistema de configuração do app. `PARCIAL` pelo risco de depreciação KGP em `firebase_core` e `share_plus` (`Q9-DEP-02`).
9. **Backend:** `PASSOU` em neutralidade e estabilidade de contratos REST multiplataforma (`Q9-BCK-01`).

---

## 6. Riscos e Incompatibilidades Encontradas

### RISCO-Q9-001 (GAP-Q9-IOS-01): Ausência de `LSApplicationQueriesSchemes` no iOS
- **Severidade:** Média.
- **Descrição:** O arquivo `ios/Runner/Info.plist` não declara os schemes externos (`https`, `http`, `mailto`, `tel`). A documentação oficial do `url_launcher` exige essa declaração para consultas com `canLaunchUrl()`. No iOS 9+, a verificação falhará silenciosamente, impactando abertura de notícias externas, diário oficial e contatos.
- **Recomendação:** Adicionar a tag `<key>LSApplicationQueriesSchemes</key>` com os esquemas necessários no `Info.plist` em ciclo de correção prévio ao lançamento na App Store.

### RISCO-Q9-002 (GAP-Q9-IOS-02): Firebase Não Configurado para a Plataforma iOS
- **Severidade:** Média.
- **Descrição:** O arquivo `GoogleService-Info.plist` não existe e `lib/firebase_options.dart` lança `UnsupportedError` para iOS. O aplicativo desabilita o Firebase em tempo de execução no iOS por desenho (`PushNotificationService.isSupportedPlatform == false`), evitando falha na inicialização, mas impedindo o recebimento de notificações push no iOS.
- **Recomendação:** Gerar credenciais do projeto Firebase iOS e registrar o `GoogleService-Info.plist` quando o suporte iOS for promovido para runtime.

### RISCO-Q9-003: Inexistência de Suporte a Tema Escuro (Dark Mode)
- **Severidade:** Baixa.
- **Descrição:** O arquivo `lib/main.dart` define exclusivamente o tema claro (`ThemeData`). Não há declaração de `darkTheme` nem tratamento de `themeMode`. O aplicativo permanece renderizado em fundo claro mesmo quando o usuário ativa o Dark Mode no sistema operacional.

### RISCO-Q9-004: Alerta de Depreciação Futura do Kotlin Gradle Plugin (KGP)
- **Severidade:** Baixa (Débito Técnico).
- **Descrição:** A compilação do APK emitiu aviso de que `firebase_core` e `share_plus` aplicam diretamente o KGP. Recomenda-se avaliar atualização para versão compatível com Built-in Kotlin em ciclo próprio de atualização de dependências.

---

## 7. Portões de Regressão

| Portão | Comando | Tempo | Resultado |
| :--- | :--- | :--- | :--- |
| **Análise Estática** | `flutter analyze` | 117,7s | **0 issues (VERDE)** |
| **Testes Automatizados** | `flutter test` | 13,0s | **187/187 PASS (VERDE)** |
| **Compilação de APK** | `flutter build apk --debug --flavor homolog -t lib/main.dart` | 43,8s | **Sucesso (`app-homolog-debug.apk`, 220 MB) (VERDE)** |

---

## 8. Conclusão Metodologicamente Precisa

Compatibilidade estática, de configuração e empacotamento Android validada no escopo testado; Android 14 possui evidência dinâmica herdada da Q8-R01, porém a reexecução Q9 ficou bloqueada. iOS foi validado estaticamente, com gaps documentados e runtime não aferido.

---

**Q9 CONCLUÍDA E CONGELADA.**  
**Q10 NÃO INICIADA.**
