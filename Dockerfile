FROM debian:buster-slim
ENV VERSION 2.9.20

RUN mkdir -p /root/pcaps/
COPY labs /root/
COPY tools /root/
WORKDIR /root/src/



RUN  apt-get update 
RUN  apt-get -y install \
  build-essential \
  vim \
  curl \
  gcc \
  flex \
  bison \
  wget \
  iputils-ping \
  iproute2 \
  net-tools \
  dnsutils \
  nmap \
  lsof \
  procps \
  tcpdump \
  nano \
  pkg-config

RUN  apt-get -y install \
  libpcap0.8 \
  libpcap0.8-dev \
  libpcre3 \
  libpcre3-dev \
  libdumbnet1 \
  libdumbnet-dev \
  libdaq2 \
  libdaq-dev

RUN  apt-get -y install \
  zlib1g \
  zlib1g-dev \
  liblzma5 \
  liblzma-dev \
  luajit \
  libluajit-5.1-dev \
  libssl1.1 \
  libssl-dev \
  tcpreplay && \
  apt-get clean
  
RUN curl -L -O https://snort.org/downloads/snort/snort-$VERSION.tar.gz && \
  tar xf ./snort-$VERSION.tar.gz && \
  cd ./snort-$VERSION && \
  ./configure --enable-sourcefire --enable-open-appid && \
  make -j$(nproc) && \
  make install && \
  ldconfig && \
  cd /root && \
  rm -rf /root/src && \
  touch /root/pcaps/local.rules && \
  echo 'export TERM=xterm-256color' >> ~/.bashrc

# rule syntax file
COPY include/hog.vim /root/.vim/syntax/hog.vim
# colorscheme
COPY include/ir_black.vim /root/.vim/colors/ir_black.vim
# vimrc
COPY include/vimrc /root/.vimrc

RUN <<EOF
apt-get -y install gnupg
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update && apt-get install filebeat
update-rc.d filebeat defaults
update-rc.d filebeat enable
filebeat modules enable snort
filebeat setup
/etc/init.d/filebeat start
EOF


CMD /bin/bash
