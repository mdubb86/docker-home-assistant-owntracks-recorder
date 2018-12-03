FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
  nginx \
  apache2-utils \
  libcurl3 \
  libcurl4-openssl-dev \
  libconfig-dev \
  liblmdb-dev \
  libmosquitto-dev \
  lua5.1 \
  liblua5.1-dev \
  unzip \
  curl \
  libssl-dev \
  git && \
  git clone https://github.com/owntracks/recorder.git && \
  cd recorder && \
  cp config.mk.in config.mk && \
  sed -i 's/WITH_LUA ?= no/WITH_LUA ?= yes/' config.mk && \
  sed -i 's/pkg-config --cflags lua/pkg-config --cflags lua-5.1/' config.mk && \
  sed -i 's/pkg-config --libs lua/pkg-config --libs lua-5.1/' config.mk && \
  make && \
  make install && \
  cd ../ && \
  rm -rf /recorder && \
  git clone git://github.com/luarocks/luarocks.git && \
  cd luarocks && \
  ./configure && \
  make && \
  make install && \
  cd ../ && \
  rm -rf /luarocks && \
  luarocks install lua-requests && \
  ot-recorder --storage /storage --initialize && \
  ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log && \
  rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default

# Set the entry point
ENTRYPOINT ["/init"]

# Install services
COPY services /etc/services.d

# Install init.sh as init script
COPY init.sh /etc/cont-init.d/

# Install nginx sites
COPY sites/* /etc/nginx/sites-available/

RUN ln -sf /etc/nginx/sites-available/publish /etc/nginx/sites-enabled/publish && \
    ln -sf /etc/nginx/sites-available/view    /etc/nginx/sites-enabled/view
   
# Install hooks.lua
COPY hooks.lua /hooks.lua

# Download and extract s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

