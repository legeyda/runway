#!/bin/sh

main() {
	set -eu
	mkdir -p "$RUNWAY_CHECKOUT"
	cd "$RUNWAY_CHECKOUT"

	if [ -z "${RUNWAY_SSH_KNOWN_HOSTS_FILE:-}" ] && [ -n "${RUNWAY_SSH_KNOWN_HOSTS}" ]; then
		RUNWAY_SSH_KNOWN_HOSTS_FILE="$(mktemp)"
		printf %s "$RUNWAY_SSH_KNOWN_HOSTS" > "$RUNWAY_SSH_KNOWN_HOSTS_FILE"
	fi

	if [ -z "${RUNWAY_SSH_KEY_FILE:-}" ] && [ -n "${RUNWAY_SSH_KEY}" ]; then
		RUNWAY_SSH_KEY_FILE="$(mktemp)"
		printf %s "$RUNWAY_SSH_KEY" > "$RUNWAY_SSH_KEY_FILE"
	fi

	# -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
	export GIT_SSH_COMMAND="ssh '${RUNWAY_SSH_KNOWN_HOSTS_FILE:+ -o "UserKnownHostsFile=$RUNWAY_SSH_KNOWN_HOSTS_FILE"}' '${RUNWAY_SSH_KEY_FILE:+ -i "$RUNWAY_SSH_KEY_FILE"}' "
	git clone ${RUNWAY_BRANCH:+ --branch "$RUNWAY_BRANCH"} --single-branch --recurse-submodules "$RUNWAY_REPO" "$RUNWAY_CHECKOUT"
	if [ -z "${RUNWAY_BRANCH}" ]; then
		RUNWAY_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
	fi

	fix_time
	while true; do
		/bin/sh ./run
		if [ $(seconds) -gt "$due" ]; then
			git fetch origin "$RUNWAY_BRANCH" # fetch remote
			fix_time
			git reset --hard "origin/$RUNWAY_BRANCH" --hard
		else
			sleep 1
		fi
	done

}

fix_time() {
	due=$(( "$(seconds)" + "$RUNWAY_UPDATE_DELAY" ))
}

seconds() {
	date +%s
}

main "$@"