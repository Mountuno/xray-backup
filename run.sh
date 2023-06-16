RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ "$(id -u)" -ne 0 ]; then
    echo "${RED}This script must be run with root privileges. Please run it as root or using sudo -l."
    exit 1
fi

echo "${GREEN}Welcome to ${RED}V2Last ${GREEN}Telegram Backup Helper."
echo ""
echo "${GREEN}__     ______  _              _     ____             _                "
echo "${GREEN}\ \   / /___ \| |    __ _ ___| |_  | __ )  __ _  ___| | ___   _ _ __  "
echo "${GREEN} \ \ / /  __) | |   / _` / __/ __/ ]  _/  / _` |/ __| |/ / | | | '_ \ "
echo "${GREEN}  \ V /  / __/| |__| (_| \__ \ |_  ] |_) | (_| | (__|   <| |_| | |_) |"
echo "${GREEN}   \_/  |_____|_____\__,_|___/\__| |____/ \__,_|\___|_|\_/___,_| .__/ "
echo "                                                               |_|    "                                                               
echo ""                                                                                                                              
echo ""
echo ""
sleep 3
echo "${RED}RUNNING THIS INSTALL SCRIPT WILL REMOVE YOUR PREVIOUS INSTALLATION OF THE SCRIPT"
read -p "${RED}ARE YOU SURE YOU WANT TO PROCEED? ${GREEN}(y/n): " confirmation

if [[ $confirmation == [Yy] ]]; then
    echo "Confirmed. Proceeding..."
    sleep 3
else
    echo "Aborting installation. Exitting..."
    exit 3
fi

echo "${GREEN}Installing necessary packages..."
apt update && apt upgrade -y
apt install curl -y

read -p "${GREEN}Please enter your Telegram Bot Token: " setup_token
read -p "${GREEN}Please enter your Telegram UserID: " setup_chatid

touch /opt/xray_backup.sh
script='#!/bin/bash

token="$setup_token"
chatid="$setup_chatid"

path_sanaie="/etc/x-ui/"
path_english="/etc/x-ui-english/"

server_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
text_date="$(date +"%Y-%m-%d")"

if [ -d "$path_sanaie" ]; then
    panel_type="Sanaie"
elif [ -d "$path_english" ]; then
    panel_type="English"
else
    exit
fi

if [ "$panel_type" == "Sanaie" ]; then
    curl -X POST -H "content-type: multipart/form-data" -F caption="Server: $server_ip Date: $text_date" -F document=@"$path_english/x-ui.db" -F chat_id=$chatid https://api.telegram.org/bot$token/sendDocument
elif [ "$panel_type" == "English" ]; then
    curl -X POST -H "content-type: multipart/form-data" -F caption="Server: $server_ip Date: $text_date" -F document=@"$path_english/x-ui-english.db" -F chat_id=$chatid https://api.telegram.org/bot$token/sendDocument
else
    exit
fi'
echo "$script" > /opt/xray_backup.sh

echo "${GREEN}Creating crontab rules..."
(crontab -u root -l ; echo "0 12 * * * ./opt/xray_backup.sh") | sort - | uniq - | crontab -

echo "${GREEN}The script is installed successfully."
echo "${GREEN}It will send you the backup files to you via Telegram at 12:00 PM every day."