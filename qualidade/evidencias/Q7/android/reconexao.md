# Evidência Q7 — Android Físico: Reconexão e Recuperação

Data: 2026-09-30  
Dispositivo: Samsung Galaxy A52 (`SM-A525M`)  
Procedimento: Restauração da Rede e Retry Manual

---

## 1. Restauração da Conectividade

- Wi-Fi reativado no dispositivo.
- Aguardada associação de rede e obtenção de lease DHCP / IP válido.
- Acesso à internet restabelecido.

## 2. Comportamento Observado na UI

1. **Retry Manual (Pull-to-Refresh)**:
   - Acionado novamente o gesto de atualização na tela de Notícias.
   - Estado de erro anterior foi limpo imediatamente.
   - Indicador de progresso iniciou e concluiu com sucesso.
   - Lista de notícias atualizada com o feed mais recente do servidor de homologação.
2. **Conclusão**:
   - Total recuperação transparente sem necessidade de fechar ou reiniciar o aplicativo.
   - Estado Riverpod restabelecido com dados atualizados.
