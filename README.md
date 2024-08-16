# GitHub Self-Hosted Runner in Docker

This repository contains a Docker Compose configuration to set up a GitHub self-hosted runner in a Docker environment. The runner supports Docker-in-Docker (DIND) functionality, allowing you to run Docker commands within the runner container.

The Docker image used for the runner is available on Docker Hub at [https://hub.docker.com/r/safeimages/dind-runner](https://hub.docker.com/r/safeimages/dind-runner).

## Prerequisites

- Docker
- Docker Compose

## Usage

1. Clone the repository:

   ```bash
   git clone git@github.com:brnorg/safeimages-dind-runner.git
   cd your-repo
   ```

2. Update the environment variables in the `docker-compose.yml` file:

   - `TOKEN`: Your GitHub personal access token*(ghp_XXXXXX)* with the necessary permissions to register a self-hosted runner.
   - `ORG`: The GitHub organization name, or `REPO` if you want to register the runner for a specific repository.
   - `TAG`: The tags to be associated with the runner.

3. Start the Docker Compose setup:

   ```bash
   docker-compose up -d
   ```

   This will start the Docker-in-Docker (DIND) service and the self-hosted runner container.

4. See the runner on GitHub:

   - Go to your GitHub organization or repository settings.
   - See your new runner

5. Once the runner is registered, it will automatically start running any workflows that are triggered.

## Docker Compose Configuration

The `docker-compose.yml` file contains the following services:

1. `docker`:
   - This service runs the Docker-in-Docker (DIND) container, which provides the necessary Docker environment for the runner.
   - The container is run in privileged mode to allow it to manage the Docker daemon.
   - The Docker TLS certificates are stored in the `docker-certs-ca` and `docker-certs-client` volumes.

2. `dind-runner`:
   - This service runs the GitHub self-hosted runner container.
   - The runner container depends on the `docker` service to access the Docker daemon.
   - The environment variables are used to configure the runner with the necessary information (token, organization/repository, and tags).
   - The `docker-certs-client` volume is mounted read-only to provide the runner with the necessary TLS certificates to communicate with the Docker daemon.

The volumes and network are defined at the end of the `docker-compose.yml` file.

## Troubleshooting

If you encounter any issues, please check the logs of the containers:

```bash
docker-compose logs -f
```

You can also check the status of the runner on the GitHub Actions page for your organization or repository.
