---
lang: ja
permalink: /ja/
---

{% raw %}

# GitHub Pages - jekyll カスタマイズ方法<!-- omit from toc --> 

- [概要](#概要)
	- [最終的なファイル構成](#最終的なファイル構成)
	- [その前に - フロントマターについて](#その前に---フロントマターについて)
	- [なぜここでフロントマターの説明をするのか](#なぜここでフロントマターの説明をするのか)
- [テーマの指定とカスタマイズ](#テーマの指定とカスタマイズ)
	- [テーマの指定](#テーマの指定)
	- [CSS のカスタマイズ](#css-のカスタマイズ)
	- [HTML のカスタマイズ](#html-のカスタマイズ)
- [多言語対応](#多言語対応)
	- [概要](#概要-1)
	- [`/ja/` ,`/en/` ディレクトリ](#ja-en-ディレクトリ)
		- [各ページでのフロントマター](#各ページでのフロントマター)
	- [`/index.html` で自動リダイレクトさせる](#indexhtml-で自動リダイレクトさせる)
		- [`docs/_includes/hreflang.html`:](#docs_includeshreflanghtml)
		- [`docs/index.html`](#docsindexhtml)
	- [各ページに言語リンクを追加する](#各ページに言語リンクを追加する)
		- [`docs/_data/i18n.yml`](#docs_datai18nyml)
		- [`docs/_includes/lang-switcher.html`:](#docs_includeslang-switcherhtml)
		- [`docs/_layouts/default.html`](#docs_layoutsdefaulthtml)
- [Docker コンテナを使ったローカルテスト](#docker-コンテナを使ったローカルテスト)
	- [その前に `docs/_config.local.yml`](#その前に-docs_configlocalyml)
	- [Docker イメージのビルドと起動](#docker-イメージのビルドと起動)


## 概要

GitHub Actions を使わずにデフォルト(jekyll)の方法でリポジトリの `docs/` 以下を GitHub Pages で公開するに当たり、以下の 2 点について説明します。

- テーマの指定およびカスタマイズ方法
- 多言語対応方法（の内の一つ）

### 最終的なファイル構成

最終的なファイル構成がどのようになるのかを先に示しておきます。

```
docs/
├── _config.yml             # テーマやサイト全体で使うパラメータの定義など
├── _data/
│   └── i18n.yml            # i18n 向けラベルテーブルなど
├── _includes/
│   ├── hreflang.html       # クローラー向けコンテンツ URL の場所を示す HTML パーツ
│   └── lang-switcher.html  # 言語切り替え用の nav リンク HTML パーツ
├── _layouts/
│   └── default.html        # 採用したテーマのコピー・カスタマイズ用
├── assets/
│   └── css/
│       └── style.scss      # スタイルシートのカスタマイズ用ファイル
├── en/
│   └── README.md           # 英語トップページダミー
├── index.html              # JS による /en/,/ja/ 自動リダイレクトを行うページ
└── ja/
    └── README.md           # 日本語トップページ（このページ）
```

これらのファイルはすべて本リポジトリに格納されているので、実物を見たい場合はそちらを参照してください。


### その前に - フロントマターについて

**フロントマター**とは markdown の先頭に YAML 形式で書くメタ情報のことです。Obsidian で採用されているのが有名です。

形式は以下の通りです。

```markdown
---
foo: bar
fizz: buzz
---

# 本文
...
```

`---` に挟まれたパートが YAML として解釈される**フロントマター**です。

jekyll では markdown だけではなく HTML や SCSS ファイルでもフロントマターを記述できます。

### なぜここでフロントマターの説明をするのか

jekyll は Liquid という Shopify が開発したテンプレートエンジンを採用しています。

jekyll はフロントマターに書かれたパラメータを読み込み、Liquid に渡してパラメータ展開に使用します。

したがって以下の `{{ lang }}` は `日本語` に置換されます。

```markdown
---
lang: 日本語
---

この言語は {{ lang }} です。
```

しかし、フロントマターが無い場合は `{{ lang }}` が展開されず、そのまま `{{ lang }}` と表示されます。

つまり、フロントマターが付いていないファイルはテンプレートエンジンに渡されず、そのまま使われる仕組みになっています。

ですが、テンプレートエンジンが埋め込むパラメータには jekyll が提供するグローバルなパラメータや、`_config.yaml` でサイト全体向けに定義したパラメータも含まれます。

そのため、そのページや HTML パーツ自体にフロントマターによるメタ情報を埋め込む必要がなくても、フロントマターを書いておかないとそれらパラメータの埋め込み機能が働きません。

こういった場合は**空のフロントマターを書いておく必要があります**。空のフロントマターは以下の通りです。

```
---
---
```

_ちなみに最初の `---` は必ず一行目に書かないといけないようです。_

以降の説明でこの空のフロントマターが何度も出てきますが、これはこうした理由によって付けられたものであり、省略してはいけないものです。


## テーマの指定とカスタマイズ

### テーマの指定

テーマには GitHub Pages がデフォルトでサポートしている組み込みのテーマと、外部テーマの2種類がありますが、ここではひとまず組み込みのテーマを扱います。

デフォルトで組み込まれているテーマは以下のリポジトリに格納されています。

- [“GitHub Pages themes”](https://github.com/pages-themes)

ここでは例として [`slate`](https://pages-themes.github.io/slate/) を適用します。この場合 `docs/_config.yml` を作成して以下のように記述します。

`docs/_config.yml`:
```yaml
theme: jekyll-theme-slate
```

この `jekyll-theme-slate` という名前は[テーマ側のリポジトリ](https://github.com/pages-themes/slate)にある `_config.yml` に記述されている名前を使います。テーマの名前は大抵 `jekyll-theme-****` という命名になっています。

この `docs/_config.yml` をコミット・プッシュすれば GitHub Pages 上でテーマが適用されます。


### CSS のカスタマイズ

`docs/assets/css/style.scss` というファイルを作り、ベースの状態として以下のように記述しておきます。

```scss
---
---

@import "{{ site.theme }}";
```

`{{ site.theme }}` は先ほど `_config.yml` の `theme` に書いた `jekyll-theme-slate` に置換されます。つまり `@import "jekyll-theme-slate";` と書いているのと同じになります。

あとはブラウザの「検証」機能やテーマのリポジトリにあるスタイルを見て、カスタム内容を書き込んでいけば OK です。

テーマ側の CSS 定義は大体リポジトリの `_sass` ディレクトリに格納されています。

拡張子から分かるとおり、jekyll は Sass/SCSS を採用しているので修正したい属性値のみを書けばその属性値だけ上書きしてくれます。

例えば `slate` のコンテンツブロック用のセレクタは以下のように定義されています。

```scss
.inner {
  position: relative;
  max-width: 640px;
  padding: 20px 10px;
  margin: 0 auto;
}
```

今時のブラウザで見るのにコンテンツの最大幅が `640px` というのはいささか狭すぎるので、`768px` にしたいだけの場合、`docs/assets/css/style.scss` には以下のように書き込めば良いです。

```scss
---
---

@import "{{ site.theme }}";

.inner {
  max-width: 768px;
}
```

### HTML のカスタマイズ

こちらは CSS よりやや原始的な方法になります。テーマのリポジトリから HTML をコピーしてきて、`docs/_layouts/default.html` に置きます。

このファイルはテーマ側のリポジトリの `_layouts/default.html` にあります。

このコピーしてきたファイルを編集することでテーマの HTML をカスタマイズできます。


## 多言語対応

### 概要

jekyll そのものには多言語対応のための機能は含まれていないので、基本的には自分で実装する必要があります。

方針は概ね以下の様になります:

1. 日本語ページと英語ページをそれぞれ `/ja/` ,`/en/` ディレクトリに分けます
2. `/index.html` でブラウザの `accept-language`（実際には JS の `navigator.languages` など） を参照して JS でリダイレクトします
3. 各言語のページのヘッダに言語切り替えの UI を追加します

### `/ja/` ,`/en/` ディレクトリ

特に難しいことはありません。  
リポジトリの `docs/ja/`,`docs/en/` ディレクトリを作り、その直下に適当な `README.md` や他のファイルを置いておきます。

ただしフロントマターに `lang` で `ja` のページなのか `en` のページなのか設定しておく必要があります。これは後述する言語切り替え用のナビゲーション上のラベルを切り替えるのに使います。

#### 各ページでのフロントマター

例えば以下のように書きます。

```markdown
---
layout: default
title: Hello World
---
```

これにより以下のような効果が得られます。

- `layout`: テンプレートに `/_layout/default.html` を使うことを指定できます。`default` はデフォルトの定義なのでこの場合 `layout` は省略しても構いません。
- `title`: ページタイトルを "Hello World" にします。デフォルトではリポジトリ名がページタイトルになります。

こういった予約ワードの一部は公式ドキュメントで説明されていますが、すべての予約ワードを知りたければソースを読む必要があります。

- [“Front Matter”](https://jekyllrb.com/docs/front-matter/)

予約されていないワードについては Liquid による変数展開に使用できます。


### `/index.html` で自動リダイレクトさせる

以下、見出しのファイルを作成してください。

#### `docs/_includes/hreflang.html`:

一種の SEO 対策。JavaScript によるリダイレクトを行う為、検索エンジンのクローラーが実際のサイトを辿れるようにする `link` タグを記述しておきます。

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

以下、見出しのファイルを作成してください。

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

これで GitHub Pages のテーマ設定と HTML カスタマイズの基本、多言語対応でサイトルートにアクセスすると自動的に `/en/` と `/ja/` にリダイレクトする仕組みが完成します。

各ページのフロントマターに `lang` を指定しておけば、言語切り替え用リンクのラベルもそれぞれの言語で表示されるので忘れないようにしてください。


## Docker コンテナを使ったローカルテスト

本リポジトリには Docker コンテナを使ったローカルテスト用の `docker-compose.yaml` とビルド用の `Dockerfile` が用意されています。

これらを使えば簡単にローカルでの確認が行えます。

### その前に `docs/_config.local.yml`

ただし、そのまま動かすと jekyll が git の情報からリポジトリ名などを使ったパスを構築してしまい、ローカル環境と合わずにうまく表示できません。そのため、治具を噛ませる必要があります。

それが `docs/_config.local.yml` というファイルで、中身は以下のようにしておきます。

```yaml
url: ""         # 127.0.0.1:4000 で見るときは空にします
baseurl: ""     # ルート直下で配信させます（/ になる）
```

### Docker イメージのビルドと起動

```sh
# イメージのビルド（最初だけ）
$ docker compose build 

# コンテナの起動
$ docker compose up

# 止めるときは ctrl + c で止めるか、別のターミナルから
# docker compose down
# を実行します。
```

これで http://127.0.0.1:4000 から `docs/` 以下のプレビューを確認することができます。

{% endraw %}


