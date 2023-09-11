#!/bin/bash

format=$(getopt -n "$0" -l "sourceUrl:,sourceToken:,targetUrl:,targetToken:" -- -- -- -- "$@")
if [ $# -lt 4 ]; then
    echo "Wrong number of arguments are passed."
    exit
fi
eval set -- "$format"

while [ $# -gt 0 ]
do
    case "$1" in
        --sourceUrl) Grafana_Source_Url="$2"; shift;;
        --sourceToken) Grafana_Source_Token="$2"; shift;;
        --targetUrl) Grafana_Target_Url="$2"; shift;;
        --targetToken) Grafana_Target_Token="$2"; shift;;
        --) shift;;
    esac
    shift;
done


GetHeaders=("Authorization: Bearer $Grafana_Source_Token")
ContentType="Content-Type: application/json"
WriteHostBreak=$'\r\n------------------------------------------'

LibraryPanelResult=$(curl -X GET "$Grafana_Source_Url/api/library-elements" -H "${GetHeaders[@]}" -H "$ContentType")

LibraryPanels=$(echo "$LibraryPanelResult" | jq '.')

echo "$(echo "$LibraryPanels" | jq '.result.elements | length') Library Panels discovered." "$WriteHostBreak"


elements="$(echo "$LibraryPanels" | jq '.result.elements | length')"
elements="$(($elements-1))"


for i in $( eval echo {0..$elements} )
do
    PostBody="$(echo "$LibraryPanels" | jq ".result.elements["$i"]")"

    PostHeaders=("Authorization: Bearer $Grafana_Target_Token")
    response=$(curl -X POST "$Grafana_Target_Url/api/library-elements" -d "$PostBody" -H "${PostHeaders[@]}" -H "$ContentType")

    if [ $? -eq 0 ]; then
      echo "Element created on target Grafana Instance: $Grafana_Target_Url"
    else
      echo "Error Message: $response" >&2
    fi
done