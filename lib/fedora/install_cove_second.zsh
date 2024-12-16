export SHELL=$(which zsh)

# Hook direnv into oh-my-zsh
# First, find the line where the plugins are defined
line=$(grep -n "^\S*plugins=(" ~/.zshrc | cut -d: -f1)
# Then, add direnv to the list of plugins
sed -i "${line}s/)/ direnv)/" ~/.zshrc
# Finally, source the .zshrc file
source ~/.zshrc

# Python build dependencies
sudo dnf install -y make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2
# Install pyenv
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.nvm/nvm.sh

source ~/.zshrc

# Copy the ssh keys from the same folder as this script to the user's .ssh folder
mkdir -p ~/.ssh
cp id_ed25519 ~/.ssh/id_ed25519
cp id_ed25519.pub ~/.ssh/id_ed25519.pub

# Import the gnupg keys
gpg --import key.gpg

# Set the permissions of the ssh keys
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add the ssh key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy the direnvrc file
cp direnvrc ~/.direnvrc

# Install AWS CLI
sudo dnf install -y awscli2
# Create the AWS config folder
mkdir -p ~/.aws

# # Clone cove repositories
mkdir -p ~/src

INSTALL_FOLDER=$(pwd)

# Set up the script shortcuts
cd ~/src
git clone git@github.com:covetool/cove_dev_scripts.git --recursive
mkdir -p ~/.zsh/
cd ~/.zsh/
ln -s ~/src/cove_dev_scripts/docker-cove.zsh
echo "function load_file {" >> ~/.zshrc
echo "    [ -e ~/.zsh/${1} ] && . ~/.zsh/${1} || true" >> ~/.zshrc
echo "    [ -e ~/.zsh.local/${1} ] && . ~/.zsh.local/${1} || true" >> ~/.zshrc
echo "}" >> ~/.zshrc
echo "load_file "docker-cove.zsh"" >> ~/.zshrc

# Set up the openstudio environment
cd ~/src
git clone git@github.com:covetool/ct_openstudio.git --recursive
# Copy the openstudio_envrc.sh file to the ct_openstudio repository
cp $INSTALL_FOLDER/openstudio_envrc.sh ~/src/ct_openstudio/.envrc
cd ~/src/ct_openstudio
direnv allow
eval "$(direnv export zsh)"

# Build the docker image
cd openstudio
export CT_UNITS_GIT_COMMIT=$(git ls-remote https://$GITHUB_PAT_TOKEN@github.com/covetool/ct_units.git | head -1 | sed "s/HEAD//")
docker build -t open_studio \
    --build-arg BUILDKIT_DOCKERFILE_CHECK=skip=SecretsUsedInArgOrEnv \
    --build-arg CT_UNITS_GIT_COMMIT=$CT_UNITS_GIT_COMMIT \
    --build-arg GITHUB_PAT_TOKEN=$GITHUB_PAT_TOKEN .

# Setup the node environment
cd ~/src
git clone git@github.com:covetool/ct_node.git --recursive
# Install the node version from the node_envrc.sh file
nvm install $(grep "use node" $INSTALL_FOLDER/node_envrc.sh | cut -d' ' -f3)
# Copy the node_envrc.sh file to the ct_node repository
cp $INSTALL_FOLDER/node_envrc.sh ~/src/ct_node/.envrc
cd ~/src/ct_node
direnv allow
eval "$(direnv export zsh)"
# Set the token for the registries
npm set '//registry.npmjs.org/:_authToken' "${NPM_TOKEN}"
npm set "//covetool.com/:_authToken=$NPM_TOKEN"
# Install the dependencies
cd node
npm install

# Set up the chatbot-integration Python environment
cd ~/src
git clone git@github.com:covetool/chatbot-integration.git --recursive
# Get and install the python version from the chatbot_envrc.sh file
pyenv install $(grep "use python" $INSTALL_FOLDER/chatbot_envrc.sh | cut -d' ' -f3)
# Copy the chatbot_envrc.sh file to the chatbot-integration repository
cp $INSTALL_FOLDER/chatbot_envrc.sh ~/src/chatbot-integration/.envrc
cd ~/src/chatbot-integration
direnv allow
eval "$(direnv export zsh)"
# Install the python dependencies
pip install -r src/requirements.txt
# Install development libraries
pip install black isort pip-tools
# Pre-create the dynamodb folder
mkdir -p docker/dynamodb
# Build the docker image
cd src
docker build -t cove_chatbot .

# Pull the ct_units Python repository
cd ~/src
git clone git@github.com:covetool/ct_units.git

# Set up the cove Python environment
cd ~/src
git clone git@github.com:covetool/cove.git --recursive
# Install the dependencies for python dependencies
sudo dnf install -y libcurl libpq-devel
# Get and install the python version from the cove_envrc.sh file
pyenv install $(grep "use python" $INSTALL_FOLDER/cove_envrc.sh | cut -d' ' -f3)
# Copy the cove direnv file to the cove repository
cp $INSTALL_FOLDER/cove_envrc.sh ~/src/cove/.envrc
cd ~/src/cove
direnv allow
eval "$(direnv export zsh)"
# Install the python dependencies
pip install -r web/requirements.txt
# Install development libraries
pip install darker isort pip-tools
# Install ct_units
pip install -e ~/src/ct_units
# Copy AWS config
mkdir -p ~/.aws
touch ~/.aws/config
echo "[cove]" > ~/.aws/config
echo "region = $AWS_DEFAULT_REGION" >> ~/.aws/config
# Copy AWS credentials
touch ~/.aws/credentials
echo "[cove]" > ~/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
# Build the docker image
cd web
export CT_UNITS_GIT_COMMIT=$(git ls-remote https://$GITHUB_PAT_TOKEN@github.com/covetool/ct_units.git | head -1 | sed "s/HEAD//")
docker build -t cove_web \
    --build-arg BUILDKIT_DOCKERFILE_CHECK=skip=SecretsUsedInArgOrEnv \
    --build-arg CT_UNITS_GIT_COMMIT=$CT_UNITS_GIT_COMMIT \
    --build-arg GITHUB_PAT_TOKEN=$GITHUB_PAT_TOKEN .
