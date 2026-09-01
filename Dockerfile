FROM debian

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt update && \
    apt install -y curl sudo nano ca-certificates zsh git openssh-server gcc g++ gdb tzdata wget iputils-ping net-tools iproute2 dnsutils mtr-tiny jq htop tree locales && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && \
    mkdir -p /run/sshd && \
    ssh-keygen -A && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    groupadd --gid 1000 bestrui && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/zsh bestrui && \
    echo 'bestrui:bestrui' | chpasswd && \
    usermod -aG sudo bestrui && \
    echo 'bestrui ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER bestrui
WORKDIR /home/bestrui

RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
    curl -fsSL https://github.com/bestruirui.keys -o ~/.ssh/authorized_keys && \
    chmod 600 ~/.ssh/authorized_keys && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions && \
    curl https://mise.run | sh && \
    ~/.local/bin/mise use --global node go python && \
    case "$(dpkg --print-architecture)" in \
        amd64) curl -fsSL https://github.com/sigoden/dufs/releases/download/v0.46.0/dufs-v0.46.0-x86_64-unknown-linux-musl.tar.gz | tar -xzf - -C ~/.local/bin dufs ;; \
        arm64) curl -fsSL https://github.com/sigoden/dufs/releases/download/v0.46.0/dufs-v0.46.0-aarch64-unknown-linux-musl.tar.gz | tar -xzf - -C ~/.local/bin dufs ;; \
        *) echo "Unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac

COPY --chown=1000:1000 .zshrc /home/bestrui/.zshrc

EXPOSE 2222
CMD ["sudo", "/usr/sbin/sshd", "-D"]
