# Evidência Q7 — Android Físico: Estado Online

Data: 2026-09-30  
Dispositivo: Samsung Galaxy A52 (`SM-A525M`)  
Sistema Operacional: Android 14 / One UI 6.1 (API 34)  
Arquitetura: `arm64-v8a`  
Ambiente: Endpoint Público de Produção (Build Flavor Homolog sem `--dart-define=API_URL=...`)
Endpoint Efetivo: `https://aplicativo-api.mppb.mp.br`

---

## 1. Configuração da Rede Ativa

- Conexão Wi-Fi ativa com conectividade estável.
- Dados móveis desativados para isolamento determinístico.
- Conectividade verificada via probe `GET /api/public/health` em `https://aplicativo-api.mppb.mp.br` respondendo 200 OK.
- Escopo executado: estritamente leitura pública e observabilidade de estado offline/reconexão.

## 2. Jornada Executada (Início Online)

1. App MPPB iniciado a partir da Splash Screen.
2. Home pública carregada com sucesso.
3. Notícias carregadas e renderizadas na listagem principal com títulos, resumos e datas.
4. Cards públicos (Contatos, Diário Oficial, Processos, Certidão, Ouvidoria) interativos e responsivos.
5. Sem alertas de erro ou banners de conectividade na UI.
