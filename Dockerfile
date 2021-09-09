FROM alpine:3.8
MAINTAINER Nicholas Wiersma <nick@wiersma.co.za>

ENV VERSION 3.3.1

# Create user and group for SABnzbd.
RUN addgroup -S -g 666 sabnzbd \
    && adduser -S -u 666 -G sabnzbd -h /sabnzbd -s /bin/sh sabnzbd

# Install Dependencies
RUN apk add --no-cache python3-pip python3-openssl p7zip-full par2 unrar unzip python3 openssl ca-certificates \
    && /usr/bin/update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    && wget -O- https://codeload.github.com/sabnzbd/sabnzbd/tar.gz/$VERSION | tar -zx \
    && mv sabnzbd-*/* sabnzbd \
    && python3 -m pip install -r /sabnzbd/requirements.txt \
    && chown -R sabnzbd: sabnzbd

# Add SABnzbd init script.
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Define container settings.
VOLUME ["/datadir", "/download"]

EXPOSE 8080

# Start SABnzbd.
WORKDIR /sabnzbd

CMD ["/entrypoint.sh"]
