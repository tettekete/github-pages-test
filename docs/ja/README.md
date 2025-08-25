---
lang: ja
permalink: /ja/
---

{% raw %}

# GitHub Pages - jekyll カスタマイズ方法<!-- omit from toc --> 

- [概要](#概要)
	- [最終的なファイル構成](#最終的なファイル構成)
- [テーマの指定とカスタマイズ](#テーマの指定とカスタマイズ)
	- [CSS のカスタマイズ](#css-のカスタマイズ)
	- [HTML のカスタマイズ](#html-のカスタマイズ)
- [多言語対応](#多言語対応)
	- [概要](#概要-1)
	- [`/ja/` ,`/en/` ディレクトリ](#ja-en-ディレクトリ)
	- [`/index.html` で自動リダイレクトさせる](#indexhtml-で自動リダイレクトさせる)
	- [各ページに言語リンクを追加する](#各ページに言語リンクを追加する)
- [Docker コンテナを使ったローカルテスト](#docker-コンテナを使ったローカルテスト)
	- [その前に `docs/_config.local.yml`](#その前に-docs_configlocalyml)
	- [Docker イメージのビルドと起動](#docker-イメージのビルドと起動)


## 概要

GitHub Actions を使わずにデフォルト(jekyll)の方法でリポジトリの `docs/` 以下を GitHub Pages で公開するに当たり、以下の 2 点について説明する。

- テーマの指定およびカスタマイズ方法
- 多言語対応方法（の内の一つ）

### 最終的なファイル構成

最終的なファイル構成がどの様になるのか先に示しておく。

```
docs/
├── _config.yml             # テーマやサイト全体で使うパラメータの定義など
├── _data/
│   └── i18n.yml            # i18n 向けラベルテーブルなど
├── _includes/
│   ├── hreflang.html       # クローラー向けコンテンツ URL の場所を示す HTML パーツ
│   └── lang-switcher.html  # 言語切り替え用の nav リンク HTML パーツ
├── _layouts/
│   └── default.html        # 採用したテーマのコピー・カスタマイズ用
├── assets/
│   └── css/
│       └── style.scss      # スタイルシートのカスタマイズ用ファイル
├── en/
│   └── README.md           # 英語トップページダミー
├── index.html              # JS による /en/,/ja/ 自動リダイレクトを行うページ
└── ja/
    └── README.md           # 日本語トップページ（このページ）
```

これらのファイルは全て本リポジトリに格納されているので、実物が見たくなったそちらを参照してください。

## テーマの指定とカスタマイズ

テーマには GitHub Pages がデフォルトでサポートしているいわば組み込みのテーマと、外部テーマの2種類があるが、ここではひとまず組み込みのテーマを扱う。

デフォルトで組み込まれているテーマは以下のリポジトリに格納されている。

- [“GitHub Pages themes”](https://github.com/pages-themes)

ここでは例として [`slate`](https://pages-themes.github.io/slate/) を適用するとする。この場合 `docs/_config.yml` を作成して以下の様に記述する。

`docs/_config.yml`:
```yaml
theme: jekyll-theme-slate
```

この `jekyll-theme-slate` という名前はテーマ側のリポジトリにある `_config.yml` に記述されている名前を使う。テーマの名前は大抵 `jekyll-theme-****` という命名になっている。

この `docs/_config.yml` をコミット・プッシュすればテーマが適用される。


### CSS のカスタマイズ

`docs/assets/css/style.scss` というファイルを作り、ベースの状態として以下の様に記述しておく。

```scss
---
---

@import "{{ site.theme }}";
```

冒頭の `---` 二つは後述する Liquid テンプレートエンジンを機能させるためのおまじない（空のフロントマター）なので省略してはいけない。

これにより `{{ site.theme }}` は先ほど `_config.yml` の `theme` に書いた `jekyll-theme-slate` に置換される。つまり `@import "jekyll-theme-slate";` と書いているのと同じになる。

あとはブラウザの「検証」機能や、テーマのリポジトリにあるスタイルを見てカスタム内容を書き込んでいけば OK。

テーマ側の CSS 定義は大体リポジトリの `_sass` ディレクトリに格納されている。

拡張子から分かるとおり、 jekyll は Sass/SCSS を採用しているので修正したい属性値のみを書けばその属性値だけ上書きしてくれる。

例えば `slate` のコンテンツブロック用のセレクタは以下の様に定義されている。

```scss
.inner {
  position: relative;
  max-width: 640px;
  padding: 20px 10px;
  margin: 0 auto;
}
```

今時のブラウザで見るのにコンテンツの最大幅が `640px` というのはいささか狭すぎるので、`768px` にしたいだけの場合、`docs/assets/css/style.scss` には以下の様に書き込めば良い。


```scss
---
---

@import "{{ site.theme }}";

.inner {
  max-width: 768px;
}
```



### HTML のカスタマイズ

こちらは CSS よりやや原始的な方法になる。テーマのリポジトリから HTML をコピーしてきて、`docs/_layouts/default.html` に置く。

このファイルはテーマ側のリポジトリの `_layouts/default.html` にある。

このコピーしてきたファイルを弄ることでテーマの HTML をカスタマイズすることができる。

#### Liquid テンプレートエンジン

この `default.html` では `{{ site.title }}` といった変数展開や `{% 〜 %}` を使ったロジックの埋め込みが可能。これは jekyll が採用した Liquid(Shopify開発) というテンプレーティングエンジンによる機能。

特に `_includes/` ディレクトリに置いた `html` ファイルを以下の様な構文で埋めこむことができる。

```liquid
{% include head-custom.html %}
```

次の多言語対応ではこの機能を使うので覚えておきたい。


## 多言語対応

### 概要

jekyll そのものに多言語対応のための機能は含まれていないので、ざっくり自分で実装する必要がある。

以下は概ねの方針。

1. ひとまず日本語ページと英語ページをそれぞれ `/ja/` ,`/en/` ディレクトリに分ける
2. `/index.html` でブラウザの `accept-language`（実際には JS の `navigator.languages` など） を参照して JS でリダイレクトする
3. 各言語のページのヘッダに言語切り替えの UI を追加する


### `/ja/` ,`/en/` ディレクトリ

特に難しい事はない。
リポジトリの `docs/ja/`,`docs/en/` ディレクトリを作り、その直下に適当な `README.md` を置いておく。

ただしフロントマターに `lang` で `ja` のページなのか `en` のページなのか設定しておく必要がある。これは後述する言語切り替え用のナビゲーション上のラベルを切り替えるのに使う。

#### フロントマター

ただし、冒頭に**フロントマター**がないと Liquid による処理を通さなくなるため、何も定義しないとしても markdown ファイルの先頭には以下の様にする必要がある(HTML の場合も同様)。

```
---
lang: ja
---

# 見出し
...
```

冒頭簿 `---` に挟まれた部分を**フロントマター**と呼び、この間には YAML 形式でパラメータを書くことが出来る。

例えば

```
---
layout: default
title: Hello World
---
```

と書くと、以下の様な効果をもたらす。

- `layout`: テンプレートに `/_layout/default.html` を使うことを指定出来る。`default` はデフォルトの定義なので省略して良い。
- `title`: ページタイトルを "Hello World" にする。デフォルトでは markdown 最初の見出しがタイトルになる。

予約ワードの一部は公式ドキュメントで説明されているが全ての予約ワードを知りたければソースを読め、というスタイルの模様。


- [“Front Matter”](https://jekyllrb.com/docs/front-matter/)


予約されていないワードについては Liquid による変数展開に使用する事ができる。

例えば HTML ファイルで:

```
---
lang: ja
---
```

と書いて置けば

```html
<html lang="{{ page.lang }}">
```

のように展開することができる。


### `/index.html` で自動リダイレクトさせる

#### `docs/_config.yml`:

各 HTML で URL を構築しやすい様に `url` と `baseurl` に URL 情報を設定しておきます。

```yaml
theme: jekyll-theme-slate
# GitHub Pages URL のスキーマ + ドメイン部分
url: https://tettekete.github.io
# GitHub Pages 上のルートパス部分
baseurl: /github-pages-test/
```

`domain` と `path` のような名前の方が適切に思えるが ChatGPT5 さんに聞いたところ jekyll の歴史的な事情で `url` と `baseurl` を使うのだそうな。


#### `docs/_includes/hreflang.html`:

SEO 対策。JavaScript によるリダイレクトを行う為、検索エンジンのクローラーが実際のサイトを辿れるようにする `link` タグを記述しておきます。

```html
<link rel="alternate" hreflang="en" href="{{ site.url }}{{ site.baseurl }}/en/">
<link rel="alternate" hreflang="ja" href="{{ site.url }}{{ site.baseurl }}/ja/">
<link rel="alternate" hreflang="x-default" href="{{ site.url }}{{ site.baseurl }}/">
```

#### `docs/index.html`

```html
---
---
<!-- ↑フロントマター。jekyll(Liquid) によるテンプレーティングを機能させるためのおまじない -->

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Redirecting…</title>
  {% include hreflang.html %}	<!-- SEO 対策 HTML を include -->
  <script>
    (function() {
      // 優先言語のリスト（例: ["ja", "en-US", "en"]）
      const langs = navigator.languages && navigator.languages.length
                    ? navigator.languages            // 標準的な優先リスト
                    : [navigator.language];          // 後方互換（古いブラウザ用）

      const siteUrl = "{{ site.baseurl }}";
      let target = siteUrl + "/en/"; // デフォルトを英語に

      for (const lang of langs) {
        if (lang.toLowerCase().startsWith("ja")) {
          target = siteUrl + "/ja/";
          break;
        } else if (lang.toLowerCase().startsWith("en")) {
          target = siteUrl + "/en/";
          break;
        }
        // 他の言語を追加したい場合はここに else if を足す
      }

      // クライアントサイドでリダイレクト
      window.location.replace(target);
    })();
  </script>
</head>
<body>
  <p>Redirecting… If not redirected, <a href="/en/">click here</a>.</p>
  <p>ページが自動的に遷移しない場合は <a href="/ja/">こちら</a>。</p>
</body>
</html>
```


### 各ページに言語リンクを追加する

#### `docs/_data/i18n.yml`

任意でテンプレートに埋めこめるパラメータを定義しておく。

```yaml
ja:
  read_in: "言語"
  english: "英語"
  japanese: "日本語"
en:
  read_in: "Language"
  english: "English"
  japanese: "Japanese"
```

この場合 `{{ site.data.i18n.en.japanese }}` と書けば `Japanese` に置き換わる。

これは次項の言語切り替え用ナビゲーションラベルで使う。


#### `docs/_includes/lang-switcher.html`:

各ページに表示する言語切り替えリングの HTML パーツファイル。

```html
<nav id="lang-switch-nav">
  <span>{{ site.data.i18n[page.lang].read_in }}:</span>
  <a href="{{ '/ja/' | relative_url }}">{{ site.data.i18n[page.lang].japanese | '日本語' }}</a> |
  <a href="{{ '/en/' | relative_url }}">{{ site.data.i18n[page.lang].english | 'English' }}</a>
</nav>
```

#### `docs/_layouts/default.html`

これは採用したテンプレートやカスタマイズの仕方によってインサート箇所などが異なるため、基本的なインサート方法のみ示します。


```html
<body>
...
{% include lang-switcher.html %}

...
</body>
```

-----

これで GitHub Pages のテーマ設定と HTML カスタマイズの基本と、多言語対応でサイトルートにアクセスすると自動的に `/en/` と `/ja/` にリダイレクトする仕組みが完成する。

各ページのフロントマターに  `lang` を指定しておけば言語切り替え用リンクのラベルもそれぞれの言語で表示されるので忘れずに。


## Docker コンテナを使ったローカルテスト

本リポジトリには Docker コンテナを使ったローカルテスト用の `docker-compose.yaml` とビルド用の `Dockerfile` が用意されている。

これらを使えば簡単にローカルでの確認が行える。

### その前に `docs/_config.local.yml`

ただし、普通に動かすと jekyll が git の情報からリポジトリ名などを使ったパスを構築してしまい、ローカルのパス環境と合わずうまく表示出来無いため、ちょっとした治具を噛ませる必要がある。

それが `docs/_config.local.yml` というファイルで中身は以下の様にしておく。

```yaml
url: ""         # 127.0.0.1:4000 で見るときは空にする
baseurl: ""     # ルート直下で配信させる（/ になる）
```

### Docker イメージのビルドと起動

```sh
# イメージのビルド（最初だけ）
$ docker compose build 

# コンテナの起動
$ docker comose up

# 止めるときは ctrl + c で止めるか別のターミナルから
# docker compose down
# を実行する。
```

これで http://127.0.0.1:4000 で `docs/` 以下を確認する事ができる。


{% endraw %}


