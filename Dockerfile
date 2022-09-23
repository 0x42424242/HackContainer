FROM ubuntu:focal

# Standard libs / programs
ENV DEBIAN_FRONTEND noninteractive
ADD ./files/sources.list /etc/apt/sources.list
RUN dpkg --add-architecture i386
RUN apt update

RUN apt install -y zsh curl git make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl apt-file dnsutils gdb cmake \
python3.8-dev python3-pip nmap ncat libimage-exiftool-perl binwalk pngcheck vim \
libc6-dev-i386 libpq-dev libsqlite-dev libpcap-dev libxslt-dev whois groff-base jq wireguard \
zip python3-dev virtualenvwrapper man tmux iputils-ping socat iproute2 strace ltrace libgmp3-dev \
awscli libmpc-dev php

# Install ZSH
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Set Environment Variables
ENV LC_CTYPE=C.UTF-8
ENV HOME="/root"
ENV SHELL=/bin/zsh
ENV PATH="$HOME/.cargo/bin:$HOME/.rbenv/shims:$HOME/.rbenv/bin:/usr/share/metasploit-framework:/usr/share/graudit:/usr/local/go/bin:$PATH"
ENV GOBIN="/usr/local/go/bin"

# Install pwntools
RUN pip3 install ropper keystone-engine capstone ortools pandas unicorn==1.0.2rc3
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pwntools

# Symlink Python etc
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install golang
RUN wget -q https://dl.google.com/go/go1.15.linux-amd64.tar.gz -O /tmp/golang.tar.gz
RUN tar -C /usr/local -xzf /tmp/golang.tar.gz

# Install rbenv & ruby
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN cd ~/.rbenv && src/configure && make -C src
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
RUN rbenv install 3.0.2
RUN rbenv global 3.0.2

# Install metasploit
WORKDIR /usr/share/
RUN git clone https://github.com/rapid7/metasploit-framework.git
WORKDIR /usr/share/metasploit-framework/
RUN gem install bundler
RUN bundle install

# Install SQLMap
WORKDIR /usr/share/
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap

# Install graudit
WORKDIR /usr/share/
RUN git clone https://github.com/wireghoul/graudit.git

# Install rust scan
WORKDIR /root/
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
WORKDIR /usr/share/
RUN git clone https://github.com/brandonskerritt/RustScan.git
WORKDIR /usr/share/RustScan/
RUN cargo build --release
RUN ln -s /usr/share/RustScan/target/release/rustscan /usr/bin/rustscan

# Install Ffuf
WORKDIR /root/
RUN git clone https://github.com/ffuf/ffuf.git
WORKDIR /root/ffuf/
RUN go build
RUN mv /root/ffuf/ffuf /usr/bin/ffuf
WORKDIR /root/
RUN rm -rf /root/ffuf/
RUN rm -rf /root/go

# Install Vim
WORKDIR /root/
RUN git clone --recurse-submodules https://Peleus@bitbucket.org/Peleus/vim.git
RUN /root/vim/restore.sh
RUN rm -rf /root/vim/ 

# Install Wordlists
RUN mkdir /usr/wordlists/
WORKDIR /usr/wordlists/
RUN git clone https://github.com/danielmiessler/SecLists.git
WORKDIR /usr/wordlists/SecLists/
RUN git config --add oh-my-zsh.hide-status 1
RUN git config --add oh-my-zsh.hide-dirty 1
WORKDIR /root/

# Install Unfurl
RUN go get -u github.com/tomnomnom/unfurl
RUN rm -rf /root/go/

# Configure Tmux
ADD ./files/tmux.conf /root/.tmux.conf

# Move over the zshrc
ADD ./files/zshrc.conf /root/.zshrc

# Set PTrace to 0
RUN sed -i 's/1/0/g' /etc/sysctl.d/10-ptrace.conf

# Install GEF
RUN bash -c "$(wget https://gef.blah.cat/sh -O -)"