# 📱 PharmaNexux — Como gerar e baixar o seu APK (passo a passo)

Este guia ensina, do zero, como transformar o projeto que você recebeu no arquivo
`app-release.apk` instalável no Android — tudo **gratuito**, usando apenas o navegador.

A ideia é simples: o GitHub (site gratuito de hospedagem de código) tem um serviço
chamado **GitHub Actions** que "empresta" um computador na nuvem para compilar o app
para você. Você sobe os arquivos, ele compila sozinho e te entrega o APK pronto.

---

## Parte 1 — Criar sua conta no GitHub (5 min)

1. Acesse **https://github.com** no navegador.
2. Clique em **Sign up** (criar conta).
3. Informe seu e-mail, crie uma senha e um nome de usuário (ex.: `hmservices`).
4. Confirme o código que chega no seu e-mail. Pronto, conta criada — o plano
   gratuito é suficiente para tudo que vamos fazer.

## Parte 2 — Criar o repositório do projeto (2 min)

Um "repositório" é como uma pasta na nuvem onde o projeto vai morar.

1. Logado no GitHub, clique no botão **+** no canto superior direito → **New repository**.
2. Em **Repository name**, digite: `pharmanexux`
3. Marque a opção **Public** (necessária para o serviço de compilação ser gratuito e ilimitado).
4. Marque a caixinha **Add a README file** (isso facilita os próximos passos).
5. Clique em **Create repository**.

## Parte 3 — Subir os arquivos do projeto (10 min)

Você recebeu o arquivo **pharmanexux.zip**. Primeiro, **extraia o zip** no seu
computador (clique com o botão direito → "Extrair tudo"). Vai aparecer uma pasta
`pharmanexux` com: `lib`, `assets`, `pubspec.yaml`, `TUTORIAL.md` e uma pasta
(possivelmente oculta) chamada `.github`.

Agora, no seu repositório no GitHub:

1. Clique em **Add file** → **Upload files**.
2. Abra a pasta extraída no seu computador e **arraste para a página do GitHub**:
   - a pasta `lib`
   - a pasta `assets`
   - o arquivo `pubspec.yaml`
   - (o `TUTORIAL.md` é opcional)

   💡 Dica: arraste as pastas inteiras — o GitHub mantém a estrutura interna.
3. Desça a página e clique no botão verde **Commit changes**.

### 3b — Criar o arquivo de compilação automática

A pasta `.github` costuma ficar **oculta** no Windows e o arraste dela pode falhar.
Por isso, vamos criar esse arquivo manualmente (é rápido):

1. No repositório, clique em **Add file** → **Create new file**.
2. No campo do nome do arquivo, digite **exatamente** (com os pontos e as barras):

   ```
   .github/workflows/build-apk.yml
   ```

   (Ao digitar cada `/`, o GitHub cria a pasta automaticamente.)
3. No campo grande de conteúdo, cole **todo** o conteúdo do arquivo
   `.github/workflows/build-apk.yml` que veio no zip.
   (Se não conseguir ver a pasta oculta, o mesmo conteúdo está no final deste tutorial — Apêndice A.)
4. Clique em **Commit changes**.

## Parte 4 — A mágica: compilação automática (10–15 min de espera)

Assim que você salvar o arquivo da Parte 3b, a compilação começa **sozinha**.

1. Clique na aba **Actions** (no topo do repositório).
2. Você verá uma linha chamada *"Compilar APK do PharmaNexux"* com uma bolinha
   amarela 🟡 (compilando). Aguarde uns 10 a 15 minutos.
3. Quando a bolinha ficar **verde ✅**, o APK está pronto!
   - Se ficar vermelha ❌, clique nela para ver o erro e me mande uma foto/print
     que eu te ajudo a resolver.

💡 Se a compilação não iniciar sozinha: aba **Actions** → clique em
*"Compilar APK do PharmaNexux"* na lista da esquerda → botão **Run workflow**.

## Parte 5 — Baixar o APK

O jeito mais fácil (funciona até pelo celular):

1. Na página inicial do repositório, procure na coluna da direita a seção
   **Releases** e clique em **"PharmaNexux — APK mais recente"**.
2. Baixe o arquivo **app-release.apk**.

Caminho alternativo: aba **Actions** → clique na execução verde ✅ → seção
**Artifacts** (no final da página) → baixe **PharmaNexux-APK** (vem em um zip;
extraia para obter o `app-release.apk`).

## Parte 6 — Instalar no Android

1. Abra o arquivo `app-release.apk` no celular (se baixou pelo computador,
   envie para o celular por WhatsApp, e-mail ou cabo USB).
2. O Android vai avisar que o app não vem da Play Store e pedir permissão para
   **"instalar apps de fontes desconhecidas"** — toque em **Configurações** e
   ative a permissão para o app que abriu o arquivo (ex.: Chrome ou Arquivos).
3. Toque em **Instalar**. Pronto! O PharmaNexux estará na sua tela inicial. 🎉

> É normal o Google Play Protect exibir um aviso extra na primeira instalação,
> porque o app não passou pela loja. Toque em "Instalar mesmo assim".

## Como atualizar o app no futuro

Sempre que quiser mudar algo (novos medicamentos, novos casos clínicos):

1. Edite ou substitua os arquivos no GitHub (dá para editar os `.json` de dados
   direto no navegador: abra o arquivo → ícone de lápis ✏️ → salve).
2. Ao salvar (**Commit changes**), a compilação roda de novo sozinha.
3. Baixe o novo APK na seção **Releases** e instale por cima do antigo.

Os dados do app ficam em `assets/data/`:
- `medicamentos.json` — a apostila (medicamentos, classes, macetes e sintomas associados)
- `casos.json` — os casos clínicos e as perguntas do quiz

---

## Apêndice A — Conteúdo do arquivo `.github/workflows/build-apk.yml`

```yaml
name: Compilar APK do PharmaNexux

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Baixar o código
        uses: actions/checkout@v4

      - name: Instalar Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Gerar estrutura Android
        run: |
          flutter create . --platforms android --project-name pharmanexux --org com.hmservices
          git checkout -- .

      - name: Baixar fontes Inter e Manrope (opcional)
        continue-on-error: true
        run: |
          mkdir -p fonts
          curl -fsSL -o "fonts/Inter.ttf" "https://raw.githubusercontent.com/google/fonts/main/ofl/inter/Inter%5Bopsz%2Cwght%5D.ttf"
          curl -fsSL -o "fonts/Manrope.ttf" "https://raw.githubusercontent.com/google/fonts/main/ofl/manrope/Manrope%5Bwght%5D.ttf"
          {
            echo ''
            echo '  fonts:'
            echo '    - family: Inter'
            echo '      fonts:'
            echo '        - asset: fonts/Inter.ttf'
            echo '    - family: Manrope'
            echo '      fonts:'
            echo '        - asset: fonts/Manrope.ttf'
          } >> pubspec.yaml

      - name: Instalar dependências
        run: flutter pub get

      - name: Gerar ícone do aplicativo
        continue-on-error: true
        run: dart run flutter_launcher_icons

      - name: Compilar APK (release)
        run: flutter build apk --release

      - name: Guardar APK como artefato
        uses: actions/upload-artifact@v4
        with:
          name: PharmaNexux-APK
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Publicar APK na página de Releases
        uses: softprops/action-gh-release@v2
        with:
          tag_name: v1.0-latest
          name: PharmaNexux — APK mais recente
          body: |
            APK do PharmaNexux gerado automaticamente.
            Baixe o arquivo app-release.apk abaixo e instale no Android.
          files: build/app/outputs/flutter-apk/app-release.apk
```

---

**PharmaNexux** — a conexão inteligente do conhecimento farmacológico.
Ferramenta de estudo: não substitui prescrição, diagnóstico ou orientação profissional.
