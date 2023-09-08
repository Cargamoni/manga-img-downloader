#!/bin/bash

MAINURL=$1
DOWNDIR="`pwd`/assets"
SITESEARCH=$2
SITEMAXCONT=$3
TMPDIR=/tmp/

# Page count rounder
round() {
  local dividend="$1"
  local divisor="$2"
  local result

  result=$(awk "BEGIN { rounded = int($dividend / $divisor + 0.5); print (rounded < $dividend / $divisor + 0.5) ? rounded : rounded - 1 }")
  echo "$result"
};

RESULT=$( [ ! -e $SITESEARCH-page-1.html ] && curl -s https://$MAINURL/search/$SITESEARCH/ | tee $SITESEARCH-page-1.html | grep -i results | cut -d '-' -f2 | awk '{print $1}')
PAGING=$(round $RESULT $SITEMAXCONT)
BEGPAG=1

while [ $BEGPAG -lt $PAGING ]
do
    echo "## Getting Page $BEGPAG ##"
    
    # Parse manga dir name and picture location to files
    grep cover $SITESEARCH-page-$BEGPAG.html | grep -v meta | cut -d '"' -f2 > MANGADIR
    grep caption $SITESEARCH-page-$BEGPAG.html | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/-//g' | sed 's/\.//g' | sed 's/ /_/g' > MANGANAME
    grep src $SITESEARCH-page-$BEGPAG.html | grep pics | cut -d '"' -f8 > MANGAPICLOC
   
    # Merge all manga dir name and picture in same line seperated by ";" char 
    MANGAVARS=$(paste -d ';' MANGADIR MANGANAME MANGAPICLOC)
    
    # Enter each manga site for page and content
    for MANGA in $MANGAVARS; do
        # Get each manga dir name and picture directory
        echo $MANGA 
        MANGADIR=$(echo $MANGA | cut -d ';' -f1)
        MANGANAME=$(echo $MANGA | cut -d ';' -f2 | tr -d '#$*?%&^')
        MANGAPICDIR=$(echo $MANGA | cut -d ';' -f3)
        
        # TODO Check MANGANAME if exists skip

        # Create Download dir, set download url and check how much manga page had, download selected manga poster
        mkdir -p $DOWNDIR/$MANGANAME
        DOWNURL="https://$MAINURL$MANGADIR"
        MAXMANGACOUNT=$(curl -s "$DOWNURL" | grep pages | cut -d '>' -f2 | cut -d ' ' -f1)
        curl -s $MANGAPICDIR -o $DOWNDIR/$MANGANAME/poster.jpg
       
        # Download each jpg in manga content
        PICTURESURL=$(echo $MANGAPICDIR | sed 's/\/poster.jpg//g')
        for (( PICSTART=1; PICSTART <= $MAXMANGACOUNT; PICSTART++ )) do
            curl -s $PICTURESURL/$PICSTART.jpg -o $DOWNDIR/$MANGANAME/$PICSTART.jpg
            # TODO Check if downloaded file empty, if empty try png
            echo hello > /dev/null
        done
    done
   
    # Clear left-ofs
    rm -f MANGADIR MANGANAME MANGAPICLOC $SITESEARCH-page-$BEGPAG.html
    BEGPAG=$(($BEGPAG + 1))

    # Iterating page numbers for each manga content  
    [ ! -e $SITESEARCH-page-$BEGPAG.html ] && curl -s https://$MAINURL/search/$SITESEARCH/?p=$BEGPAG -o $SITESEARCH-page-$BEGPAG.html
   
    # Special TODO Progress Bar
done


 ### DEBUG ###
# echo https://$MAINURL/search/$SITESEARCH/?p=$BEGPAG
# echo Result=$RESULT
# echo Rounded=`round $RESULT $SITEMAXCONT` 







