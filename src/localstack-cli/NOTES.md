Available versions of the Localstack CLI can be found here: https://pypi.org/project/localstack/.

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.

`cdklocal` option requires `npm` to be installed which is not handled by this feature.
All other tools are installed by `pipx` which is installed via package manager or the Python installation. The latter can be combined with the Python feature.

> [!NOTE]
> None of the wrapped tool(s) (ie Terraform, Pulumi or AWS CLI...etc), are handled by this feature, to install the underlying tool(s) please use the respective feature from the [DevContainer Feature Community Index](https://containers.dev/features).