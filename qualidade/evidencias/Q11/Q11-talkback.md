# Q11 — Evidência TalkBack e Leitor de Tela em Android Físico (Q11-T08, Q11-C21)

Data: 01/10/2026 (Reconciliado Q11-R01)  
Dispositivo: Samsung Galaxy A52 (SM-A525M, Android 14 / One UI 6.1, serial `RX8RC09H70X`)  
Pacote Instalado no Dispositivo: `com.samsung.android.accessibility.talkback`  
Status: PARCIAL

---

## 1. Diretriz e Política de Auditoria

Conforme diretriz canônica da fase Q11:
> *"No Samsung Galaxy A52: executar validação manual controlada com TalkBack, se disponível. Não habilitar/desabilitar serviço de acessibilidade silenciosamente via comandos invasivos. Se for necessário ativar manualmente: documentar como cenário manual. Não exigir TalkBack para tudo: TalkBack real deve complementar, não substituir testes widget, SemanticsTester, guidelines, inspeção estrutural. Se TalkBack ficar indisponível: classificar runtime manual como BLOQUEADO ou PARCIAL."*

## 2. Diagnóstico no Dispositivo Físico

Comando executado via ADB:
```powershell
adb shell settings get secure enabled_accessibility_services
# Retorno: null
```

Declaração de status:
- O pacote do TalkBack está instalado no dispositivo (`com.samsung.android.accessibility.talkback`), porém inativo por padrão.
- Em respeito à integridade das configurações pessoais do aparelho, não foi realizada habilitação invasiva via shell.
- **Classificação formal**: `PARCIAL — roteiro manual definido, não executado com TalkBack ativo`.
- A integridade da árvore semântica (`SemanticsNode`) consumida nativamente pela API de Acessibilidade do Android foi comprovada integralmente por testes automatizados (`labeledTapTargetGuideline` e asserções de nós semânticos).

## 3. Roteiro Manual Formalizado

Cenário a ser percorrido sob TalkBack quando ativado explicitamente pelo usuário:
1. **Home Pública**: Foco inicial na AppBar anuncia "Início, botão" e "Notificações, botão". Brasão excluído da leitura. Cards de serviços anunciam título e subtítulo combinados. Dock anuncia nomes por extenso.
2. **Notícias**: Título anunciado na abertura da tela. Botões de paginação anunciam "Página anterior, botão" e "Próxima página, botão". Modal de detalhes anuncia "Fechar, botão".
3. **Login**: Botão voltar anuncia "Voltar, botão". Campos anunciam "Usuário, caixa de edição" e "Senha, caixa de edição, texto protegido". Botão de visibilidade anuncia "Mostrar senha / Ocultar senha". Botão "ACESSAR, botão". Erro verbalizado imediatamente via `liveRegion: true`.
4. **Consulta Processual**: Botão recarregar captcha anuncia "Recarregar captcha, botão". Botão fechar modal anuncia "Fechar, botão".
