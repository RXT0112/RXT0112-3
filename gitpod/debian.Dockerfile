FROM debian:latest

# FIXME: Outputs `gitpod@ws-ce281d58-997b-44b8-9107-3f2da7feede3:/workspace/gitpod-tests1$` in terminal

# To avoid bricked workspaces (https://github.com/gitpod-io/gitpod/issues/1171)
ARG DEBIAN_FRONTEND=noninteractive

USER root

ENV LANG=en_US.UTF-8
ENV LC_ALL=C

# Add 'gitpod' user
RUN useradd \
	--uid 33333 \
	--create-home --home-dir /home/gitpod \
	--shell /bin/bash \
	--password gitpod \
	gitpod || exit 1

# APT management
RUN apt update \
  && apt upgrade -y \
  && apt dist-upgrade -y \
  && apt install -y shellcheck \
  && apt autoremove -y \
  && rm -r /var/lib/apt/lists/*

# Add nektos's act to test github actions, Thank You! <3
# NOTICE: Unable to build -> Disabled for now
RUN if ! command -v act >/dev/null; false; then \
  apt install -y golang-go git wget \
  && wget https://github.com/nektos/act/archive/v0.2.1.tar.gz \
  && make -C act install; fi
