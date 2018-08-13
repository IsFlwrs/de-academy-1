#! /bin/bash

# Install the GCloud SDK if it is not already installed and set it up to start working on DE Academy
source colored_output.sh

PROJECT_NAME="data-castle-bravo"
ZONE="us-central1-a"
PLATFORM_NAME="linux-x86_64.tar.gz"
OS_NUMBER=1

_main() {
    GCLOUD_INSTALLED=`command -v gcloud`
    if [ -z "$GCLOUD_INSTALLED" ]; then
        _install_gcloud
    else
        echo "${WARNING}A previous installation of the GCloud SDK has been detected.${RESET}"
        echo "If you run into an issue in the next steps, please be sure to update to the latest components and run this installer again."
        sleep 5
    fi

    _setup_gcloud_project

    echo "${SUCCESS}We've successfully set up the GCloud SDK and environment on your machine.${RESET}"
    echo "${INFO}To be able to invoke gcloud commands, please restart your terminal.${RESET}"
}

_install_gcloud() {
    while true; do
        read -p "${INFO}The GCloud SDK is about to get installed on your machine. Do you wish to proceed [y/n]? ${RESET}" answer
        case $answer in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    _download_gcloud_sdk

    echo
    echo "${INFO}About to start installation. Please follow the instructions...${RESET}"
    sleep 3

    if [ $OS_NUMBER -lt 5 ]
    then
        ./google-cloud-sdk/install.sh
    else
        .\google-cloud-sdk\install.bat
    fi
}

_setup_gcloud_project() {
    if [ -f './google-cloud-sdk/path.bash.inc' ]; then source './google-cloud-sdk/path.bash.inc'; fi

    echo "${INFO}We're about to create a configuration for DE Academy. You'll be asked for your Google credentials...${RESET}"
    sleep 2

    gcloud config configurations create de-training-configuration
    gcloud auth login
    gcloud config set project $PROJECT_NAME
    gcloud config set compute/zone $ZONE
}

_download_gcloud_sdk() {
    echo
    echo "${INFO}Select the operating system you have in your computer:${RESET}
1) Linux 64-bit (x86_64)
2) Linux 32-bit (x86)
3) Mac OS X 64-bit (x86_64)
4) Mac OS X 32-bit (x86)
5) Windows 64-bit (x86_64)
6) Windows 64-bit (x86_64) with Python bundled
7) Windows 32-bit (x86)
8) Windows 32-bit (x86) with Python bundled
"

    read OS_NUMBER
    echo

    case $OS_NUMBER in
        1) PLATFORM_NAME=linux-x86_64.tar.gz;;
        2) PLATFORM_NAME=linux-x86.tar.gz;;
        3) PLATFORM_NAME=darwin-x86_64.tar.gz;;
        4) PLATFORM_NAME=darwin-x86.tar.gz;;
        5) PLATFORM_NAME=windows-x86_64.zip;;
        6) PLATFORM_NAME=windows-x86_64-bundled-python.zip;;
        7) PLATFORM_NAME=windows-x86.zip;;
        8) PLATFORM_NAME=windows-x86-bundled-python.zip;;
    esac

    echo "${INFO}Downloading SDK...${RESET}"
    sleep 2

    TAR_NAME=google-cloud-sdk-210.0.0-$PLATFORM_NAME
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$TAR_NAME

    if [ $OS_NUMBER -lt 5 ]
    then
        tar -xvzf $TAR_NAME
    else
        unzip $TAR_NAME
    fi
    rm $TAR_NAME
}

_main
