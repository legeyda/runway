FROM ubuntu:24.04 AS build

ARG WORKDIR=/tmp/runway
WORKDIR $WORKDIR
COPY . ./src
ENV PATH="$PATH:/opt/bin"


RUN <<EOF
	set -eu
	apt-get  update
	apt-get --yes install curl dnsutils ssh
	rm -rf /var/lib/apt/lists/*
	shelduck_installer=$(curl -fsS https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh)
	eval "$shelduck_installer"
	cd $WORKDIR/src
	export RUNWAY_INSTALL_DESTDIR=$WORKDIR/dest
	./run install
	./run install_supervisord_program
EOF


FROM ubuntu:24.04
RUN	apt-get update


ARG RUNWAY_DOCKER_USER=root
ARG RUNWAY_DATA=/opt/runway
ARG RUNWAY_INSTALL_CONFDIR

WORKDIR $RUNWAY_DATA

# ENV RUNWAY_SSH_KNOWN_HOSTS_FILE
# ENV RUNWAY_SSH_KNOWN_HOSTS
# ENV RUNWAY_SSH_IDENTITY_FILE
# ENV RUNWAY_SSH_IDENTITY
# ENV RUNWAY_REPO_URL
ENV RUNWAY_REPO_PATH="$RUNWAY_DATA/checkout"
# ENV RUNWAY_REPO_BRANCH
ENV RUNWAY_REFRESH_DELAY=60
ENV RUNWAY_RUN_COMMAND="./run install"
# ENV RUNWAY_RUN_ENV

ENV PATH="$PATH:/opt/bin"


RUN	<<EOF
	set -eu
	apt-get --yes update
	apt-get --yes install supervisor git curl
	rm -rf /var/lib/apt/lists/*
	shelduck_lib=$(curl -fsS https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh)
	eval "$shelduck_lib"
	if [ root != "$RUNWAY_DOCKER_USER" ]; then
		useradd -M $RUNWAY_DOCKER_USER
		mkdir /opt/$RUNWAY_DOCKER_USER/logs
		chown -R $RUNWAY_DOCKER_USER:$RUNWAY_DOCKER_USER /opt/$RUNWAY_DOCKER_USER
	fi
EOF

COPY --from=build /tmp/runway/dest /

USER "$RUNWAY_DOCKER_USER"
ENTRYPOINT ["/bin/sh", "-c", "set -eux; \"$0\" \"$@\""]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]