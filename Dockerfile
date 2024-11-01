FROM ubuntu:24.04

ARG RUNWAY_ROOT /opt/runway
ARG RUNWAY_CHECKOUT "$RUNWAY_ROOT/checkout"

WORKDIR $RUNWAY_ROOT

ENV RUNWAY_SSH_KNOWN_HOSTS_FILE=
ENV RUNWAY_SSH_KNOWN_HOSTS=
ENV RUNWAY_SSH_KEY_FILE=
ENV RUNWAY_SSH_KEY=
ENV RUNWAY_REPO=
ENV RUNWAY_BRANCH=
ENV RUNWAY_UPDATE_DELAY=60



RUN apt-get --yes install git && \
	instaluseradd -M runway && \
    mkdir $RUNWAY_ROOT/logs && \
    chown -R runway:runway

COPY entrypoint.sh "$RUNWAY_ROOT"

USER runway
ENTRYPOINT ["/bin/sh"]
CMD ["$RUNWAY_ROOT/entrypoint.sh"]
