#! /bin/sh
cd $(dirname $(which "$0"))/..
java -Djava.class.path=lib/bar-${bar.version}.jar -Djava.library.path=native dummy.bar.Main
