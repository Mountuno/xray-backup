if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with root privileges. Please run it as root or using sudo -l."
    exit 1
fi

echo "Xray Backup Helper - Install Script"
sleep 3
echo "RUNNING THIS WILL REMOVE YOUR PREVIOUS INSTALLATION OF THE SCRIPT"
read -p "ARE YOU SURE YOU WANT TO PROCEED? (y/n): " confirmation

if [[ $confirmation == [Yy] ]]; then
    echo "CONFIRMED. Proceeding..."
    rm -rf /opt/xray_backup.sh
    sleep 3
else
    echo "ABORTING INSTALLATION. Exitting..."
    exit 3
fi

echo "Installing necessary packages..."
apt update && apt upgrade -y
apt install curl -y

read -p "Please enter your Telegram Bot Token: " setup_token
read -p "Please enter your Telegram UserID: " setup_chatid

touch /opt/xray_backup.sh
script='#!/bin/bash

token="'$setup_token'"
chatid="'$setup_chatid'"

path_sanaie="/etc/x-ui/"
path_english="/etc/x-ui-english/"

server_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
text_date="$(TZ=Asia/Tehran date +"%D %T")"

if [ -d "$path_sanaie" ]; then
    panel_type="Sanaie"
elif [ -d "$path_english" ]; then
    panel_type="English"
else
    exit
fi

if [ "$panel_type" == "Sanaie" ]; then
    text="Date: $text_date - Panel Type: $panel_type - Server: $server_ip"
    # url="$(printf %s "$text" | jq -s -R -r @uri)"
    curl -X POST -H "content-type: multipart/form-data" -F caption="$text" -F document=@"$path_sanaie/x-ui.db" -F chat_id=$chatid https://api.telegram.org/bot$token/sendDocument
elif [ "$panel_type" == "English" ]; then
    text="Date: $text_date - Panel Type: $panel_type - Server: $server_ip"
    # url="$(printf %s "$text" | jq -s -R -r @uri)"
    curl -X POST -H "content-type: multipart/form-data" -F caption="$text" -F document=@"$path_english/x-ui-english.db" -F chat_id=$chatid https://api.telegram.org/bot$token/sendDocument
else
    exit
fi'
echo "$script" > /opt/xray_backup.sh
chmod +x /opt/xray-backup.sh

echo "Creating crontab rules..."
(crontab -u root -l ; echo "@hourly bash /opt/xray_backup.sh") | sort - | uniq - | crontab -

echo "The script is installed successfully."
echo "It will send you the backup files to you via Telegram every hour."
