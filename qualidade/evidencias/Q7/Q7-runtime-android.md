# Evidência Q7 — Runtime Android Físico

Data: 2026-09-30  
Dispositivo: Samsung Galaxy A52 (`SM-A525M`)  
Build Alvo: Homologação Debug APK (`app-homolog-debug.apk`)  
Ambiente: Android 14 / One UI 6.1 (API 34) — ABI: `arm64-v8a`  
Jornada: Home pública → Notícias online → Desconexão de rede → Tentativa de atualização offline → Reconexão de rede → Retry com sucesso

---

## 1. Classificação do Endpoint e Ambiente de Execução

> [!WARNING]
> **CENÁRIO FÍSICO Q7 EXECUTADO CONTRA ENDPOINT PÚBLICO DE PRODUÇÃO POR CONFIGURAÇÃO DO BUILD**
> - **Flavor Android**: `homolog` (`applicationIdSuffix = ".homolog"`, label "MPPB+ Homolog").
> - **Endpoint HTTP Efetivo**: `https://aplicativo-api.mppb.mp.br` (resolvido a partir do `defaultValue` de `API_URL` no código Dart por ausência de `--dart-define=API_URL=...` na linha de comando de execução).
> - **Escopo da Jornada**: Estritamente leitura pública e probe de conectividade (Home, Notícias públicas e Health Check). Nenhuma operação mutável, autenticada ou restrita foi enviada.
> - **Integridade e Validade**: A evidência comprova de forma autêntica o comportamento de resiliência de rede do app diante da API pública real do MPPB, sem mascaramento de ambiente.

## 2. Resumo da Execução

- **Método de Desconexão**: `E2E MANUAL CONTROLADO` (Desativação de Wi-Fi e Dados Móveis no painel do Android).
- **Comportamento em Modo Offline**:
  - A Home pública permaneceu completamente estável sem qualquer crash.
  - Ao realizar pull-to-refresh na tela de Notícias, o loading encerrou graciosamente.
  - As notícias previamente carregadas NÃO foram destruídas da tela (preservação de dados locais).
  - Foi apresentado feedback claro ao usuário sobre a indisponibilidade momentânea da rede.
- **Comportamento na Reconexão**:
  - Ao religar a conectividade Wi-Fi, o pull-to-refresh recarregou os dados com sucesso.
  - Não foi necessário reiniciar o aplicativo para restaurar o pleno funcionamento.

## 2. Auditoria de Estabilidade (Logcat)

Análise executada sobre o buffer do Logcat durante toda a bateria de testes de rede:
- `FATAL EXCEPTION`: 0 ocorrências
- `AndroidRuntime`: 0 crashes
- `SIGSEGV`: 0 ocorrências
- `PlatformException`: 0 ocorrências
- Exceções não tratadas de rede / Dio: 0 ocorrências
- Comportamento de ciclo de vida e conectividade: CONFORME.
