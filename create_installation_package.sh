#!/bin/bash

# Creates an installation package to set up the cove.tool development environment on a new machine.
OUTPUT_DIR=install_cove

# Remove old installation package
rm -rf $OUTPUT_DIR
rm -f install_cove.zipcl

# Copy ssh keys and gpgh keys
mkdir -p $OUTPUT_DIR
cp ~/.ssh/id_ed25519 $OUTPUT_DIR/id_ed25519
cp ~/.ssh/id_ed25519.pub $OUTPUT_DIR/id_ed25519.pub
gpg --output $OUTPUT_DIR/key.gpg --export $(git config user.email)

# Copy the .direnvrc file
cp ~/.direnvrc $OUTPUT_DIR/direnvrc

function direnv_cd() {
    cd "$1"
    if [[ -f .envrc ]]; then
        # Allow the script to use direnv
        direnv allow .
        eval "$(direnv export bash)"
    fi
}


WORK_DIR=$(pwd)
# Create cove_envrc.sh if .envrc don't exist, else use the existing one
direnv_cd ~/src/cove
if [[ ! -f .envrc ]]; then
    bash $WORK_DIR/lib/create_cove_envrc.sh
    mv cove_envrc.sh $WORK_DIR/$OUTPUT_DIR/cove_envrc.sh
else
    cp .envrc $WORK_DIR/$OUTPUT_DIR/cove_envrc.sh
fi

# Create openstudio_envrc.sh if .envrc don't exist, else use the existing one
direnv_cd ~/src/ct_openstudio
if [[ ! -f .envrc ]]; then
    bash $WORK_DIR/lib/create_openstudio_envrc.sh
    mv openstudio_envrc.sh $WORK_DIR/$OUTPUT_DIR/openstudio_envrc.sh
else
    cp .envrc $WORK_DIR/$OUTPUT_DIR/openstudio_envrc.sh
fi

# Create node_envrc.sh if .envrc don't exist, else use the existing one
direnv_cd ~/src/ct_node
if [[ ! -f .envrc ]]; then
    bash $WORK_DIR/lib/create_node_envrc.sh
    mv node_envrc.sh $WORK_DIR/$OUTPUT_DIR/node_envrc.sh
else
    cp .envrc $WORK_DIR/$OUTPUT_DIR/node_envrc.sh
fi

# Create chatbot_envrc.sh if .envrc don't exist, else use the existing one
direnv_cd ~/src/chatbot-integration
if [[ ! -f .envrc ]]; then
    bash $WORK_DIR/lib/create_chatbot_envrc.sh
    mv chatbot_envrc.sh $WORK_DIR/$OUTPUT_DIR/chatbot_envrc.sh
else
    cp .envrc $WORK_DIR/$OUTPUT_DIR/chatbot_envrc.sh
fi

direnv_cd ~/src/automation_testing
# Copy the .as-a.ini file to automation_testing_as_a.ini
cp .as-a.ini $WORK_DIR/$OUTPUT_DIR/automation_testing_as_a.ini
# Create automation_testing_envrc.sh if .envrc don't exist, else use the existing one
if [[ ! -f .envrc ]]; then
    bash $WORK_DIR/lib/create_automation_testing_envrc.sh
    mv automation_testing_envrc.sh $WORK_DIR/$OUTPUT_DIR/automation_testing_envrc.sh
else
    cp .envrc $WORK_DIR/$OUTPUT_DIR/automation_testing_envrc.sh
fi


DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
# Target the distribution from the argument if it is provided,
# otherwise, target the current distribution
TARGET_DISTRO=${1:-$DISTRO}

cd $WORK_DIR

if [[ $TARGET_DISTRO == "ubuntu" ]]; then
    cp $WORK_DIR/lib/ubuntu/install_cove.sh $WORK_DIR/$OUTPUT_DIR/install_cove.sh
    cp $WORK_DIR/lib/ubuntu/install_cove_second.zsh $WORK_DIR/$OUTPUT_DIR/install_cove_second.zsh
elif [[ $TARGET_DISTRO == "fedora" ]]; then
    echo $WORK_DIR/lib/fedora/install_cove.sh
    echo $OUTPUT_DIR/install_cove.sh
    cp $WORK_DIR/lib/fedora/install_cove.sh $WORK_DIR/$OUTPUT_DIR/install_cove.sh
    cp $WORK_DIR/lib/fedora/install_cove_second.zsh $WORK_DIR/$OUTPUT_DIR/install_cove_second.zsh
else
    echo "Unsupported distribution: $DISTRO"
    exit 1
fi

# Zip the installation package
zip -r install_cove.zip $OUTPUT_DIR
