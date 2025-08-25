FROM debian:trixie-slim

# Install basic dependencies and tools
RUN apt-get update && apt-get install -y \
    curl \    
    sudo \    
    ca-certificates \
    locales \
    fish \
    starship \
    mariadb-server \
    mariadb-client \
    wget \    
    && rm -rf /var/lib/apt/lists/*

# Generate locale for en_GB.UTF-8
RUN sed -i '/en_GB.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_GB.UTF-8
ENV LANGUAGE=en_GB:en
ENV LC_ALL=en_GB.UTF-8

# Configure MariaDB
RUN mkdir -p /var/run/mysqld \
    && chown mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# Initialize MariaDB data directory
RUN mysql_install_db --user=mysql --ldata=/var/lib/mysql --auth-root-authentication-method=normal

# Create non-root user with fish as default shell
ARG CONTAINER_USER
ARG DEV_PASSWORD
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $CONTAINER_USER \
    && useradd --uid $USER_UID --gid $USER_GID -m $CONTAINER_USER -s /usr/bin/fish \
    && echo $CONTAINER_USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$CONTAINER_USER \
    && chmod 0440 /etc/sudoers.d/$CONTAINER_USER \
    && usermod -aG mysql $CONTAINER_USER \
    && mkdir -p /home/$CONTAINER_USER/.vscode-server/extensions \
    && mkdir -p /home/$CONTAINER_USER/.vscode-server/bin \
    && mkdir -p /home/$CONTAINER_USER/.vscode-server/data/Machine \
    && chown -R $CONTAINER_USER:$USER_GID /home/$CONTAINER_USER

USER $CONTAINER_USER
WORKDIR /home/$CONTAINER_USER

# Install MoonBit via official installer
RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# Install Nix package manager
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon \
    && . $HOME/.nix-profile/etc/profile.d/nix.sh 

# Enable experimental features for flakes
RUN mkdir -p $HOME/.config/nix && \
    echo "experimental-features = nix-command flakes" >> $HOME/.config/nix/nix.conf    

ENV PATH="/home/$CONTAINER_USER/.nix-profile/bin:/home/$CONTAINER_USER/.moon/bin:${PATH}"

# Install direnv via Nix
RUN nix-env -iA nixpkgs.direnv

# Create Fish config directories
RUN mkdir -p $HOME/.config/fish/conf.d \
    && mkdir -p $HOME/.config/direnv

# Copy Fish configuration files
COPY --chown=${CONTAINER_USER}:${USER_GID} fish/conf.d/*.fish /home/${CONTAINER_USER}/.config/fish/conf.d/
COPY --chown=${CONTAINER_USER}:${USER_GID} fish/config.fish /home/${CONTAINER_USER}/.config/fish/config.fish

# Copy MariaDB initialization script
COPY --chown=${CONTAINER_USER}:${USER_GID} init-mariadb.sh /home/${CONTAINER_USER}/init-mariadb.sh
RUN chmod +x /home/${CONTAINER_USER}/init-mariadb.sh

ENV SHELL="/usr/bin/fish"

# Verify MoonBit installation
RUN fish -c "moon version" || true