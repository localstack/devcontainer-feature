
# LocalStack CLI (lstk) (localstack-cli)

Installs lstk, the LocalStack CLI. lstk starts and manages LocalStack and runs the AWS CLI, Terraform, AWS CDK and AWS SAM against it.

## Example Usage

```json
"features": {
    "ghcr.io/localstack/devcontainer-feature/localstack-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter an lstk version (see https://github.com/localstack/lstk/releases). | string | latest |
| pulumilocal | Install pulumi-local (pulumilocal), the LocalStack wrapper for Pulumi. lstk has no Pulumi command. Installs pipx and Python. | boolean | false |

This Feature installs [`lstk`](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/), the LocalStack CLI, from its [GitHub releases](https://github.com/localstack/lstk/releases).
The download is checked against the release checksums.
Bash, zsh and fish completions and man pages are installed too.

## Using lstk in the container

`lstk` needs a Docker daemon to start LocalStack.
Add the `docker-in-docker` or `docker-outside-of-docker` Feature, or use one of the [LocalStack DevContainer Templates](https://github.com/localstack/devcontainer-template).

Pass your [auth token](https://docs.localstack.cloud/aws/getting-started/auth-token/) from the host:

```json
"remoteEnv": {
    "LOCALSTACK_AUTH_TOKEN": "${localEnv:LOCALSTACK_AUTH_TOKEN}"
}
```

You can also run `lstk login` in a container terminal.

`lstk start` refuses to run when `AWS_ENDPOINT_URL` or `LSTK_ENDPOINT_URL` is set, because those variables tell `lstk` to target an emulator it does not manage.
Set them only when LocalStack runs outside the container, for example as a Docker Compose service.

## Tool integrations

`lstk` replaces the `awslocal`, `tflocal`, `cdklocal` and `samlocal` wrapper scripts.
It does not install the underlying tools. Add the matching Feature for each one you use:

| Command | Replaces | Feature for the underlying tool |
| --- | --- | --- |
| `lstk aws` | `awslocal` | `ghcr.io/devcontainers/features/aws-cli:1` |
| `lstk terraform`, `lstk tf` | `tflocal` | `ghcr.io/devcontainers/features/terraform:1` |
| `lstk cdk` | `cdklocal` | `ghcr.io/devcontainers-extra/features/aws-cdk:2` (CDK 2.177.0 or newer) |
| `lstk sam` | `samlocal` | `ghcr.io/customink/codespaces-features/sam-cli:1` (SAM CLI 1.95.0 or newer) |

There is no `lstk` command for Pulumi.
Set `pulumilocal: true` to install the [`pulumi-local`](https://github.com/localstack/pulumi-local) wrapper with `pipx`, and add `ghcr.io/devcontainers-extra/features/pulumi:1` for Pulumi itself.
This is the only option that pulls in Python.

## Migrating from 0.x

Version 1.0.0 of this Feature drops the legacy Python `localstack` CLI and the `awslocal`, `cdklocal`, `samlocal`, `tflocal` and `installUsingPython` options.
The `version` option now selects an `lstk` release.
See the [lstk migration guide](https://docs.localstack.cloud/aws/developer-tools/running-localstack/lstk/migration/) for the command mapping.

If you still need the legacy CLI, pin the old major version: `ghcr.io/localstack/devcontainer-feature/localstack-cli:0`.

## OS support

The Feature works on Debian, Ubuntu and Alpine based images on `amd64` and `arm64`.
It installs `curl`, `tar`, `gzip` and `ca-certificates` when they are missing, and `pipx` when `pulumilocal` is enabled.
`bash` is required to run `install.sh`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/localstack/devcontainer-feature/blob/main/src/localstack-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
