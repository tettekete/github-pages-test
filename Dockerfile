FROM ruby:3.2-alpine

RUN apk add --no-cache build-base git nodejs tini

WORKDIR /site

# ===== バージョン固定（必要に応じて値を更新）=====
# https://rubygems.org/gems/github-pages でリビジョン番号を確認する事が出来る
ARG PAGES_VERSION=232
# ================================================

COPY <<__EOL__ Gemfile
source "https://rubygems.org"
gem "github-pages", "=${PAGES_VERSION}", group: :jekyll_plugins
gem "webrick", "~> 1.8"
__EOL__

# 依存はイメージ層にインストール（起動高速化 & 再現性向上）
RUN bundle config set path "/usr/local/bundle" \
 && bundle install

# .git から自動的に読み込まれて URL 構築に使われるパラメータを無効化するコンフィグファイル
COPY <<__EOL__ _config.local.yml
# _config.local.yml
url: ""         # 127.0.0.1:4000 で見るときは空にする
baseurl: ""     # ルート直下で配信させる（/ になる）
__EOL__


ENTRYPOINT ["/sbin/tini","-g","--","bundle","exec","jekyll"]
CMD [\
	"serve",\
	"--host","0.0.0.0",\
	"--port","4000",\
	"--safe",\
	"--livereload",\
	"--watch",\
	"--force_polling",\
	"--source","docs",\
	"--config","docs/_config.yml,_config.local.yml"\
	]
