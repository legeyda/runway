FROM ubuntu:24.04


ARG RUNWAY_USER=runway
ARG RUNWAY_DATA=/opt/runway
ARG RUNWAY_DIR="$RUNWAY_DATA/checkout"

WORKDIR $RUNWAY_DATA

ENV RUNWAY_SSH_KNOWN_HOSTS_FILE=
ENV RUNWAY_SSH_KNOWN_HOSTS=
ENV RUNWAY_SSH_KEY_FILE=
ENV RUNWAY_SSH_KEY=
ENV RUNWAY_REPO_URL=
ENV RUNWAY_REPO_BRANCH=
ENV RUNWAY_REFRESH_DELAY=60
ENV RUNWAY_RUN_COMMAND=
ENV RUNWAY_RUN_ENV=''




RUN	set -eu \
	apt-get --yes update \
	apt-get --yes install supervisor git curl \
	src=$(curl -fsS https://raw.githubusercontent.com/legeyda/shelduck/refs/heads/main/install.sh) \
	eval "$src" \
	if [ root != "$RUNWAY_USER" ]; then \
		useradd -M $RUNWAY_USER \
		mkdir /opt/$RUNWAY_USER/logs \
		chown -R $RUNWAY_USER:$RUNWAY_USER /opt/$RUNWAY_USER \
	fi


COPY runway.conf /etc/supervisor/conf.d

COPY entrypoint.sh /


USER $RUNWAY_USER
ENTRYPOINT ["/bin/sh", "-c", 'set -eu; "$0" "$@"']
CMD ["supervisord"]
