FROM alpine:3.4
MAINTAINER Nicholas Wiersma <nick@wiersma.co.za>

ENV VERSION 1.0.3
ENV CHEETAH 2.4.4
ENV YENC 0.4.0
ENV PAR2 0.6.14

# Create user and group for SABnzbd.
RUN addgroup -S -g 666 sabnzbd \
    && adduser -S -u 666 -G sabnzbd -h /sabnzbd -s /bin/sh sabnzbd

# Install Dependencies
RUN apk add --no-cache ca-certificates py-six py-cryptography py-enum34 \
                       py-cffi py-openssl openssl unzip unrar p7zip \
    && wget -O- https://codeload.github.com/sabnzbd/sabnzbd/tar.gz/$VERSION | tar -zx \
    && mv sabnzbd-*/* sabnzbd \
    && wget -O- https://pypi.python.org/packages/source/C/Cheetah/Cheetah-$CHEETAH.tar.gz | tar -zx \
    && cd Cheetah-$CHEETAH \
    && python setup.py install \
    && cd .. \
    && rm -rf Cheetah-$CHEETAH

RUN apk add --no-cache build-base automake autoconf python-dev \
    && wget -O- https://github.com/Parchive/par2cmdline/archive/v$PAR2.tar.gz | tar -zx \
    && cd par2cmdline-$PAR2 \
    && aclocal \
    && automake --add-missing \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf par2cmdline-$PAR2 \
    && wget -O- https://bitbucket.org/dual75/yenc/get/$YENC.tar.gz | tar -zx \
    && cd dual75-yenc-* \
    && python setup.py install \
    && cd .. \
    && rm -rf dual75-yenc-* \
    && apk del build-base automake autoconf python-dev

# Add SABnzbd init script.
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Define container settings.
VOLUME ["/datadir", "/download"]

EXPOSE 8080

# Start SABnzbd.
WORKDIR /sabnzbd

CMD ["/entrypoint.sh"]
