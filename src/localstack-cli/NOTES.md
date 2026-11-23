Installs [lstk](https://github.com/localstack/lstk), the LocalStack CLI built in Go. Available versions can be found here: https://github.com/localstack/lstk/releases.

lstk replaces both the Python `localstack` CLI and the separate `awslocal`, `cdklocal`, `samlocal` and `tflocal` wrappers: run `lstk` to start LocalStack, and `lstk aws`, `lstk cdk`, `lstk sam` or `lstk terraform` to send commands to it with the endpoint, credentials and region already set.

lstk is downloaded from its GitHub releases (linux `amd64` and `arm64`) and checked against the release checksums.

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.

> [!NOTE]
> The tools that lstk proxies (AWS CLI, AWS CDK, AWS SAM CLI or Terraform) are not handled by this feature. To install them, use the respective feature from the [DevContainer Feature Community Index](https://containers.dev/features).