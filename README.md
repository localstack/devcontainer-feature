# DevContainer Feature(s)
A collection of LocalStack related and managed Devcontainer Feature(s).

>**Features** are self-contained units of installation code and development container configuration.
Features are designed to install atop a wide-range of base container images (this repo focuses on debian based images).

> [!NOTE]
> This repo follows the [**proposed** DevContainer Feature distribution specification](https://containers.dev/implementors/features-distribution/).

## List of features
- [LocalStack](https://docs.localstack.cloud/getting-started/): install the LocalStack CLI tool and any of the related _Local™_ tools for:
    - AWS CLI
    - AWS CDK
    - AWS SAM CLI
    - Terraform
    - Pulumi

## Usage
To reference a feature from this repository, add the desired features to a `devcontainer.json`.
Each feature has a `README.md` that shows how to reference the feature and which options are available for that feature.

The example below installs the LocalStack CLI declared in the `./src` directory of this repository.

See the relevant feature's README for supported options.

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/localstack/feature/localstack-cli": {}
    }
}
```
## Repo and Feature Structure
Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.
Each feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`.

```
├── src
│   ├── hello
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── color
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
|   ├── ...
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
...
```
An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time.
Implementing tools are also free to process attributes under the `customizations` property as desired.