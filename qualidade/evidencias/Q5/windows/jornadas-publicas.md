# Execução das Jornadas Públicas E2E — Q5 (Windows + Android Físico)

## 1. Identificação do Teste
- **Arquivo**: `integration_test/q5_public_e2e_test.dart`
- **Dispositivo**: Samsung Galaxy A52 (`RX8RC09H70X`)
- **Comando de Execução**:
  ```bash
  flutter test integration_test/q5_public_e2e_test.dart -d RX8RC09H70X --flavor homolog --dart-define=API_URL=https://aplicativo-mppb-homolog.mppb.mp.br --dart-define=Q5_E2E_DISABLE_FCM=true
  ```

## 2. Bateria de Execuções e Diagnóstico de Estabilidade
| Execução | Status do Runner | Falha Observada | Estabilidade do ADB | Estado do App |
| :--- | :--- | :--- | :--- | :--- |
| **Execução 1** | **FAIL** (Asserção) | `TestFailure: Nenhuma condicao observavel encontrada em 0:00:25.000000` | `device` (100% online) | Sem crash / Sem ANR |
| **Execução 2** | **FAIL** (Asserção) | `TestFailure: Nenhuma condicao observavel encontrada em 0:00:25.000000` | `device` (100% online) | Sem crash / Sem ANR |
| **Execução 3** | **FAIL** (Asserção) | `TestFailure: Nenhuma condicao observavel encontrada em 0:00:25.000000` | `device` (100% online) | Sem crash / Sem ANR |

## 3. Investigação Detalhada da Causa Raiz

### 3.1 Comportamento da Aplicação e Conectividade
- O aplicativo iniciou normalmente na Home do MPPB.
- A navegação até **Contatos e Atendimento** foi executada com sucesso.
- O retorno à Home foi executado com sucesso.
- A navegação até **Notícias** foi executada com sucesso.
- A requisição para `https://aplicativo-mppb-homolog.mppb.mp.br/api/public/noticias` respondeu com `HTTP 200` e payload de notícias reais.
- Os cards foram renderizados na tela.

### 3.2 Causa da Quebra da Asserção no Teste Inicial
- No harness inicial, o teste aguardava a string `'min de leitura'` para confirmar que as notícias haviam sido carregadas.
- No entanto, a implementação do card de listagem em `lib/features/noticias/ui/noticias_page.dart` exibe a duração abreviada como `${_readingTime(noticia)}m` e o botão `Abrir`.
- A string `'min de leitura'` só é exibida na folha modal de detalhes (`NewsDetailSheet`) após abrir o detalhe.
- Como o matcher inicial não encontrava a string no card da lista, ocorria timeout.

### 3.3 Conclusão Técnica e Comparativo com Linux
- No **Linux**, o teste era interrompido pelo crash abrupto do emulador QEMU (`exit code 139`) e perda de comunicação ADB (`error: device offline`).
- No **Windows com Dispositivo Físico USB**, o ADB manteve estabilidade ininterrupta (3/3), o app nunca sofreu crash (zero erros no AndroidRuntime), isolando que o teste vindo do Linux possuía uma asserção inconsistente com o card da listagem.

## 4. Q5-R02 — Correção da Asserção do Harness e Fechamento 3/3 Verde

### 4.1 Correção Realizada
1. **Identificador Estrutural**: Adicionada `key: const Key('lista-noticias')` no `GridView.builder` de `lib/features/noticias/ui/noticias_page.dart` estritamente para testabilidade E2E.
2. **Correção do Harness**: No teste `integration_test/q5_public_e2e_test.dart`, substituída a busca pela asserção estrita positiva da listagem de Notícias (`find.byKey(const Key('lista-noticias'))`) e botões dos cards (`find.text('Abrir')`). Estados de erro (`Tentar novamente`, `Não foi possível`) não satisfazem a asserção.
3. **Estabilização de Transições**: Substituído o `pumpAndSettle` nas operações de navegação por pumps explícitos temporizados, evitando retenção do runner por animações contínuas de carrossel.

### 4.2 Bateria Oficial Gate 3/3 (Android 14 Físico — Samsung Galaxy A52)
| Execução | Status do Runner | Tempo | Estado ADB | Estado do App |
| :--- | :--- | :--- | :--- | :--- |
| **Execução 1** | **PASS** (`+1: All tests passed!`) | ~13s | `device` (100% online) | Sem crash / Sem ANR |
| **Execução 2** | **PASS** (`+1: All tests passed!`) | ~12s | `device` (100% online) | Sem crash / Sem ANR |
| **Execução 3** | **PASS** (`+1: All tests passed!`) | ~13s | `device` (100% online) | Sem crash / Sem ANR |

### 4.3 Verificação de Logs Nativos
- Ausência total no app de: `FATAL EXCEPTION`, `AndroidRuntime`, `SIGSEGV`, `PlatformException` ou crash Flutter.

### 4.4 Veredito do E2E Público
**JORNADA PÚBLICA PRINCIPAL E2E VALIDADA EM ANDROID FÍSICO — 3/3 PASS**.
O bloqueio Linux/AVD/ADB foi definitivamente superado no hardware físico real com a asserção estrita positiva da listagem de Notícias.
