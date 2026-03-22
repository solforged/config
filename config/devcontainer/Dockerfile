FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Core dev tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git jq ripgrep fd-find tree \
    && rm -rf /var/lib/apt/lists/*

# Claude Code settings: bypass all permission prompts inside the sandbox
COPY settings.json /tmp/claude-settings.json
