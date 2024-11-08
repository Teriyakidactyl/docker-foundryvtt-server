
# Docker Foundry VTT Server Image

This Docker image provides a Foundry Virtual Tabletop (Foundry VTT) dedicated server, supporting both **`amd64`** and **`arm64`** (x86, arm) architectures.

![Foundry VTT Logo](/images/fvtt_teriyaki.png)

## Features

- Supports `amd64` and `arm64` architectures
- Runs under non-root user (`node` user)

## Environment Variables

Configure your Foundry VTT server using the following environment variables:

- `NODE_IMAGE_VERSION`: The version of the Node.js Docker image to use as the base (default: `latest`). Generally follows [these tags](https://hub.docker.com/_/node).
- `FOUNDRY_RELEASE_URL`: The URL to the Foundry VTT release package (default: empty, latest version will be used). Relies on the [Timed Link](https://foundryvtt.com/article/installation/) concept of install.
- `DATA_PATH`: The path to store your Foundry VTT data (default: `/data`).

## Usage

1. Pull the image:

   ```bash
   docker pull ghcr.io/teriyakidactyl/docker-foundry-vtt-server:latest
   ```

2. Run the container:

   ```bash
   FVTT_DATA_PATH="/path/to/your/fvtt/data"
   mkdir -p $FVTT_DATA_PATH
   docker run -d \
   -e FOUNDRY_RELEASE_URL="https://example.com/foundryvtt.zip" \
   -v $FVTT_DATA_PATH:/data \
   -p 30000:30000/tcp \
   --name Foundry-VTT-Server \
   ghcr.io/teriyakidactyl/docker-foundry-vtt-server:latest
   ```

   Replace `FVTT_DATA_PATH="/path/to/your/fvtt/data"` with the path where you want to store your Foundry VTT data.

## Building the Image

To build the image yourself:

```docker
docker build -t ghcr.io/teriyakidactyl/docker-foundry-vtt-server:latest .
```

## Support

For issues, feature requests, or contributions, please use the GitHub issue tracker.