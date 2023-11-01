# Textbook 'Backend Development'

My Textbook on Backend Development. Developed on github, published at
http://backend-development.github.io

Topics covered are: Ruby on Rails, node.js and a tiny, tiny bit of next.js.

## How to Read the book

Point your browser at
https://backend-development.github.io

## How to contribute small changes

fork the repository
https://github.com/backend-development/backend-development-textbook

on the github site, browse the folders `sources`... you'll find
all the texts there. Use github's editing capability to fix
typos, add clarifications.

Send me a pull request when you're done.

## How to contribute large changes

fork the repository
https://github.com/backend-development/backend-development-textbook

you need ruby

run `bundle` to install dependencies

run `rake` to build the site in output/\*

When you are content with your changes, push up to your own github repository,
and send me a pull request

## built with

- code from the rails guides, found in the 'guides' folder of the rails repository#
- this includes syntax highlighting with rouge.rb for [these languages](https://rouge-ruby.github.io/docs/file.Languages.html)
- reveals.js for the slides https://revealjs.com/
- syntax highlighter highlight.js used through reveal.js


## neues bilder für das thema performance


in assests/images

Bilder caching-before-metrics-2.png

- 1: event#show, mit talks http://localhost:3000/events/111
step-4-cache-talks: sichtbar bei 0.6
- 2: event#show, barcamp 2022 https://stempelheft.multimediatechnology.at/events/142
BEFORE: sichtbar bei 3.2
step-1-font: sichtbar bei 0.8
setp-2-defer: sichtbar bei 0.5
step-4-cache-talks: sichtbar bei 0.6
step-5-cache-events-index:
- 3: event#index: archiv-seite https://stempelheft.multimediatechnology.at/events/archiv
BEFORE: sichtbar bei 1.1
step-1-font: sichtbar bei 2.4
setp-2-defer: sichtbar bei 1.5
step-5-cache-events-index: sichtbar bei 1.5



## TODO

Error: Action failed with "not found deploy key or tokens"
https://github.com/backend-development/backend-development-textbook/runs/3857968861?check_suite_focus=true
https://github.com/settings/tokens
https://github.com/peaceiris/actions-gh-pages/blob/2decf4e752abab9095efc5ace22a0e92ae2e6fec/src/set-tokens.ts
