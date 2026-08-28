# ============================================================================
#  Dockerfile — the base image for the devbox
# ----------------------------------------------------------------------------
#  Kept intentionally thin. The Features listed in devcontainer.json do most of
#  the tool installation (node, python, aws-cli, gh, ...). This file is where
#  you bake in anything Features do not cover, or pin things you care about.
#
#  The mcr "base" images ship a non-root `vscode` user already, which is what
#  devcontainer.json's remoteUser/containerUser point at.
#
#  Tags: https://hub.docker.com/r/microsoft/devcontainers-base
# ============================================================================
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# -- Extra OS packages (uncomment / extend) ---------------------------------
# Run as root for installs; the base image drops back to `vscode` afterwards.
# USER root
# RUN apt-get update \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get install -y --no-install-recommends \
#         jq \
#         ripgrep \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# -- Bake in your own tools here --------------------------------------------
# e.g. a CLI coding agent, extra runtimes, dotfiles bootstrap, etc.
# Prefer running user-level installs as the non-root user:
# USER vscode
# RUN curl -fsSL https://example.com/install.sh | sh

# The base image already leaves us as the non-root `vscode` user.
