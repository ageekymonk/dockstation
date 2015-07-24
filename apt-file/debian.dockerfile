FROM debian:latest
MAINTAINER Ramz <ramzthecoder@gmail.com>

RUN apt-get update && apt-get install -y \
	apt-file \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-file update

ENTRYPOINT ["apt-file"]
