sudo systemctl daemon-reload

# Remove old versions of Docker
sudo dnf remove docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

# Install required packages to add the Docker repository
sudo dnf -y install dnf-plugins-core

# Add the Docker repository
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker and enable it on boot
sudo systemctl enable --now docker

# Set up non-root docker
sudo usermod -aG docker $USER

# Install direnv, zsh, curl and pip
sudo apt -y install direnv zsh curl python3-pip

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set zsh as the default shell
sudo usermod -s $(which zsh) $USER

# Switch to zsh, running it with docker newgrp
newgrp docker << END
zsh ./install_cove_second.zsh
END
