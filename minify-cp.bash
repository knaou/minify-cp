#!/bin/bash

TEMP_DIR=/tmp/minify-cp

function usage_exit() {
	echo "$0 [-a file] [-b executable] [-t temp_dir] [-h]" >&2
	echo "    -a: Add file" >&2
	echo "    -b: Add files as executable" >&2
	echo "        Files means itself and .so file used by it" >&2
	echo "    -t: Set path of added files" >&2
	echo "    -h: show this help" >&2
	exit 1
}

rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

function copy() {
	TO_FILE=$TEMP_DIR/.$1
	mkdir -p $(dirname $TO_FILE)
	echo Copying $1 >&2
	cp -r $1 $TO_FILE
}

function add_binary() {
	FILES=$( \
		ldd $1 | \
		grep '=>' | \
		sed -e 's/  */ /g' |
		cut -f3 -d' '
		echo $FILES \
	)
	copy $1
	for file in $FILES; do
		copy $file
	done
}

while getopts ab:t:h OPT
do
	case $OPT in
		a) copy $OPTARG
			;;
		b) add_binary $OPTARG
			;;
		t) TEMP_DIR=$OPTARG
			;;
		h) usage_exit
			;;
		\?) usage_exit
			;;
	esac
done
shift $((OPTIND - 1))

cd $TEMP_DIR
tar zc .

