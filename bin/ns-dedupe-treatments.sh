#!/bin/bash

self=$(basename $0)

function usage ( ) {
cat <<EOF
Usage: $self --find <NIGHTSCOUT_HOST>
$self delete <NIGHTSCOUT_HOST>
EOF
}

function fetch ( ) {
  curl -s $ENDPOINT.json
}

function flatten ( ) {
  json -a created_at | uniq -c
}


function find_dupes_on ( ) {
  count=$1
  date=$2
  test $count -gt 1  && curl -g -s ${ENDPOINT}.json"?count=$(($count-1))&find[created_at]=$date" 
}
function debug_cmd ( ) {
tid=$1
echo -n  curl -X DELETE -H "API-SECRET: $API_SECRET" ${ENDPOINT}/${tid}
}

function delete_cmd ( ) {
tid=$1
(set -x
curl -X DELETE -H "API-SECRET: $API_SECRET" ${ENDPOINT}/$tid 
)
}

function main ( ) {
NIGHTSCOUT_HOST=$1
ACTION=${2-debug_cmd}
ENDPOINT=${NIGHTSCOUT_HOST}/api/v1/treatments

if [[ -z "$NIGHTSCOUT_HOST" || -z "$NIGHTSCOUT_HOST" ]] ; then
  test -z "$NIGHTSCOUT_HOST" && echo NIGHTSCOUT_HOST undefined.
  test -z "$API_SECRET" && echo API_SECRET undefined.
  usage
  exit 1;
fi

export NIGHTSCOUT_HOST ENDPOINT
fetch | flatten | while read count date; do
  find_dupes_on $count $date | json -a _id \
  | head -n 30 | while read tid line ; do
    echo -n $count' '
    $ACTION $tid
    echo
  done
done


}

export API_SECRET
case "$1" in
  --find)
    main $2
    ;;
  delete)
    main $2 delete_cmd
    ;;
  *|help)
    usage
    exit 1;
    ;;
esac
# curl -s bewest.labs.diabetes.watch/api/v1/treatments.json | json -a created_at | uniq -c | while read count date; do test $count -gt 1  && curl -g -s bewest.labs.diabetes.watch/api/v1/treatments.json"?count=$(($count-1))&find[created_at]=$date" |   json -a _id | head -n 30 | while read tid line ; do  echo $count; (set -x;  curl -X DELETE -H "API-SECRET: $API_SECRET" bewest.labs.diabetes.watch/api/v1/treatments/$tid) ; done ; done  

# curl -s bewest.labs.diabetes.watch/api/v1/treatments.json | json -a created_at | uniq -c | while read count date; do test $count -gt 1  && curl -g -s bewest.labs.diabetes.watch/api/v1/treatments.json"?count=$(($count-1))&find[created_at]=$date" |   json -a _id | head -n 30 | while read tid line ; do  echo $count curl -X DELETE -H "API-SECRET: $API_SECRET" bewest.labs.diabetes.watch/api/v1/treatments/$tid ; done ; done  | cut -d ' ' -f 2-
