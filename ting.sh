#!/bin/bash

TING="${1}"
if [ -z "${1}" ] ; then
	TING="$(grep '/TING\s' /proc/mounts |cut -d ' ' -f 2)"
	if ! [ -d "${TING}/\$ting" ] ; then
		TING=
	fi
fi


if [ -z "${TING}" ]; then
	echo "TING could not be recognized automatically. Please enter the mount point of the TING pen as a parameter."
	echo
	echo "You shoud probably do something like this: $(blkid | awk '/LABEL="TING"/ {print "mount", $1, "/mnt/TING"}' | sed 's#:##g')"
	echo
        echo "Usage: $0 [Location of the \$ting folder]"

        exit 1
fi

tingPath="$TING"

pngEnd="_en.png"
txtEnd="_en.txt"
oufEnd="_en.ouf"
scrEnd="_en.script"

# removes ^M from file and rewrites the lines
cleanFile () {
    echo "Clean file $1"
    while read -r line
    do
        $(echo -n "$line" | tr -d $'\r' | grep "[0-9]" >> TBD_TEMP.TXT)
    done < "$filename"
    rm $1    
    sort -u TBD_TEMP.TXT > $1
    rm TBD_TEMP.TXT
    echo
}

# empties the whole file
emptyFile () {
    echo "Empty file $1"
    echo
    truncate --size=0 $1
}

checkFiles () {
    echo "Check file $3";
    thumbMD5=$(cat $3 | grep "ThumbMD5:" | grep -ow "[0-9a-z]*");
    s=$(echo "$1" | sed 's/^0*//')
    if [ -z $thumbMD5 ]; then
        echo "No preview image necessary"
    else
        echo "Downloading preview image $1$pngEnd"
        wget http://system.ting.eu/book-files/get/id/$s/area/en/type/thumb -O $2/$1$pngEnd
    fi

    fileMD5=$(cat $3 | grep "FileMD5:" | grep -ow "[0-9a-z]*")
    if [ -z $fileMD5 ]; then
        echo "No book file necessary"
    else
        echo "Downloading book file $1$oufEnd"
        wget http://system.ting.eu/book-files/get/id/$s/area/en/type/archive -O $2/$1$oufEnd
    fi
    scriptMD5=$(cat $3 | grep "ScriptMD5:" | grep -ow "[0-9a-z]*")
    if [ -z $scriptMD5 ]; then
        echo "No script file necessary"
    else
        echo "Downloading script file $1$scrEnd"
        wget http://system.ting.eu/book-files/get/id/$s/area/en/type/script -O $2/$1$scrEnd
    fi

    echo
}

getInfo () {
    s=$(echo "$1" | sed 's/^0*//')
    echo "short: $s"
    wget http://system.ting.eu/book-files/get-description/id/"$s"/area/en -O "$2"/"$1""$3"
}

getFiles () {
    bookId=$1
    echo "Loading BookId $bookId"
    getInfo $bookId "$2" $txtEnd
    checkFiles $bookId $2 "$2/$1$3$txtEnd"
    echo
}

echo "Location of \$ting folder: $tingPath"

filename="$tingPath/\$ting/TBD.TXT"
if [ -f "$tingPath/\$ting/TBD.TXT" ] ; then
	filename="$tingPath/\$ting/TBD.TXT"
elif [ -f "$tingPath/\$ting/tbd.txt" ] ; then
	filename="$tingPath/\$ting/tbd.txt"
else
	echo "Could not find tbd.txt nor TBD.TXT file in $tingPath/\$ting/"
	echo
	exit 1
fi

if [ "$(wc -l "$filename"|cut -d ' ' -f 1)" == 0 ] ; then
	echo 'No missing book found'
	exit 0
fi

if [ ! -w $filename ]; then
	echo "You do not have permissins to write to $filename."
	echo "Run this script as root or remount $tingPath with proper ownership"
	echo
	exit 1
fi
	
cleanFile "$filename"

while read -r line
do
    export bookId=$(echo -n "$line" | tr -d $'\r' | grep "[0-9]")
    getFiles "$bookId" "$tingPath/\$ting"

done < "$filename"

emptyFile "$filename"

echo "Syncing ..."
sync
