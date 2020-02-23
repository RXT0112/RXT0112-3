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
  && if command -v curl >/dev/null; then apt install -y curl; fi \
  && apt dist-upgrade -y \
  && apt autoremove -y \
  && rm -r /var/lib/apt/lists/*

# Add nektos's act, Thank You! <3
RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
