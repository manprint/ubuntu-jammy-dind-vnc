#!/bin/bash

RED=$(tput setaf 1)
YELLOW=$(tput setaf 2)
RESET=$(tput sgr0)
DESC="Manage Kasm Dind VNC"

function internal_mkdir() {
	mkdir -vp $(pwd)/data/docker
	mkdir -vp $(pwd)/data/kasm-user
	sudo chown root:root $(pwd)/data/docker
	sudo chown 1000:1000 $(pwd)/data/kasm-user
}

function down() {
	docker stop kasm-dind
	docker rm kasm-dind
}

# VNC_USERNAME="kasm_user"
function up() {
	down
	internal_mkdir
	docker run -dit \
		--name=kasm-dind \
		--privileged \
		--hostname=kasmweb \
		--shm-size=512m \
		-p 6901:6901 \
		-p 2901:22 \
		-e VNC_PW=password \
		-v $(pwd)/data/docker:/var/lib/docker \
		-v $(pwd)/data/kasm-user:/home/kasm-user \
		ghcr.io/manprint/ubuntu-jammy-dind-vnc:latest
}

function help() {
	me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
	echo
	echo $DESC
	echo
	echo "List of functions in $YELLOW$me$RESET script: "
	echo
	list=$(declare -F | awk '{print $NF}' | sort | egrep -v "^_")
	for i in ${list[@]}
	do
		echo "Usage: $YELLOW./$me$RESET$RED $i $RESET"
	done
	echo
}

if [ "_$1" = "_" ]; then
	help
else
	"$@"
fi
