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


ENTRYPOINT ["/sbin/tini","-g","--","bundle","exec","jekyll"]
CMD [\
	"serve",\
	"--host","0.0.0.0",\
	"--port","4000",\
	"--safe",\
	"--livereload",\
	"--watch",\
	"--force_polling",\
	"--source","docs"\
	]
