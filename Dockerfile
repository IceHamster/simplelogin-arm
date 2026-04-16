# syntax=docker/dockerfile:1@sha256:2780b5c3bab67f1f76c781860de469442999ed1a0d7992a5efdf2cffc0e3d769

ARG NODE_VERSION=10.17.0
# renovate: datasource=github-releases packageName=astral-sh/uv
ARG UV_VERSION=0.11.3

# Stage 1: Build frontend assets
FROM node:${NODE_VERSION}-alpine AS npm
WORKDIR /code
COPY ./static/package*.json /code/static/
RUN cd /code/static && npm ci

# Stage 2: Fetch uv
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv_source

# Stage 3: Builder
FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b AS builder

# 1. Set a fixed location for the python installation
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    UV_LINK_MODE=copy \
    UV_PYTHON_INSTALL_DIR="/python"

WORKDIR /code

COPY --from=uv_source /uv /usr/bin/uv
COPY pyproject.toml uv.lock .python-version ./

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential python3-dev pkg-config cmake ninja-build clang gcc libre2-dev git ca-certificates

# 2. uv will now install python into /python
RUN uv python install && \
    uv sync --no-dev --no-cache

# Stage 4: Final Runtime Image
FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

WORKDIR /code

# 3. Copy the Python installation AND the venv
COPY --from=builder /python /python
COPY --from=builder /code/.venv /code/.venv

ENV PATH="/code/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    netcat-traditional ca-certificates libre2-10 gnupg && \
    rm -rf /var/lib/apt/lists/*

COPY . .
COPY --from=npm /code /code

EXPOSE 7777
CMD ["gunicorn", "wsgi:app", "-b", "0.0.0.0:7777", "-w", "2", "--timeout", "15"]