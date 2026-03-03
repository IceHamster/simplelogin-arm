# SimpleLogin Multi-Arch (ARM64/AMD64)

This repository provides an automated build pipeline for **SimpleLogin**, specifically optimized for **ARM64** (Raspberry Pi, Apple Silicon, Ampere) and **AMD64** architectures. 

The primary goal is to provide a modern, multi-arch alternative to the official image while tracking upstream releases as closely as possible.



## 🚀 Key Features

* **Multi-Arch Support:** Built for `linux/amd64` and `linux/arm64` using Docker Buildx.
* **Upstream Sync:** Automatically tracks the latest [SimpleLogin](https://github.com/simple-login/app) versions via Renovate.
* **Optimized Build:** Uses [uv](https://github.com/astral-sh/uv) for lightning-fast Python dependency management and smaller layers.
* **Modern Base:** Built on Ubuntu 24.04 for the latest security patches and performance improvements.

---

## 🛠 Project Structure

* `Dockerfile`: Our custom, optimized build definition.
* `upstream-version.txt`: The source of truth for the SimpleLogin version. Renovate monitors this file.
* `.github/workflows/docker-publish.yml`: The CI/CD pipeline that builds and pushes images to GHCR.
* `build_local.sh`: A helper script for testing the build on your local machine.
* `.github/renovate.json`: Configuration for automated dependency and version tracking.

---

## 🤖 Automation Workflow

We use a "hands-off" approach to keep the image updated:

1.  **Detection:** [Renovate](https://github.com/renovatebot/renovate) monitors the SimpleLogin repository for new tags.
2.  **Pull Request:** When a new version is released, Renovate opens a PR updating `upstream-version.txt`.
3.  **Verification:** GitHub Actions triggers a "test build" on the PR (without pushing) to ensure the new version is compatible with our Dockerfile.
4.  **Deployment:** Once the PR is merged into `main`, the workflow builds the final images and pushes them to the **GitHub Container Registry (GHCR)**.

---

## 💻 Local Development

If you want to build the image locally using Podman or Docker:

```bash
# Ensure the script is executable
chmod +x build_local.sh

# Run the build
./build_local.sh
```

The script will automatically detect your host architecture, clone the version specified in upstream-version.txt, and create a local image named simplelogin:local.

## 🩹 Modern UI Patch

This repository includes an optional patch (`modern-ui.patch`) to apply the new, modern SimpleLogin user interface. 

### In CI/CD (GitHub Actions)
When running the workflow manually via `workflow_dispatch`, you can set the `apply_patch` parameter to `true`. By default, it builds the "original" upstream version. 

To make it the default for automated builds (on push), update the `APPLY_PATCH` environment variable in `.github/workflows/docker-publish.yml` to `true`.

### Local Build
To apply the patch during a local build, use the `--patch` flag:

```bash
./build_local.sh --patch
```
The resulting image will be tagged as `simplelogin:local-modern-ui`.

---

## Usage

To use this image in your docker-compose.yml, replace the official SimpleLogin image with your custom image hosted on GHCR: