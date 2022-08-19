#!/usr/bin/env bash

###################################################################
# @Time    : 08/01/2022 4:00 PM
# @Author  : iopssre
# @File    : dockere-env.sh
# @github  : https://github.com/iopssre
# @Role    : install docker running environment
# @Version : 0.1
###################################################################

echo -ne "\\033[0;33m"
cat<<EOT
                                  _oo0oo_
                                 088888880
                                 88" . "88
                                 (| -_- |)
                                  0\\ = /0
                               ___/'---'\\___
                             .' \\\\\\\\|     |// '.
                            / \\\\\\\\|||  :  |||// \\\\
                           /_ ||||| -:- |||||- \\\\
                          |   | \\\\\\\\\\\\  -  /// |   |
                          | \\_|  ''\\---/''  |_/ |
                          \\  .-\\__  '-'  __/-.  /
                        ___'. .'  /--.--\\  '. .'___
                     ."" '<  '.___\\_<|>_/___.' >'  "".
                    | | : '-  \\'.;'\\ _ /';.'/ - ' : | |
                    \\  \\ '_.   \\_ __\\ /__ _/   .-' /  /
                ====='-.____'.___ \\_____/___.-'____.-'=====
                                  '=---='
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                Script    Uses        install docker running environment
                Recommend OS          Ubuntu 20.04 TLS
                Support   Team        Move Chinese Community
                Move      Discord     https://discord.gg/D7R2TtmkTm
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

EOT
echo -ne "\\033[m"

# usage note
function usage() {
    cat <<END

    usage: $0 OPTIONS

    This script use install docker running environment.

    OPTIONS:
    install    Install docker and docker compose
END
}


# check os version
function check_os_version() {
    echo -e "\033[32m [INFO]: Check OS Version \033[0m"
    version=$(grep "^PRETTY_NAME" /etc/os-release)
    case $version in
        *Ubuntu*)
            echo -e "\033[32m [INFO]: Ubuntu is Support \033[0m"
            ;;
        *)
            echo -e "\033[32m [INFO]: OS is not Support \033[0m"
            exit 1
        ;;
    esac
}

# get docker-compose release
function get_docker_compose_release() {
    curl --silent "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

# install docker
function install_docker() {
    echo -e "\033[32m [INFO]: Start install docker \033[0m"
    # remove old package
    sudo apt remove --yes docker docker-engine docker.io containerd runc || true
    # config gpg key
    if [ ! -d /etc/apt/keyrings ]
    then
        sudo mkdir -p /etc/apt/keyrings
    fi

    if [ ! -f /etc/apt/keyrings/docker.gpg ]
    then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi
    # seting repo
    if [ ! -f /etc/apt/sources.list.d/docker.list ]
    then
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    # install docker
    if [ ! -x "$(command -v docker)" ]
    then
        sudo apt update && sudo apt install --yes docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi
}

# install docker-compose
function install_docker_compose() {
    echo -e "\033[32m [INFO]: Start install docker-compose \033[0m"
    # install docker-compose
    if [ ! -x "$(command -v docker-compose)" ]
    then
        sudo curl -L https://github.com/docker/compose/releases/download/$(get_docker_compose_release)/docker-compose-$(uname -s)-$(uname -m) \
        -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
    fi
    
}

export -f install_docker
export -f install_docker_compose

# start install
case $1 in
    install)
        check_os_version

        # install dependency packages
        echo -e "\033[32m [INFO]: Install the base dependencies, here apt update will be time consuming \033[0m"
        sudo apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC \
            && apt-get install -y --no-install-recommends \
            tzdata git ca-certificates curl build-essential libssl-dev  pkg-config libclang-dev cmake jq

        [ -x "$(command -v docker)" ] && echo -e "\033[33m [Warning]: Docker already exists,Skip installation \033[0m"  || install_docker
        [ -x "$(command -v docker-compose)" ] && echo -e "\033[33m [Warning]: Docker-compose already exists,Skip installation \033[0m"  || install_docker_compose
    ;;
    *)
        usage
    ;;
esac
