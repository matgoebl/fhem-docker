ARG BASE_IMAGE="debian"
ARG BASE_IMAGE_TAG="buster"
FROM debian:buster-20230814-slim

ARG TARGETPLATFORM

ENV LANG=en_US.UTF-8 \
   LANGUAGE=en_US:en \
   LC_ADDRESS=de_DE.UTF-8 \
   LC_MEASUREMENT=de_DE.UTF-8 \
   LC_MESSAGES=en_DK.UTF-8 \
   LC_MONETARY=de_DE.UTF-8 \
   LC_NAME=de_DE.UTF-8 \
   LC_NUMERIC=de_DE.UTF-8 \
   LC_PAPER=de_DE.UTF-8 \
   LC_TELEPHONE=de_DE.UTF-8 \
   LC_TIME=de_DE.UTF-8 \
   TERM=xterm \
   TZ=Europe/Berlin \
   LOGFILE=./log/fhem-%Y-%m-%d.log \
   TELNETPORT=7072 \
   FHEM_UID=6061 \
   FHEM_GID=6061 \
   FHEM_PERM_DIR=0750 \
   FHEM_PERM_FILE=0640 \
   UMASK=0037 \
   BLUETOOTH_GID=6001 \
   GPIO_GID=6002 \
   I2C_GID=6003 \
   TIMEOUT=10 \
   CONFIGTYPE=fhem.cfg

# Install base environment
COPY src/entry.sh src/health-check.sh src/ssh_known_hosts.txt /
COPY src/find-* /usr/local/bin/

# Custom installation packages
ARG APT_PKGS=""

RUN chmod 755 /*.sh /usr/local/bin/* \
    && sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list \
    && sed -i "s/buster-updates main/buster-updates main contrib non-free/g" /etc/apt/sources.list \
    && sed -i "s/buster\/updates main/buster\/updates main contrib non-free/g" /etc/apt/sources.list \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        apt-utils \
        ca-certificates \
        gnupg \
        locales \
    && LC_ALL=C c_rehash \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
    && echo 'de_DE@euro ISO-8859-15\nde_DE ISO-8859-1\nde_DE.UTF-8 UTF-8\nen_DK ISO-8859-1\nen_DK.ISO-8859-15 ISO-8859-15\nen_DK.UTF-8 UTF-8\nen_GB ISO-8859-1\nen_GB.ISO-8859-15 ISO-8859-15\nen_GB.UTF-8 UTF-8\nen_IE ISO-8859-1\nen_IE.ISO-8859-15 ISO-8859-15\nen_IE.UTF-8 UTF-8\nen_US ISO-8859-1\nen_US.ISO-8859-15 ISO-8859-15\nen_US.UTF-8 UTF-8\nes_ES@euro ISO-8859-15\nes_ES ISO-8859-1\nes_ES.UTF-8 UTF-8\nfr_FR@euro ISO-8859-15\nfr_FR ISO-8859-1\nfr_FR.UTF-8 UTF-8\nit_IT@euro ISO-8859-15\nit_IT ISO-8859-1\nit_IT.UTF-8 UTF-8\nnl_NL@euro ISO-8859-15\nnl_NL ISO-8859-1\nnl_NL.UTF-8 UTF-8\npl_PL ISO-8859-2\npl_PL.UTF-8 UTF-8' >/etc/locale.gen \
    && LC_ALL=C locale-gen \
    \
    && ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && echo "Europe/Berlin" > /etc/timezone \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        adb \
        android-libadb \
        avahi-daemon \
        avrdude \
        bluez \
        curl \
        dnsutils \
        etherwake \
        fonts-liberation \
        i2c-tools \
        inetutils-ping \
        jq \
        libcap-ng-utils \
        libcap2-bin \
        lsb-release \
        mariadb-client \
        net-tools \
        netcat \
        openssh-client \
        procps \
        sendemail \
        sqlite3 \
        subversion \
        sudo \
        telnet \
        unzip \
        usbutils \
        wget \
        ${APT_PKGS} \
    && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/*

# Add Perl basic app layer for pre-compiled packages
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        libarchive-extract-perl \
        libarchive-zip-perl \
        libcgi-pm-perl \
        libcpanel-json-xs-perl \
        libdbd-mariadb-perl \
        libdbd-mysql-perl \
        libdbd-pg-perl \
        libdbd-pgsql \
        libdbd-sqlite3 \
        libdbd-sqlite3-perl \
        libdbi-perl \
        libdevice-serialport-perl \
        libdevice-usb-perl \
        libgd-graph-perl \
        libgd-text-perl \
        libimage-imlib2-perl \
        libimage-info-perl \
        libimage-librsvg-perl \
        libio-all-perl \
        libio-file-withpath-perl \
        libio-interface-perl \
        libio-socket-inet6-perl \
        libjson-perl \
        libjson-pp-perl \
        libjson-xs-perl \
        liblist-moreutils-perl \
        libmail-gnupg-perl \
        libmail-imapclient-perl \
        libmail-sendmail-perl \
        libmime-base64-perl \
        libmime-lite-perl \
        libnet-server-perl \
        libsocket6-perl \
        libterm-readline-perl-perl \
        libtext-csv-perl \
        libtext-diff-perl \
        libtext-iconv-perl \
        libtimedate-perl \
        libutf8-all-perl \
        libwww-curl-perl \
        libwww-perl \
        libxml-libxml-perl \
        libxml-parser-lite-perl \
        libxml-parser-perl \
        libxml-simple-perl \
        libxml-stream-perl \
        libxml-treebuilder-perl \
        libxml-xpath-perl \
        libxml-xpathengine-perl \
        libyaml-libyaml-perl \
        libyaml-perl \
        perl-base \
    && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/*

# Custom image layers options:
ARG IMAGE_LAYER_SYS_EXT="1"

# Add extended system layer
RUN if [ "${IMAGE_LAYER_SYS_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        alsa-utils \
        dfu-programmer \
        espeak \
        ffmpeg \
        lame \
        libnmap-parser-perl \
        libttspico-utils \
        mp3wrap \
        mpg123 \
        mplayer \
        nmap \
        normalize-audio \
        snmp \
        snmp-mibs-downloader \
        sox \
        vorbis-tools \
        gstreamer1.0-tools \
        libsox-fmt-all \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi


# Custom image layers options:
ARG IMAGE_LAYER_PERL_EXT="1"

# Add Perl extended app layer for pre-compiled packages
RUN if [ "${IMAGE_LAYER_PERL_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        libalgorithm-merge-perl \
        libauthen-bitcard-perl \
        libauthen-captcha-perl \
        libauthen-cas-client-perl \
        libauthen-dechpwd-perl \
        libauthen-htpasswd-perl \
        libauthen-krb5-admin-perl \
        libauthen-krb5-perl \
        libauthen-krb5-simple-perl \
        libauthen-libwrap-perl \
        libauthen-ntlm-perl \
        libauthen-oath-perl \
        libauthen-pam-perl \
        libauthen-passphrase-perl \
        libauthen-radius-perl \
        libauthen-sasl-cyrus-perl \
        libauthen-sasl-perl \
        libauthen-sasl-saslprep-perl \
        libauthen-scram-perl \
        libauthen-simple-cdbi-perl \
        libauthen-simple-dbi-perl \
        libauthen-simple-dbm-perl \
        libauthen-simple-http-perl \
        libauthen-simple-kerberos-perl \
        libauthen-simple-ldap-perl \
        libauthen-simple-net-perl \
        libauthen-simple-pam-perl \
        libauthen-simple-passwd-perl \
        libauthen-simple-perl \
        libauthen-simple-radius-perl \
        libauthen-simple-smb-perl \
        libauthen-smb-perl \
        libauthen-tacacsplus-perl \
        libauthen-u2f-perl \
        libauthen-u2f-tester-perl \
        libclass-dbi-mysql-perl \
        libclass-isa-perl \
        libclass-loader-perl \
        libcommon-sense-perl \
        libconvert-base32-perl \
        libcpan-meta-yaml-perl \
        libcrypt-blowfish-perl \
        libcrypt-cast5-perl \
        libcrypt-cbc-perl \
        libcrypt-ciphersaber-perl \
        libcrypt-cracklib-perl \
        libcrypt-des-ede3-perl \
        libcrypt-des-perl \
        libcrypt-dh-gmp-perl \
        libcrypt-dh-perl \
        libcrypt-dsa-perl \
        libcrypt-ecb-perl \
        libcrypt-eksblowfish-perl \
        libcrypt-format-perl \
        libcrypt-gcrypt-perl \
        libcrypt-generatepassword-perl \
        libcrypt-hcesha-perl \
        libcrypt-jwt-perl \
        libcrypt-mysql-perl \
        libcrypt-openssl-bignum-perl \
        libcrypt-openssl-dsa-perl \
        libcrypt-openssl-ec-perl \
        libcrypt-openssl-pkcs10-perl \
        libcrypt-openssl-pkcs12-perl \
        libcrypt-openssl-random-perl \
        libcrypt-openssl-rsa-perl \
        libcrypt-openssl-x509-perl \
        libcrypt-passwdmd5-perl \
        libcrypt-pbkdf2-perl \
        libcrypt-random-seed-perl \
        libcrypt-random-source-perl \
        libcrypt-rc4-perl \
        libcrypt-rijndael-perl \
        libcrypt-rsa-parse-perl \
        libcrypt-saltedhash-perl \
        libcrypt-simple-perl \
        libcrypt-smbhash-perl \
        libcrypt-smime-perl \
        libcrypt-ssleay-perl \
        libcrypt-twofish-perl \
        libcrypt-u2f-server-perl \
        libcrypt-unixcrypt-perl \
        libcrypt-unixcrypt-xs-perl \
        libcrypt-urandom-perl \
        libcrypt-util-perl \
        libcrypt-x509-perl \
        libcryptx-perl \
        libdata-dump-perl \
        libdatetime-format-strptime-perl \
        libdatetime-perl \
        libdevel-size-perl \
        libdigest-bcrypt-perl \
        libdigest-bubblebabble-perl \
        libdigest-crc-perl \
        libdigest-elf-perl \
        libdigest-hmac-perl \
        libdigest-jhash-perl \
        libdigest-md2-perl \
        libdigest-md4-perl \
        libdigest-md5-file-perl \
        libdigest-perl-md5-perl \
        libdigest-sha-perl \
        libdigest-sha3-perl \
        libdigest-ssdeep-perl \
        libdigest-whirlpool-perl \
        libdpkg-perl \
        libencode-perl \
        liberror-perl \
        libev-perl \
        libextutils-makemaker-cpanfile-perl \
        libfile-copy-recursive-perl \
        libfile-fcntllock-perl \
        libfinance-quote-perl \
        libgnupg-interface-perl \
        libhtml-strip-perl \
        libhtml-treebuilder-xpath-perl \
        libio-socket-inet6-perl \
        libio-socket-ip-perl \
        libio-socket-multicast-perl \
        libio-socket-portstate-perl \
        libio-socket-socks-perl \
        libio-socket-ssl-perl \
        libio-socket-timeout-perl \
        liblinux-inotify2-perl \
        libmath-round-perl \
        libmodule-pluggable-perl \
        libmojolicious-perl \
        libmoose-perl \
        libmoox-late-perl \
        libmp3-info-perl \
        libmp3-tag-perl \
        libnet-address-ip-local-perl \
        libnet-bonjour-perl \
        libnet-jabber-perl \
        libnet-oauth-perl \
        libnet-oauth2-perl \
        libnet-sip-perl \
        libnet-snmp-perl \
        libnet-ssleay-perl \
        libnet-telnet-perl \
        libnet-xmpp-perl \
        libnmap-parser-perl \
        librivescript-perl \
        librpc-xml-perl \
        libsnmp-perl \
        libsnmp-session-perl \
        libsoap-lite-perl \
        libsocket-perl \
        libswitch-perl \
        libsys-hostname-long-perl \
        libsys-statistics-linux-perl \
        libterm-readkey-perl \
        libterm-readline-perl-perl \
        libtime-period-perl \
        libtypes-path-tiny-perl \
        liburi-escape-xs-perl \
        perl \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Custom image layers options:
ARG IMAGE_LAYER_DEV="1"

# Add development/compilation layer
RUN if [ "${IMAGE_LAYER_DEV}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ] || [ "${IMAGE_LAYER_NODEJS}" != "0" ] || [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        libavahi-compat-libdnssd-dev \
        libdb-dev \
        libsodium-dev \
        libssl-dev \
        libtool \
        libusb-1.0-0-dev \
        patch \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi


# Custom image layers options:
ARG IMAGE_LAYER_PERL_CPAN="1"
ARG IMAGE_LAYER_PERL_CPAN_EXT="1"

# Custom installation packages
ARG CPAN_PKGS=""

# Add Perl app layer for self-compiled modules
#  * exclude any ARM platforms due to long build time
#  * manually pre-compiled ARM packages may be applied here
RUN if [ "${CPAN_PKGS}" != "" ] || [ "${PIP_PKGS}" != "" ] || [ "${IMAGE_LAYER_PERL_CPAN}" != "0" ] || [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
      curl --retry 3 --retry-connrefused --retry-delay 2 -fsSL https://git.io/cpanm | perl - App::cpanminus \
      && cpanm --notest \
          App::cpanoutdated \
          CPAN::Plugin::Sysdeps \
          Perl::PrereqScanner::NotQuiteLite \
          Readonly \
      && if [ "${CPAN_PKGS}" != "" ]; then \
          cpanm \
           ${CPAN_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_PERL_CPAN_EXT}" != "0" ]; then \
           if [ "${TARGETPLATFORM}" = "linux/amd64" ] || [ "${TARGETPLATFORM}" = "linux/i386" ]; then \
             cpanm --notest \
              Alien::Base::ModuleBuild \
              Alien::Sodium@1.0.8.0 \
              Crypt::Argon2 \
              Crypt::OpenSSL::AES \
              Crypt::NaCl::Sodium \
              Device::SMBus \
              Net::MQTT::Constants \
              Net::MQTT::Simple \
              Net::WebSocket::Server \
              Device::Firmata \
              Protocol::WebSocket \ 
             ; fi \
         ; fi \
      && rm -rf /root/.cpanm \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Custom image layers options:
ARG IMAGE_LAYER_PYTHON="1"
ARG IMAGE_LAYER_PYTHON_EXT="1"

# Custom installation packages
ARG PIP_PKGS=""

# Add Python app layer
RUN if [ "${PIP_PKGS}" != "" ] || [ "${IMAGE_LAYER_PYTHON}" != "0" ] || [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
      LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
      && if [ "${PIP_PKGS}" != "" ]; then \
           pip3 install \
            ${PIP_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_PYTHON_EXT}" != "0" ]; then \
           LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
                python3-pychromecast \
                speedtest-cli \
                youtube-dl \
             && ln -s ../../bin/speedtest-cli /usr/local/bin/speedtest-cli \
        ; fi \
      && rm -rf /root/.cpanm \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Custom installation packages
ARG NPM_PKGS=""

# Custom image layers options:
ARG IMAGE_LAYER_NODEJS="1"
ARG IMAGE_LAYER_NODEJS_EXT="1"

# Add nodejs app layer
RUN if ( [ "${NPM_PKGS}" != "" ] || [ "${IMAGE_LAYER_NODEJS}" != "0" ] || [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ] ) ; then \
      LC_ALL=C curl --retry 3 --retry-connrefused --retry-delay 2 -fsSL https://deb.nodesource.com/setup_14.x | LC_ALL=C bash - \
      && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
          nodejs=14.* \
      && if [ ! -e /usr/bin/npm ]; then \
           LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends \
             npm=5.* \
      ; fi \
      && npm install -g --unsafe-perm --production \
          npm \
      && if [ "${NPM_PKGS}" != "" ]; then \
          npm install -g --unsafe-perm --production \
           ${NPM_PKGS} \
         ; fi \
      && if [ "${IMAGE_LAYER_NODEJS_EXT}" != "0" ]; then \
           npm install -g --unsafe-perm --production \
            alexa-cookie2 \
            alexa-fhem \
            gassistant-fhem \
            homebridge \
            homebridge-fhem \
            tradfri-fhem \
        ; fi \
      && LC_ALL=C apt-get autoremove -qqy && LC_ALL=C apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.[^.] ~/.??* ~/* \
    ; fi

# Add FHEM app layer
# Note: Manual checkout is required if build is not run by Github Actions workflow:
#   svn co https://svn.fhem.de/fhem/trunk ./src/fhem/trunk

COPY src/fhem/trunk/fhem/ /fhem/
COPY src/FHEM/ /fhem/FHEM

# Moved AGS to the end, because it changes every run and invalidates the cache for all following steps  https://github.com/moby/moby/issues/20136
# Arguments to instantiate as variables
ARG PLATFORM="linux"
ARG TAG=""
ARG IMAGE_VCS_REF=""
ARG VCS_REF=""
ARG FHEM_VERSION=""
ARG IMAGE_VERSION=""
ARG BUILD_DATE=""

# Re-usable variables during build

ARG L_AUTHORS=""
ARG L_URL="https://hub.docker.com/r/fhem/fhem-${TARGETPLATFORM}"
ARG L_USAGE="https://github.com/fhem/fhem-docker/blob/${IMAGE_VCS_REF}/README.md"
ARG L_VCS_URL="https://github.com/fhem/fhem-docker/"
ARG L_VENDOR="FHEM"
ARG L_LICENSES="MIT"
ARG L_TITLE="fhem-${TARGETPLATFORM}"
ARG L_DESCR="A basic Docker image for FHEM house automation system, based on Debian Buster."

ARG L_AUTHORS_FHEM="https://fhem.de/MAINTAINER.txt"
ARG L_URL_FHEM="https://fhem.de/"
ARG L_USAGE_FHEM="https://fhem.de/#Documentation"
ARG L_VCS_URL_FHEM="https://svn.fhem.de/"
ARG L_VENDOR_FHEM="FHEM e.V."
ARG L_LICENSES_FHEM="GPL-2.0"
ARG L_DESCR_FHEM="FHEM (TM) is a GPL'd perl server for house automation. It is used to automate some common tasks in the household like switching lamps / shutters / heating / etc. and to log events like temperature / humidity / power consumption."


# non-standard labels
LABEL org.fhem.authors=${L_AUTHORS_FHEM} \
   org.fhem.url=${L_URL_FHEM} \
   org.fhem.documentation=${L_USAGE_FHEM} \
   org.fhem.source=${L_VCS_URL_FHEM} \
   org.fhem.version=${FHEM_VERSION} \
   org.fhem.revision=${VCS_REF} \
   org.fhem.vendor=${L_VENDOR_FHEM} \
   org.fhem.licenses=${L_LICENSES_FHEM} \
   org.fhem.description=${L_DESCR_FHEM}

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.created=${BUILD_DATE} \
   org.opencontainers.image.authors=${L_AUTHORS} \
   org.opencontainers.image.url=${L_URL} \
   org.opencontainers.image.documentation=${L_USAGE} \
   org.opencontainers.image.source=${L_VCS_URL} \
   org.opencontainers.image.version=${IMAGE_VERSION} \
   org.opencontainers.image.revision=${IMAGE_VCS_REF} \
   org.opencontainers.image.vendor=${L_VENDOR} \
   org.opencontainers.image.licenses=${L_LICENSES} \
   org.opencontainers.image.title=${L_TITLE} \
   org.opencontainers.image.description=${L_DESCR}

RUN echo "org.opencontainers.image.created=${BUILD_DATE}\norg.opencontainers.image.authors=${L_AUTHORS}\norg.opencontainers.image.url=${L_URL}\norg.opencontainers.image.documentation=${L_USAGE}\norg.opencontainers.image.source=${L_VCS_URL}\norg.opencontainers.image.version=${IMAGE_VERSION}\norg.opencontainers.image.revision=${IMAGE_VCS_REF}\norg.opencontainers.image.vendor=${L_VENDOR}\norg.opencontainers.image.licenses=${L_LICENSES}\norg.opencontainers.image.title=${L_TITLE}\norg.opencontainers.image.description=${L_DESCR}\norg.fhem.authors=${L_AUTHORS_FHEM}\norg.fhem.url=${L_URL_FHEM}\norg.fhem.documentation=${L_USAGE_FHEM}\norg.fhem.source=${L_VCS_URL_FHEM}\norg.fhem.version=${FHEM_VERSION}\norg.fhem.revision=${VCS_REF}\norg.fhem.vendor=${L_VENDOR_FHEM}\norg.fhem.licenses=${L_LICENSES_FHEM}\norg.fhem.description=${L_DESCR_FHEM}" > /image_info

VOLUME [ "/opt/fhem" ]

EXPOSE 8083

HEALTHCHECK --interval=20s --timeout=10s --start-period=60s --retries=5 CMD /health-check.sh

WORKDIR "/opt/fhem"
ENTRYPOINT [ "/entry.sh" ]
CMD [ "start" ]
