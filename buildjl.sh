#!/bin/bash

for TRAVIS_TAG in "X11-v1.6.8+3" "Cairo-v1.14.12+4" "Pango-v1.42.4+3" "Fontconfig-v2.13.1+4" "Libuuid-v2.34.0+3" "libpng-v1.6.37+1" "HarfBuzz-v2.6.1+1" "Glib-v2.59.0+1" "Libffi-v3.2.1+0" "Graphite2-v1.3.13+0" "PCRE-v8.42.0+0" "FriBidi-v1.0.5+0" "FreeType2-v2.10.1+1" "Gettext-v0.20.1+0" "Zlib-v1.2.11+5" "Libiconv-v1.16.0+0" "Pixman-v0.38.4+1" "LZO-v2.10.0+0" "Bzip2-v1.0.6+0" "Expat-v2.2.7+0"; do
    dep="$(echo "$TRAVIS_TAG" | cut -d- -f1)"
    dir="$(tr '[:lower:]' '[:upper:]' <<< ${dep:0:1})${dep:1}"
    CI_REPO_OWNER="JuliaBinaryWrappers" CI_REPO_NAME="${dep}_jll.jl" TRAVIS_TAG="${TRAVIS_TAG}" julia --color=yes "${dir:0:1}/${dir}/build_tarballs.jl" --only-buildjl
done
