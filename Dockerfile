# //////////////////////////////////////////////////////////////////////////////////// #

FROM debian:trixie-slim AS base

# //////////////////////////////////////////////////////////////////////////////////// #

ARG USERNAME=vscode

ARG USER_UID=1000

ARG USER_GID=${USER_UID}

# //////////////////////////////////////////////////////////////////////////////////// #

# Install essential OS packages:
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# //////////////////////////////////////////////////////////////////////////////////// #

# Install uv Python tooling from Astral.sh:
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# //////////////////////////////////////////////////////////////////////////////////// #

FROM base AS development

# Install starship bash prompt for the non-root user:
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Add a group for a non-root user to be created later:
RUN groupadd --gid ${USER_GID} ${USERNAME}

# Add a non-root user to the group:
RUN useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Set the non-root user as the default user:
USER ${USERNAME}

# Set the working directory to the non-root user's home directory:
WORKDIR /home/${USERNAME}

# Ensure Python user base's binary directory is in PATH:
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# //////////////////////////////////////////////////////////////////////////////////// #

# Ensure starship initialises on shell start:
RUN echo 'eval "$(starship init bash)"' >> /home/${USERNAME}/.bashrc

# //////////////////////////////////////////////////////////////////////////////////// #