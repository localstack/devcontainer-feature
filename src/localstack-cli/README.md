
# LocalStack CLI (localstack-cli)

Installs the Localstack CLI along with needed dependencies and popular "local" tools.

## Example Usage

```json
"features": {
    "ghcr.io/localstack/devcontainer-feature/localstack-cli:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a Localstack CLI version. | string | latest |
| awslocal | Install awscli-local, a thin wrapper of AWS CLI for LocalStack. | boolean | false |
| cdklocal | Install aws-cdk-local, a thin wrapper of AWS CDK for LocalStack. | boolean | false |
| pulumilocal | Install pulumi-local, a thin wrapper of Pulumi for LocalStack. | boolean | false |
| samlocal | Install aws-sam-cli-local, a thin wrapper of AWS SAM CLI for LocalStack. | boolean | false |
| tflocal | Install terraform-local, a thin wrapper of Terraform for LocalStack. | boolean | false |
| installUsingPython | Install LocalStack CLI using Python instead of pipx | boolean | false |

Available versions of the Localstack CLI can be found here: https://pypi.org/project/localstack/.

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.

`cdklocal` option requires `npm` to be installed which is not handled by this feature. All other tools are installed by `pipx` which is installed via package manager or the Python installation. The latter can be combined with the Python feature.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/devcontainers/features/blob/main/src/localstack-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
