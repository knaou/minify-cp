#!/bin/bash

TEMP_DIR=/tmp/minifier

function usage_exit() {
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
	copy_file $1
	for file in $FILES; do
		copy_file $file
	done
}

while getopts ab:oh OPT
do
	case $OPT in
		a) copy $OPTARG
			;;
		b) add_binary $OPTARG
			;;
		o) $OUT="TRUE"
			;;
		h) usage_exit
			;;
		\?) usage_exit
			;;
	esac
done
shift $((OPTIND - 1))

if [ "$OUT" == "TRUE" ]; then
	cd $TEMP_DIR
	tar zc .
fi

