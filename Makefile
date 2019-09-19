#!/usr/bin/make

.PHONY: all
all: install

.PHONY: install
install:
	gem install bundler
	bundle install

.PHONY: local
local:
	bundle exec jekyll serve --drafts
