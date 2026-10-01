# Evidência Q12 — Armazenamento, Cache e Recuperação de Corrupção

**Data de Execução:** 01/10/2026  
**Fase:** Q12 — Resiliência, Observabilidade e Recuperação  
**Reconciliação:** Q12-R01 — Reconciliação Metodológica e Validação Definitiva  
**Ambiente:** Flutter (App Mobile)  
**Arquivo de Teste:** `test/features/resiliencia/q12_resiliencia_test.dart`

---

## 1. Auditoria da Desserialização de Cache Seguro

Tanto `PerfilNotifier` quanto `CarteiraNotifier` utilizam persistência em cache no `FlutterSecureStorage` sob as chaves:
- `perfil_cache_data` e `perfil_cache_username`
- `carteira_cache_data` e `carteira_cache_username`

Em cenários onde o JSON armazenado sofre corrupção por escrita incompleta ou falha de storage, o método `jsonDecode()` lança `FormatException`.

### 1.1 PerfilNotifier (`lib/features/perfil/providers/perfil_provider.dart`)
```dart
try {
  if (cachedStr != null && cachedStr.isNotEmpty) {
    state = state.copyWith(
      data: PerfilUsuario.fromJson(jsonDecode(cachedStr)),
      isLoading: false,
      isRefreshing: false,
      errorMessage: fallbackMessage,
    );
    return;
  }
} catch (_) {
  // Falha ao ler cache: limpa estado
}
if (!ref.mounted) return;
state = state.copyWith(
  isLoading: false,
  isRefreshing: false,
  errorMessage: fallbackMessage,
);
```

### 1.2 CarteiraNotifier (`lib/features/carteira/providers/carteira_provider.dart`)
```dart
try {
  if (cachedStr != null && cachedStr.isNotEmpty) {
    state = CarteiraState(
      isLoading: false,
      data: UsuarioCarteira.fromJson(jsonDecode(cachedStr)),
      isOffline: true,
      errorMessage: fallbackMessage,
    );
    return;
  }
} catch (_) {
  // Falha ao ler cache: limpa estado
}
if (!ref.mounted) return;
state = CarteiraState(
  isLoading: false,
  errorMessage: fallbackMessage,
);
```

---

## 2. Testes de Falha Controlada (`Q12-T06A` e `Q12-T06B`)

### 2.1 Q12-T06A: Perfil com JSON Inválido
- **Falha Injetada:** `perfil_cache_data = "CORRUPTED_JSON_DATA_{{{{"`
- **Comportamento Validado:**
  - O `FormatException` foi interceptado no bloco `catch (_)`.
  - O aplicativo não sofreu crash de isolate.
  - `state.isLoading` foi liberado para `false`.
  - Mensagem de erro amigável foi atribuída ao estado.
- **Status:** **PASSOU**

### 2.2 Q12-T06B: Carteira com String Inválida
- **Falha Injetada:** `carteira_cache_data = "<<<INVALID_CARTEIRA_JSON>>>"`
- **Comportamento Validado:**
  - O erro de parsing foi absorvido graciosamente.
  - `state.data` permaneceu `null`.
  - A interface permaneceu estável e utilizável.
- **Status:** **PASSOU**

---

## 3. Recuperação Pós-Crash Controlado (`Q12-T22`)

- **Calibração Metodológica (Q12-R01):**
  - O teste comprovou a recuperação da aplicação após término abrupto de processo (`am force-stop` e `am kill`) e a capacidade de absorver cache corrompido sem crash.
  - Não foi provocado crash fatal destrutivo na JVM/NDK do dispositivo físico e os valores funcionais específicos pré-existentes de sessão não foram aferidos antes/depois.
- **Classificação:** **PARCIAL**
- **Síntese:** Recuperação após término abrupto de processo validada; recuperação após crash fatal real e integridade de valores funcionais específicos não aferidas.
