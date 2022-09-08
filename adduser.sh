#!/bin/sh
FailToSend(){
  echo "File is saved in userconfigs directory. You can copypaste it from terminal:" && \
  echo "#######################" && \
  cat ./userconfigs/${1}.ovpn && \
  echo "#######################" && \
  exit 0
}
test -z "${1}" && \
  echo "set user name:" && \
  echo "\$ ./adduser.sh username" && \
  exit 1
test -f $PWD/.env && . $PWD/.env
mkdir ./userconfigs -p
test -f ./userconfigs/${1}.ovpn && \
  echo User ${1} already exists && \
  exit 1
docker-compose exec server easyrsa build-client-full ${1} nopass
docker-compose exec server ovpn_getclient ${1} > ./userconfigs/${1}.ovpn
test -z "${TelegramToken}" && \
  echo "Telegram token is not set. Create your bot with https://t.me/BotFather" && \
  FailToSend ${1}
test -z "${TelegramChatID}" && \
  echo "Telegram Chat ID is not set." && \
  echo "You can check your Chat ID with https://t.me/RawDataBot" &&
  FailToSend ${1}
TelegramAPIURL="https://api.telegram.org/bot${TelegramToken}/sendDocument"
curl -F chat_id="${TelegramChatID}" -F document=@"${PWD}/userconfigs/${1}.ovpn" "${TelegramAPIURL}"
test "$?" -ne "0" && \
  echo "Telegram sending gone wrong" && \
  FailToSend ${1}
