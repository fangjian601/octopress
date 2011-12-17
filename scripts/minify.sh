#!/bin/bash

old_pwd=`pwd`

base_dir=`dirname $0`/..

base=`cd $base_dir; pwd`

cd $old_pwd

find $base/public -iname "*.js" | while read file
do
    echo "minifying $file"
    java -jar $HOME/.tools/yuicompressor-2.4.7.jar --type js -o $file $file
done

find $base/public -iname "*.css" | while read file
do
    echo "minifying $file"
    java -jar $HOME/.tools/yuicompressor-2.4.7.jar --type css -o $file $file
done



