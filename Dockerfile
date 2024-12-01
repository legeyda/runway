FROM ubuntu:24.04


ARG RUNWAY_DOCKER_USER=root
ARG RUNWAY_DATA=/opt/runway
ARG RUNWAY_INSTALL_CONFDIR

WORKDIR $RUNWAY_DATA

ENV RUNWAY_SSH_KNOWN_HOSTS_FILE=
ENV RUNWAY_SSH_KNOWN_HOSTS=
ENV RUNWAY_SSH_KEY_FILE=
ENV RUNWAY_SSH_KEY=
ENV RUNWAY_REPO_URL=
ENV RUNWAY_REPO_PATH="$RUNWAY_DATA/checkout"
ENV RUNWAY_REPO_BRANCH=
ENV RUNWAY_REFRESH_DELAY=60
ENV RUNWAY_RUN_COMMAND="./run install"
ENV RUNWAY_RUN_ENV=

ENV PATH="$PATH:/opt/bin"


RUN	set -eu; apt-get --yes update; apt-get --yes install supervisor git curl

RUN	<<EOF
	# set -eu
	# apt-get --yes update
	#apt-get --yes install supervisor git curl
	shelduck_lib=$(curl -fsS https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh)
	eval "$shelduck_lib"
	if [ root != "$RUNWAY_DOCKER_USER" ]; then
		useradd -M $RUNWAY_DOCKER_USER
		mkdir /opt/$RUNWAY_DOCKER_USER/logs
		chown -R $RUNWAY_DOCKER_USER:$RUNWAY_DOCKER_USER /opt/$RUNWAY_DOCKER_USER
	fi
EOF

# COPY runway.conf /etc/supervisor/conf.d
COPY target/docker-build /



USER "$RUNWAY_DOCKER_USER"
ENTRYPOINT ["/bin/sh", "-c", "set -eux; \"$0\" \"$@\""]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]