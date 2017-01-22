#!/bin/bash

# Name: Script for Gmail widget for Ubersicht
# Description: Displays the sender and subject line of the latest email delivered to your gmail Inbox. 
# Author: Ryuei Sasaki
# Github: https://github.com/louixs/

# -- For debugging
function runDebugLogger(){
  if [ ! -e debugLogger.sh ]; then
    cd assets
    source debugLogger.sh
  else
    source debugLogger.sh    
  fi
   # Debug function to trace all scripts run below it
  activate_debug_logger
}

# Uncomment the below to enalbe the debugger
# runDebugLogger

# If any error occurs, exit a script with exit 1
function exitIfFail(){
  if $1; then :; else exit 1; fi
}

function runOauth (){
  if [ ! -e oauth.sh ]; then
    cd assets
    exitIfFail ./oauth.sh
  else
    exitIfFail ./oauth.sh
  fi
}

runOauth

function readCredVar(){ #rename as this is confusing this applies to extracting all values in a file after a colon :
  #$1 = file name 
  #$2 = var name e.g. CLIENT_ID
  local credVar=$(sed -e 1b "$1" | grep "$2" | sed 's/.*://' | sed 's/"//' | sed '$s/"/ /g' | xargs)
  echo "$credVar"
}

readonly PARENT_DIR=${PWD%/*}
readonly three_DIR_UP=${PWD%/*/*/*}
readonly COFFEE_FILE_NAME=$(ls ../ | grep .coffee)
readonly COFFEE_FILE="$PARENT_DIR"/"$COFFEE_FILE_NAME"
readonly GOOGLE_APP=$( readCredVar "$COFFEE_FILE" GOOGLE_APP )
readonly CONFIG_FILE="$three_DIR_UP"/google_oauth_"$GOOGLE_APP".config

whereAwk=$(which awk)
whereCat=$(which cat)
whereNetstat=$(which netstat)

foundPaths="${whereCat///cat}:${whereAwk///awk}:${whereNetstat///netstat}"
export PATH="$foundPaths" &&

#==============
# config
readonly TOKEN_FILE=token.db
readonly ACCESS_TOKEN=$(cat "$TOKEN_FILE" | grep access_token | awk '{print $2}' | tr -d \",)
readonly MESSAGE_ID=https://www.googleapis.com/gmail/v1/users/me/messages

getGmailData(){
  curl -sH "Authorization: Bearer $ACCESS_TOKEN" $1
}

function getGmailId(){
  local id=$(getGmailData $MESSAGE_ID )
  echo $id > id.db
}
getGmailId

function Ids(){
  local ids=$(./parsej.sh id.db | grep id | awk '{print $2}' | head -n$1)
  echo $ids
}

function makeMessageUrl(){
   echo https://www.googleapis.com/gmail/v1/users/me/messages/$1
}

function getLastMessage(){
  local latestId=$(Ids 1)
  local url=$(makeMessageUrl $latestId)
  local msg=$(getGmailData $url)
  echo $msg > gmail.db
}

getLastMessage

readonly from=$(./parsej.sh gmail.db | grep -A 1 From | tail -n1 | awk '{$1="";print $0}' | awk '{if(NF < 2){print $0}else{$NF=""; print $0}}')

readonly subj=$(./parsej.sh gmail.db | grep -A 1 Subject | tail -n1 | awk '{$1="";print $0}')

echo "$from,$subj"
