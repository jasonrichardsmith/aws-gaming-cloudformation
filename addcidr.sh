#!/bin/bash
myip=$(curl -w '\n' ipinfo.io/ip)
mycidr="$myip/32"
cat parameters.json | jq -r --arg v "$mycidr" '. +=[{"ParameterKey": "MyCIDR","ParameterValue": $v}]'
