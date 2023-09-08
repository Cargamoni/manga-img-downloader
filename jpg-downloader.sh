#!/bin/bash

MAINURL=$1
DOWNDIR="./assets"
SITESEARCH=$2
SITEMAXCONT=$3
round() {
  local dividend="$1"
  local divisor="$2"
  local result

  result=$(awk "BEGIN { rounded = int($dividend / $divisor + 0.5); print (rounded < $dividend / $divisor + 0.5) ? rounded : rounded - 1 }")
  echo "$result"
};

RESULT=$(curl -s https://$MAINURL/search/$SITESEARCH/ | grep -i results | cut -d '-' -f2 | awk '{print $1}')
PAGING=$(round $RESULT $SITEMAXCONT)
BEGPAG=1

while [ $BEGPAG -lt $PAGING ]
do
    BEGPAG=$(($BEGPAG + 1))
    echo https://$MAINURL/search/$SITESEARCH/?p=$BEGPAG
    curl https://$MAINURL/search/$SITESEARCH/?p=$BEGPAG
    exit 0
done











### DEBUG ###
# echo https://$MAINURL/search/$SITESEARCH/
# echo Result=$RESULT
# echo Rounded=`round $RESULT $SITEMAXCONT` 
