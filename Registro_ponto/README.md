# Registro de Ponto

Aplicativo Flutter para cadastro e login locais, confirmação opcional com biometria do aparelho e registro de data, hora e localização em SQLite. O registro só é habilitado quando as coordenadas do local de trabalho estão configuradas e o aparelho informa uma posição com precisão suficiente dentro do raio de 100 m. Autenticação e persistência não dependem de Firebase nem de conexão com a internet; a localização depende dos serviços disponíveis no aparelho.

## Requisitos

- Flutter 3.44 ou compatível com Dart `^3.12.0`.
- Android ou iOS com GPS/localização disponível.
- Android: Android Studio/SDK; no Windows, habilite Developer Mode se o Flutter solicitar suporte a symlinks.
- iOS: macOS com Xcode para compilar e executar.

Instale as dependências:

```bash
flutter pub get
```

## Coordenadas do trabalho

As coordenadas do local estão configuradas como `-22.658214, -47.345009`. Para usar outro local, informe suas coordenadas WGS84 ao executar:

```bash
flutter run --dart-define=WORKPLACE_LATITUDE=-22.658214 --dart-define=WORKPLACE_LONGITUDE=-47.345009
```

Os valores configurados são usados por padrão, então também é possível iniciar apenas com `flutter run`. Para Android Studio/VS Code, só configure `--dart-define` se quiser substituir o local. Informe valores decimais, sem símbolos de grau.

## Executar e testar

```bash
flutter run
flutter analyze
flutter test
```

Cadastre-se com e-mail e senha. A conta e a sessão ficam no banco local do aparelho; ao sair, a sessão é encerrada, e ao abrir o app novamente a sessão ativa é restaurada. No registro, permita acesso à localização e confirme com biometria se houver hardware e biometria cadastrada. Se não houver biometria disponível, o app informa que usou a sessão local. GPS desligado, permissão negada, precisão superior a 100 m, posição fora do raio e falha de gravação impedem o registro.

## Dados e privacidade

- Usuários e registros são persistidos no SQLite privado do app. Cada registro inclui usuário, e-mail, data, hora, latitude, longitude, precisão e distância calculada.
- Senhas não são armazenadas em texto puro: o app salva hash PBKDF2 com salt aleatório por conta.
- Os dados não são sincronizados com outros aparelhos e são removidos se os dados do app forem apagados ou o app for desinstalado.
- O banco SQLite não é cifrado pelo app. Para dados sujeitos a exigências de proteção adicionais, configure criptografia e gerenciamento de chaves apropriados.
- A posição e a distância são verificadas no cliente e podem ser afetadas por falsificação de GPS. A biometria usa a API nativa e depende do hardware, permissões e configuração do sistema.
