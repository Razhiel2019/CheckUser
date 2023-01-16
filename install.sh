url="https://github.com/Razhiel2019/CheckUser"

cd ~

if ! [ -x "$(command -v git)" ]; then
    echo
    echo -e "\e[32m >>>>>>>>>>>>><<<<<<<<<<<<\e[0m"
    echo " Error: Git no esta instalado." >&2
    echo -e "\e[32m >>>>>>>>>>>>><<<<<<<<<<<<\e[0m"
    echo
    echo " Instalando Git..."
    sudo apt-get install git -y 1>/dev/null 2>/dev/null
    echo 
    echo " Git instalado con Exito."

    if ! [ -x "$(command -v git)" ]; then
        echo -e "\e[32m >>>>>>>>>>>>><<<<<<<<<<<<\e[0m"
        echo " Error: Git no esta instalado." >&2
        echo -e "\e[32m >>>>>>>>>>>>><<<<<<<<<<<<\e[0m"
        exit 1
    fi
fi

function install_checkuser() {
    echo " Instalando CheckUser..."
    git clone $url
    cd CheckUser

    python3 setup.py install

    if ! [ -x "$(command -v checkuser)" ]; then
        echo " Error: CheckUser no esta instalado." >&2
        #exit 1
        sleep 1
    fi

    clear
    echo
    read -p " Elige Puerta (5000 default): " -e -i 5000 port
    checkuser --config-port $port --create-service
    service check_user start

    echo " CheckUser instalado con Exito."
    echo " Execute: checkuser --help"
    echo " URL: http://"$(curl -s icanhazip.com)":"$port
    sleep 1
}

function check_update() {
    if ! [ -d CheckUser ]; then
        echo " CheckUser no esta instalado."
        return 1
    fi

    echo " Verificando atualizaciones..."
    cd CheckUser

    git fetch --all
    git reset --hard origin/master
    git pull origin master

    python3 setup.py install
    echo " CheckUser actualizado con Exito."
    read
}

function uninstall_checkuser() {
    echo " Desinstalando CheckUser..."

    [[ -d CheckUser ]] && rm -rf CheckUser

    [[ -f /usr/bin/checker ]] && {
        service check_user stop
        /usr/bin/checker --uninstall
        rm /usr/bin/checker
    }

    [[ -f /usr/local/bin/checkuser ]] && {
        service check_user stop
        /usr/local/bin/checkuser --remove-service
        rm /usr/local/bin/checkuser
    }
}

function console_menu() {
    tput clear
    [[ $(ps x | grep -w checkuser | grep -v grep) ]] && chk="\033[1;32m◉" || chk="\033[1;31m○"
    echo
    echo -e "\e[32m >>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<\e[0m"
    echo -e "\e[32m >>>\e[1;49;97m     CHECKUSER MENU    \e[0m\e[32m<<<\e[0m"
    echo -e "\e[32m >>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<\e[0m"
    echo -e "\e[1;33m URL: http://"$(wget -qO- ipv4.icanhazip.com)":"$port
    echo
    echo -e "\e[1;97m S T A T U S : $chk \e[0m"
    echo -e "\e[32m >>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<\e[0m"
    echo -e "\e[31m [01] - \e[1;49;97mInstalar CheckUser\e[0m"
    echo -e "\e[31m [02] - \e[1;49;97mActualizar CheckUser\e[0m"
    echo -e "\e[31m [03] - \e[1;49;97mDesinstalar CheckUser\e[0m"
    echo -e "\e[32m >>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<\e[0m"
    echo -e "\e[31m [00] - \e[1;33m Salir\e[0m"
    echo -e "\e[32m >>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<\e[0m"
    read -p " Escoge una opción: " option

    case $option in
    01 | 1)
        install_checkuser
        console_menu
        ;;
    02 | 2)
        check_update
        console_menu
        ;;
    03 | 3)
        uninstall_checkuser
        console_menu
        ;;
    00 | 0)
        echo " Salindo..."
        exit 0
        ;;
    *)
        echo " Opción inválida."
        read -p " Presione enter para continuar..."
        console_menu
        ;;
    esac

}

function main() {
    case $1 in
    install)
        install_checkuser
        ;;
    update)
        check_update
        ;;
    uninstall)
        uninstall_checkuser
        ;;
    *)
        echo "Usage: ./install.sh [install|update|uninstall]"
        exit 1
        ;;
    esac
}

if [[ $# -eq 0 ]]; then
    console_menu
else
    main $1
fi
