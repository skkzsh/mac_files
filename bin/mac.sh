#!/bin/sh
#
# Repositoryにある
# Setting FilesやDirectoriesを共有させるために
# Symbolic Linkを張る
##################################################


### Setting

## 共有元のSetting FilesのDirctory
mac_dir=~/Repository/bitbucket/mac_files

## 共有元の各Directoryで共有させるFilesのList

keyremap='private.xml appdef_more.xml my_emacs_mode.xml emacs_mode_for_app.xml ignore_emacs_mode.xml snippets'

## rmのOption
alias rm='rm -i'
## Symbolic Linkを張る関数の読み込み
. ~/bin/SmartLn.sh


### Symbolic Link

## KeyRemap4MacBook
for file in $keyremap; do
    SmartLn ln $mac_dir/KeyRemap4MacBook/$file ~/Library/Application\ Support/KeyRemap4MacBook/$file
done

exit 0
