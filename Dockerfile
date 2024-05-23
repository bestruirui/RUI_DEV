# 使用官方的Debian镜像作为基础镜像
FROM debian

ENV GO_VERSION 1.22.3
ENV PATH=$PATH:/usr/local/go/bin
ENV PATH=$PATH:/root/.pyenv/bin
WORKDIR /workplace
SHELL ["/bin/bash", "-c"] 

RUN apt update && apt install -y nano openssh-server curl wget git gcc g++ make cmake liblzma-dev libnss3-dev zlib1g-dev libgdbm-dev libncurses5-dev   libssl-dev libffi-dev libreadline-dev libsqlite3-dev libbz2-dev && apt clean && rm -rf /var/lib/apt/lists/*

# GO
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash &&\
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" &&\
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install 18 && nvm install 20  && nvm use 20 && \
    npm config set registry https://registry.npmmirror.com

# Node
RUN curl -LO https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz && \
    rm -rf /usr/local/go &&\
    tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz && rm -rf go$GO_VERSION.linux-amd64.tar.gz &&\
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Python
RUN curl https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc &&\
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc &&\
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc &&\
    source ~/.bashrc && \
    pyenv install 3.9 &&\
    pyenv local 3.9 &&\
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple 

RUN mkdir /var/run/sshd && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config &&\
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config &&\
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBtmBBUuFyYNFB3OXjdfmwj5SmyzCQFEykHKX61q8sczdkhA+ZDgYM+OuNfgvfqUbOo0/qkt1gLK45qX4Ex2x02uM6NasPmA8mT7Tj3IygHWzTxQgmgD1P2c9DLs+MOa7vqLvjHWg54YdKmshrf7GXCsy2SNIs3i2Q9C1H5y3uAc2EgG3X7mUdpjMVwfytvEzfxEJSZTIJ3FeO2ImB3YPPiVys7/ZP3AaNQMXnlhA/kRfpFfg9QYoW4koAkY99N4tcIBHRvA+AX9MiCfLNVqz5KiOef8nxAlESIpE2whTsHp3uXJCw9sqUkU49dH4geFk3ozDHSEU6qhv3qUYl7gThaeTxSKF6+Z9rwlGxtifezO6G0QMpCvPNuilVKhEtAEjOE17Wg68Zq8BFaDGXiajaPzkFBW+xBsC/XcC6FnTaAMPpzrlQ4Ix9CqmC3sob+V4rTqPLKY8V9Vb89YmDm7E5Cs3pShBp11EMN+GwANG4eXpRXal8kFkZThZN4xdgpJk= xiaor@bestrui' > /root/.ssh/authorized_keys &&\
    echo 'export LS_OPTIONS="--color=auto"' >> /root/.bashrc &&\
    echo 'eval "$(dircolors)"' >> /root/.bashrc &&\
    echo 'alias ls="ls $LS_OPTIONS"' >> /root/.bashrc &&\
    echo 'alias ll="ls $LS_OPTIONS -l"' >> /root/.bashrc &&\
    echo 'alias l="ls $LS_OPTIONS -lA"' >> /root/.bashrc &&\
    echo 'parse_git_branch() {' >> /root/.bashrc && \
    echo '    git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/ (\1)/"' >> /root/.bashrc && \
    echo '}' >> /root/.bashrc  &&\
    echo "PS1='\[\033[01;32m\]bestrui\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch) \$ ' ">> /root/.bashrc &&\
    sed -i 's/http:\/\/deb.debian.org\/debian/http:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/' /etc/apt/sources.list.d/debian.sources &&\
    sed -i 's/http:\/\/security.debian.org\/debian/http:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/' /etc/apt/sources.list.d/debian.sources

CMD ["/usr/sbin/sshd", "-D"]