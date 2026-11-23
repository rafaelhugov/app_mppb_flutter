# Spec 011 — Melhorias no Painel de Envio, Acompanhamento e Seleção de Destinatários

## Requisitos Funcionais
- **RF-01 (Validação e aviso de tamanho de anexo)**: Validar localmente o tamanho máximo antes do upload conforme os limites do servidor (Imagem: 10 MB, Áudio: 15 MB, Documento: 25 MB, Vídeo: 50 MB), exibindo `AppFeedback.showError` com o tamanho do arquivo e o limite permitido; também exibir `AppFeedback.showError` caso o upload falhe no servidor (ex.: HTTP 413/400).
- **RF-02 (Overflow na barra de formatação)**: Corrigir o overflow horizontal de 1.4px no botão `Prévia` da barra de formatação em `ComporMensagemPage` em telas estreitas.
- **RF-03 (Atualização automática de entrega, leitura e ciência)**: `AcompanhamentoMensagemPage` e `PainelRemetentePage` devem realizar atualização automática periódica (a cada 5s enquanto a tela estiver ativa) e silenciosa para refletir entregas, leituras e ciências em tempo quase real sem exigir toque no botão de atualizar.
- **RF-04 (Limpar campo de busca após selecionar usuário)**: Em `SeletorDestinatariosWidget` e `GrupoEditorPage`, ao selecionar um usuário nos resultados da busca, o texto digitado e a lista de resultados devem ser limpos automaticamente para permitir digitar o próximo nome imediatamente.
- **RF-05 (Arquivar/Desarquivar avisos no Painel do Remetente)**: `PainelRemetentePage` deve oferecer filtro de `Ativos` vs `Arquivados` e ação visível para arquivar/desarquivar avisos enviados diretamente no painel (além de deslize lateral).
