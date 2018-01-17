#!/usr/bin/env bash
# Run as root or with sudo

# Make script exit if a simple command fails and
# Make script print commands being executed
set -e -x

# Set names of latest versions of each package
export VERSION_PCRE=pcre-8.41
export VERSION_ZLIB=zlib-1.2.11
export VERSION_OPENSSL=openssl-1.1.0g
export VERSION_NGINX=nginx-1.13.8

# Set checksums of latest versions
export SHA256_PCRE=244838e1f1d14f7e2fa7681b857b3a8566b74215f28133f14a8f5e59241b682c
export SHA256_ZLIB=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
export SHA256_OPENSSL=de4d501267da39310905cb6dc8c6121f7a2cad45a7707f76df828fe1b85073af
export SHA256_NGINX=8410b6c31ff59a763abf7e5a5316e7629f5a5033c95a3a0ebde727f9ec8464c5

# Set GPG keys used to sign downloads
export GPG_OPENSSL=8657ABB260F056B1E5190839D9C4D26D0E604491
export GPG_NGINX=B0F4253373F8F6F510D42178520A9993A1C052F8

# Set URLs to the source directories
export SOURCE_OPENSSL=https://www.openssl.org/source/
export SOURCE_PCRE=https://ftp.pcre.org/pub/pcre/
export SOURCE_ZLIB=https://zlib.net/
export SOURCE_NGINX=https://nginx.org/download/

# Set where OpenSSL and nginx will be built
export BPATH=$(pwd)/build

# Make a 'today' variable for use in back-up filenames later
today=$(date +"%Y-%m-%d")

# Clean out any files from previous runs of this script
rm -rf build
rm -rf /etc/nginx-default
mkdir $BPATH

# Ensure the required software to compile nginx is installed
apt-get update && apt-get -y install \
  binutils \
  build-essential \
  curl \
  apache2-utils \
  ca-certificates \
  dirmngr \
  git \
  gnupg \
  libcurl4-openssl-dev \
  libxslt1-dev \
  libxml2 \
  libssl-dev

# Download the source files
curl -L $SOURCE_PCRE$VERSION_PCRE.tar.gz -o ./build/PCRE.tar.gz && \
  echo "${SHA256_PCRE} ./build/PCRE.tar.gz" | sha256sum -c -
curl -L $SOURCE_ZLIB$VERSION_ZLIB.tar.gz -o ./build/ZLIB.tar.gz && \
  echo "${SHA256_ZLIB} ./build/ZLIB.tar.gz" | sha256sum -c -
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz -o ./build/OPENSSL.tar.gz && \
  echo "${SHA256_OPENSSL} ./build/OPENSSL.tar.gz" | sha256sum -c -
curl -L $SOURCE_NGINX$VERSION_NGINX.tar.gz -o ./build/NGINX.tar.gz && \
  echo "${SHA256_NGINX} ./build/NGINX.tar.gz" | sha256sum -c -

# Download the signature files
curl -L $SOURCE_OPENSSL$VERSION_OPENSSL.tar.gz.asc -o ./build/OPENSSL.tar.gz.asc
curl -L $SOURCE_NGINX$VERSION_NGINX.tar.gz.asc -o ./build/NGINX.tar.gz.asc

# Verify GPG signature of downloads
cd $BPATH
export GNUPGHOME="$(mktemp -d)"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_OPENSSL"
gpg --batch --verify OPENSSL.tar.gz.asc OPENSSL.tar.gz
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_NGINX"
gpg --batch --verify NGINX.tar.gz.asc NGINX.tar.gz
rm -r "$GNUPGHOME" OPENSSL.tar.gz.asc NGINX.tar.gz.asc

# Expand the source files
tar xzf PCRE.tar.gz
tar xzf ZLIB.tar.gz
tar xzf OPENSSL.tar.gz
tar xzf NGINX.tar.gz
# Clean up
rm -r \
  PCRE.tar.gz \
  ZLIB.tar.gz \
  OPENSSL.tar.gz \
  NGINX.tar.gz
cd ../

git clone --depth 1 https://github.com/simpl/ngx_devel_kit.git ./build/$VERSION_NGINX/src/devel-kit
git clone --depth 1 https://github.com/openresty/array-var-nginx-module.git ./build/$VERSION_NGINX/src/array-var
git clone --depth 1 https://github.com/samizdatco/nginx-http-auth-digest.git ./build/$VERSION_NGINX/src/auth-digest
git clone --depth 1 https://github.com/ideal/ngx_http_auto_keepalive.git ./build/$VERSION_NGINX/src/auto-keepalive
git clone --depth 1 https://github.com/DvdKhl/ngx_http_autols_module.git ./build/$VERSION_NGINX/src/autols
git clone --depth 1 https://github.com/arut/nginx-dav-ext-module.git ./build/$VERSION_NGINX/src/dav-ext
git clone --depth 1 https://github.com/aperezdc/ngx-fancyindex.git ./build/$VERSION_NGINX/src/fancyindex
git clone --depth 1 https://github.com/openresty/headers-more-nginx-module.git ./build/$VERSION_NGINX/src/headers-more
git clone --depth 1 https://github.com/cfsego/ngx_log_if.git ./build/$VERSION_NGINX/src/log-if
mkdir -p ./build/$VERSION_NGINX/src/mp4-h264 && curl --compressed --location --silent \
  http://h264.code-shop.com/download/nginx_mod_h264_streaming-2.2.7.tar.gz | \
  tar -C ./build/$VERSION_NGINX/src/mp4-h264 --strip-components 1 -xzf -
git clone --depth 1 https://github.com/nbs-system/naxsi.git ./build/$VERSION_NGINX/src/naxsi
git clone --depth 1 https://github.com/slact/nchan.git ./build/$VERSION_NGINX/src/nchan
git clone --depth 1 https://github.com/kr/nginx-notice.git ./build/$VERSION_NGINX/src/notice
git clone --depth 1 https://github.com/wandenberg/nginx-push-stream-module.git ./build/$VERSION_NGINX/src/push-stream
git clone --depth 1 https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git ./build/$VERSION_NGINX/src/rtmp
git clone --depth 1 https://github.com/openresty/set-misc-nginx-module.git ./build/$VERSION_NGINX/src/set-misc
git clone --depth 1 https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git ./build/$VERSION_NGINX/src/subs-filter
git clone -b "2.255" --depth 1 --single-branch https://github.com/vkholodkov/nginx-upload-module.git ./build/$VERSION_NGINX/src/upload
git clone --depth 1 https://github.com/masterzen/nginx-upload-progress-module.git ./build/$VERSION_NGINX/src/upload-progress
git clone --depth 1 https://github.com/kaltura/nginx-vod-module.git ./build/$VERSION_NGINX/src/vod
git clone --depth 1 https://github.com/tg123/websockify-nginx-module.git ./build/$VERSION_NGINX/src/websockify
git clone --depth 1 https://github.com/yoreek/nginx-xsltproc-module.git ./build/$VERSION_NGINX/src/xsltproc

# Rename the existing /etc/nginx directory so it's saved as a back-up
if [ -d "/etc/nginx" ]; then
  mv /etc/nginx /etc/nginx-$today
fi

# Create NGINX cache directories if they do not already exist
if [ ! -d "/var/cache/nginx/" ]; then
    mkdir -p \
    /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp
fi

# Add nginx group and user if they do not already exist
id -g nginx &>/dev/null || addgroup --system nginx
id -u nginx &>/dev/null || adduser --disabled-password --system --home /var/cache/nginx --shell /sbin/nologin --group nginx

# Test to see if our version of gcc supports __SIZEOF_INT128__
if gcc -dM -E - </dev/null | grep -q __SIZEOF_INT128__
then
ECFLAG="enable-ec_nistp_64_gcc_128"
else
ECFLAG=""
fi

# Build nginx, with various modules included/excluded
cd $BPATH/$VERSION_NGINX
./configure \
--prefix=/etc/nginx \
--with-cc-opt='-O3 -fPIE -fstack-protector-strong -Wformat -Werror=format-security' \
--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
--with-pcre=$BPATH/$VERSION_PCRE \
--with-zlib=$BPATH/$VERSION_ZLIB \
--with-openssl-opt="no-weak-ssl-ciphers no-ssl3 no-shared $ECFLAG -DOPENSSL_NO_HEARTBEATS -fstack-protector-strong" \
--with-openssl=$BPATH/$VERSION_OPENSSL \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-file-aio \
--with-http_auth_request_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-http_v2_module \
--with-pcre-jit \
--with-stream \
--with-stream_ssl_module \
--with-threads \
--with-debug \
--with-http_dav_module \
--with-http_xslt_module \
--with-mail \
--with-mail_ssl_module \
--with-stream_ssl_preread_module \
--add-module=./src/devel-kit \
--add-module=./src/array-var \
--add-module=./src/auth-digest \
--add-module=./src/auto-keepalive \
--add-module=./src/autols/ngx_http_autols_module \
--add-module=./src/dav-ext \
--add-module=./src/fancyindex \
--add-module=./src/headers-more \
--add-module=./src/log-if \
--add-module=./src/mp4-h264 \
--add-module=./src/naxsi/naxsi_src \
--add-module=./src/nchan \
--add-module=./src/notice \
--add-module=./src/push-stream \
--add-module=./src/rtmp \
--add-module=./src/set-misc \
--add-module=./src/subs-filter \
--add-module=./src/upload \
--add-module=./src/upload-progress \
--add-module=./src/vod \
--add-module=./src/websockify \
--add-module=./src/xsltproc

make
make install
make clean
strip -s /usr/sbin/nginx*

if [ -d "/etc/nginx-$today" ]; then
  # Rename the compiled 'default' /etc/nginx directory so its accessible as a reference to the new nginx defaults
  mv /etc/nginx /etc/nginx-default

  # Restore the previous version of /etc/nginx to /etc/nginx so the old settings are kept
  mv /etc/nginx-$today /etc/nginx
fi

# Create NGINX systemd service file if it does not already exist
if [ ! -e "/lib/systemd/system/nginx.service" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
  FILE="/lib/systemd/system/nginx.service"

  /bin/cat >$FILE <<'EOF'
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
fi

echo "All done.";
echo "Start with sudo systemctl start nginx"
echo "or with sudo nginx"
