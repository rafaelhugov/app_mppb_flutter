# Q1 - Baseline runtime

Data da execucao: 2026-09-25 16:30:17 -03

## Ambiente disponivel

| Item | Resultado |
| --- | --- |
| Emulador Android | NAO EXECUTADO - DEPENDENCIA EXTERNA: nenhum emulador Android ativo detectado |
| Dispositivo Android conectado | NAO EXECUTADO - DEPENDENCIA EXTERNA: `adb devices` retornou lista vazia |
| APK instalado | NAO EXECUTADO - DEPENDENCIA EXTERNA: sem device/emulador Android |
| Chrome/web | Disponivel; `flutter devices` listou Chrome |
| Linux desktop | Disponivel; `flutter devices` listou Linux |
| Backend publico padrao | Acessivel; `GET https://aplicativo-api.mppb.mp.br/api/public/health` retornou `status: UP` |
| Noticias publicas | Acessivel; `GET https://aplicativo-api.mppb.mp.br/api/public/noticias` retornou lista JSON |

## Execucao web local

Comando:

```bash
flutter run -d chrome --web-port 8091 -t lib/main.dart
```

Resultado:

- App carregou em `http://localhost:8091`.
- Console sem erros JavaScript observados durante o smoke.
- Warnings observados: mensagens WebGL `GPU stall due to ReadPixels`; FCM desabilitado nesta plataforma, esperado no web.

## Smoke publico executado

| Fluxo | Resultado | Evidencia |
| --- | --- | --- |
| Inicializacao/Home publica | PASSOU em Chrome web; tela carregou sem crash/tela branca | `qualidade/evidencias/Q1/home-web.png` |
| Noticias | PASSOU em Chrome web; rota carregou sem crash/tela branca | `qualidade/evidencias/Q1/noticias-web.png` |
| Diario Oficial | PASSOU em Chrome web; rota carregou sem crash/tela branca | `qualidade/evidencias/Q1/diario-oficial-web.png` |
| Processos/consulta publica | PASSOU em Chrome web; rota carregou sem crash/tela branca | `qualidade/evidencias/Q1/processos-web.png` |
| Certidao Extrajudicial | PASSOU em Chrome web; rota carregou sem crash/tela branca | `qualidade/evidencias/Q1/certidao-extrajudicial-web.png` |
| Login - tela | PASSOU em Chrome web; tela carregou sem crash/tela branca | `qualidade/evidencias/Q1/login-web.png` |

## Autenticacao e area autenticada

| Fluxo | Resultado | Causa |
| --- | --- | --- |
| Login valido | NAO EXECUTADO - DEPENDENCIA EXTERNA | Credenciais/massa autorizadas nao foram fornecidas |
| Login invalido | NAO EXECUTADO - DEPENDENCIA EXTERNA | Evitou-se acionar Auth API sem massa/criterio autorizado nesta Q1 |
| Entrada na area autenticada | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais |
| Manutencao da sessao | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais |
| Logout | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem sessao autenticada |
| Perfil | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais |
| Carteira Funcional | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/massa |
| Contracheque/PDF | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/massa |
| Pagamentos | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/massa |
| Designacoes | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/massa |
| Concessoes/Afastamentos | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/massa |
| Notificacoes autenticadas | NAO EXECUTADO - DEPENDENCIA EXTERNA | Sem credenciais/dispositivo FCM real |

## Observacoes runtime

- O smoke foi funcional e visual basico em Chrome web, nao substitui validacao Android/APK.
- Sem Android conectado, nao foi possivel validar instalacao/execucao real do APK, biometria, FCM real, compartilhamento nativo ou PDF nativo.
- Nao foram observados crash, tela branca ou erro visual grave nos fluxos publicos renderizados em web.

