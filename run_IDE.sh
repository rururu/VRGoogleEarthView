#!/bin/sh

cd $(dirname $0)

java -Djava.library.path=clips -jar clips/CLIPSIDE.jar

