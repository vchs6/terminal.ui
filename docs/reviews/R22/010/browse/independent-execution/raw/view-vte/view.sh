#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")"
stty size | tee size.txt
(
    printf '\033[0m\033[2J\033[H'
    cat -- snapshot.ansi
    printf '\033[0m\033[25;1H'
)
printf '0\n' > view.exit
touch ready
while [[ ! -e release ]]; do sleep .1; done
