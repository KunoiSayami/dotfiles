#!/bin/bash
REMOTE_URL=$1
ORIGINAL_URL="https://raw.githubusercontent.com/KunoiSayami/dotfiles/master/.bashrc"

failed_function() {
    if [ $? -ne 0 ]; then
        echo $1
        exit 1
    fi
}

if [ -r ~/.bashrc ]; then
    BACKUP_FILE_NAME=".bashrc$(date +_%Y%m%d_%H%M%S)"
    echo "Backup .bashrc to $BACKUP_FILE_NAME"
    cp ~/.bashrc ~/$BACKUP_FILE_NAME
fi

failed_function "Backup file failed, abort script"

if [ -z ${REMOTE_URL+x} ]; then
    echo "use specify url $REMOTE_URL"
    curl -fsSL -o ~/.bashrc $REMOTE_URL
else
    curl -fsSL -o ~/.bashrc $ORIGINAL_URL
fi

failed_function "Download file failed, abort script"

if [ -z ${NOT_VPS+x} ]; then
    sed -i 's/DISABLE_AGENTS/#DISABLE_AGENTS/g' ~/.bashrc
fi

COUNTRY_CODE=$(curl --noproxy '*' -fsSL https://api.ip.sb/geoip | sed  's/,/\n/g' | sed 's/"//g' | grep country_code | cut -d':' -f2)

if [ $? -ne 0 ]; then
    echo "Check country code failed, please comment RUSTUP mirror section if you are not in Mainland China"
else
    if [ ! -z $COUNTRY_CODE ] && [ $COUNTRY_CODE != "CN" ]; then
        sed -i 's/export RUSTUP/#export RUSTUP/g' ~/.bashrc
    fi
fi

echo "Try use \`source ~/.bashrc' to enjoy your new bashrc file"
