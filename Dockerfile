FROM ubuntu:24.04

ARG RUNWAY_DOCKER_USER=root

ENV PATH="$PATH:/opt/bin"

RUN apt-get --yes update && \
    apt-get --yes install supervisor dnsutils git curl && \
	rm -rf /var/lib/apt/lists/*

COPY . /src

RUN shelduck_install_script=$(curl --fail --silent --show-error --location https://github.com/legeyda/shelduck/releases/latest/download/install.sh) && \
	eval "$shelduck_install_script" && \
	( cd /src && ./run install && ./run install_supervisord_program ) && \
	rm -rf /src && \
	if [ root != "$RUNWAY_DOCKER_USER" ]; then \
		useradd -M $RUNWAY_DOCKER_USER && \
		mkdir /opt/$RUNWAY_DOCKER_USER/logs && \
		chown -R $RUNWAY_DOCKER_USER:$RUNWAY_DOCKER_USER /opt/$RUNWAY_DOCKER_USER; \
	fi

USER "$RUNWAY_DOCKER_USER"
ENTRYPOINT ["/bin/sh", "-c", "set -eux; \"$0\" \"$@\""]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]