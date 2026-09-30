# Evidência Q7 — Android Físico: Estado Offline Controlado

Data: 2026-09-30  
Dispositivo: Samsung Galaxy A52 (`SM-A525M`)  
Modo de Desconexão: `E2E MANUAL CONTROLADO` (Desativação de Wi-Fi e Dados Móveis)

---

## 1. Simulação da Desconexão

- Wi-Fi desativado no painel de configurações rápidas do Android.
- Dados móveis desativados.
- Confirmação de ausência total de rota IP externa no aparelho.

## 2. Comportamento Observado na UI

1. **Home Pública**:
   - Permaneceu estável e utilizável sem encerramento repentino ou crash.
   - Navegação interna e cards de serviços locais continuaram responsivos.
2. **Notícias sob Refresh**:
   - Acionado pull-to-refresh na listagem de notícias.
   - Indicador de progresso girou normalmente e encerrou sem travar.
   - **Preservação de Dados Prévios**: Os cards de notícias já carregados anteriormente NÃO foram apagados da tela.
   - **Feedback de Erro Controlado**: Apresentou feedback amigável de conexão indisponível ("Erro ao carregar notícias: SocketException" / falha de rede).
3. **Estabilidade Global**:
   - Zero crashes.
   - Zero exceptions não tratadas no runtime.
   - Botões e abas não ficaram desabilitados em loading permanente.
