#!/bin/env
rm -rf public/
hugo
in=$(find public/css/*.css) && purifycss $in public/index.html -m -i -o $in
