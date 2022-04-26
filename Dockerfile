FROM debian:buster
MAINTAINER Nicholas Wiersma <nick@wiersma.co.za>

ENV VERSION 3.5.3

# Install Dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && sed -i "s#deb http://deb.debian.org/debian buster main#deb http://deb.debian.org/debian buster main non-free#g" /etc/apt/sources.list \
    && apt-get -q update \
    && apt-get install -qqy python3-setuptools python3-pip python3-openssl libffi-dev libssl-dev p7zip-full par2 unrar unzip python3 openssl ca-certificates wget \
    && /usr/bin/update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# Create user and group for SABnzbd.
RUN addgroup --system --gid 666 sabnzbd \
    && adduser --system --uid 666 --ingroup sabnzbd --home /sabnzbd --shell /bin/sh sabnzbd

# Install Sabnzbd
RUN wget -O- https://codeload.github.com/sabnzbd/sabnzbd/tar.gz/$VERSION | tar -xz \
    && mv sabnzbd-*/* /sabnzbd \
    && python3 -m pip install -r /sabnzbd/requirements.txt

# Add SABnzbd init script.
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Define container settings.
VOLUME ["/datadir", "/download"]

EXPOSE 8080

# Start SABnzbd.
WORKDIR /sabnzbd

CMD ["/entrypoint.sh"]
