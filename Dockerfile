FROM ubuntu:noble

# Standard libs / programs
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update

RUN apt install -y zsh curl git make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev apt-file dnsutils gdb cmake \
python3-pip nmap ncat libimage-exiftool-perl binwalk pngcheck vim \
libc6-dev-i386 libpq-dev libpcap-dev libxslt-dev whois groff-base jq wireguard \
zip python3-dev virtualenvwrapper man tmux iputils-ping socat iproute2 strace ltrace libgmp3-dev \
libmpc-dev php gdbserver nasm smbclient

# Add mirror files for quicker updating later
ADD ./files/sources.list /etc/apt/sources.list

# Install ZSH
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Set Environment Variables
ENV LC_CTYPE=C.UTF-8
ENV HOME="/root"
ENV SHELL=/bin/zsh
ENV PATH="$HOME/.cargo/bin:$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/share/metasploit-framework:/usr/share/graudit:/usr/local/go/bin:/root/.local/bin/:$PATH"
ENV GOBIN="/usr/local/go/bin"

# Symlink Python etc
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install pwntools
RUN mkdir /root/tools/
RUN virtualenv /root/tools/pwntools
RUN /root/tools/pwntools/bin/pip install pwntools

# Install golang
RUN wget -q https://go.dev/dl/go1.26.1.linux-amd64.tar.gz -O /tmp/golang.tar.gz
RUN tar -C /usr/local -xzf /tmp/golang.tar.gz

# Install metasploit
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall

# Install Vim
WORKDIR /root/
RUN git clone --recurse-submodules https://Peleus@bitbucket.org/Peleus/vim.git
RUN /root/vim/restore.sh
RUN rm -rf /root/vim/ 

# Configure Tmux
ADD ./files/tmux.conf /root/.tmux.conf

# Set PTrace to 0
RUN sed -i 's/1/0/g' /etc/sysctl.d/10-ptrace.conf

# Install GEF
RUN bash -c "$(wget https://gef.blah.cat/sh -O -)"

# Install Claude
RUN curl -fsSL https://claude.ai/install.sh | bash

# Move over the zshrc
ADD ./files/zshrc.conf /root/.zshrc

# Clobber claude folder so our mount version can take over
RUN rm -rf /root/.claude/
RUN rm /root/.claude.json