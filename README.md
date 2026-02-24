# Resumo da Aula

## Instalação e Configuração
- Instalamos o Git
- Instalamos o VS Code
- Conectamos o Git com o GitHub
- Configuramos perfis no VS Code
- Usamos Live Share para colaboração

## Configuração do Git

Executamos os seguintes comandos no terminal:

```bash
git config --global user.email "meu.email@email.com"
git config --global user.name "nome.no.git"
```

## Criação de Pastas pelo Terminal

```bash
cd doc
mkdir gabidev
cd gabidev
mkdir mobile
type nul > README.md
```


# Introdução ao Desenvolvimento Mobile

### Tipos de desenvolvimento 

- Nativo
    - Android:
        - SDK: Android SDK
        - IDE: Android Studio
        - Linguagens: Kotlin e Java
        - Ambientes: Mac, Win e Linux
    
    - iOS:
        - SDK: Cocoa Touch
        - IDE: Xcode
        - Linguagens: Swift / Objective-C
        - Ambiente: Mac

- Multiplataforma
    - React Native:
        - SDK: Node.js
        - IDE: VS Code,
        - Linguagem: JavaScript / TypeScript
        - Ambientes: Mac, Win e Linux

    - Flutter:
        - SDK: Flutter SDK
        - IDE: VS Code / Android Studio
        - Linguagem: Dart
        - Ambientes: Mac, Win e Linux

    ## Preparação do Ambiente de Desenvolvimento    

    ## Instalação do FLutterSDK
    - Download do arquivo ZIP na página flutter.dev
    - Inclusão do flutter na pasta C:\src
    - Inclusão do flutter\bin nas variáveis de ambiente
    - Teste o flutter --version

    ### Instalação do AndroidSDK
    - Download do AndroidSDK - Command Line Tools
    - Adicionar o Command-Line ao C:\src\AndroidSDK
    - Adicionar o SDKManager as Variáveis de Ambiente
    - Download dos pacotes:
        - emulator
        - platforms
        - platform-tools
        - build-tools
    - Adicionar ADB e o Emulator as Variáveis de Ambiente
    - Criação da Imagem do Emulador
    - Build do Emulador - via SDKManager