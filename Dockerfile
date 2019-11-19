FROM debian:latest

RUN printf "deb http://ftp.au.debian.org/debian/ buster main contrib non-free\ndeb-src http://ftp.au.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list

RUN dpkg --add-architecture i386

RUN apt update

RUN apt install -y zsh curl git make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl apt-file dnsutils gdb cmake \
python3.7-dev python3-pip nmap ncat libimage-exiftool-perl binwalk pngcheck vim \
libc6-dev-i386 libpq-dev libsqlite-dev libpcap-dev libxslt-dev

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

RUN apt-file update

ENV HOME="/root"

ENV LC_CTYPE=C.UTF-8

ENV SHELL=/bin/zsh

RUN pip3 install unicorn ropper keystone-engine capstone

RUN pip3 install git+https://github.com/arthaud/python3-pwntools.git

RUN cp /usr/local/lib/python3.7/dist-packages/usr/lib/python3/dist-packages/keystone/* /usr/local/lib/python3.7/dist-packages/keystone/

RUN wget -q -O- https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

RUN cd ~/.rbenv && src/configure && make -C src

ENV PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$HOME/metasploit-framework:$PATH"

RUN mkdir -p "$(rbenv root)"/plugins

RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

RUN rbenv install 2.6.5

RUN rbenv global 2.6.5

WORKDIR /root/

RUN git clone https://github.com/rapid7/metasploit-framework.git

WORKDIR /root/metasploit-framework/

RUN gem install bundler

RUN bundle install