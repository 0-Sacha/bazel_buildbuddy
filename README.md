[![bazel_buildbuddy](https://github.com/0-Sacha/bazel_buildbuddy/actions/workflows/buildbuddy.yml/badge.svg)](https://github.com/0-Sacha/bazel_buildbuddy/actions/workflows/buildbuddy.yml)

# bazel_buildbuddy

A Bazel module that configure a buildbuddy CI toolchain. using an Ubuntu 23.04 with gcc-14 and clang-18 installed (see the Dockerfile) for use of up to `c++23`.
Probably not needed if you don't need a recent `ubuntu image`, see [linux-image-configuration](https://www.buildbuddy.io/docs/workflows-config/#linux-image-configuration)

## How to Use
#### MODULE.bazel
```python
bazel_dep(name = "rules_cc", version = "0.0.10")
bazel_dep(name = "platforms", version = "0.0.10")

# use the latest commit avaible
git_override(module_name="bazel_utilities", remote="https://github.com/0-Sacha/bazel_utilities.git", commit="1c3c6c01dcccc6c922c4955c92aa7c3c015a9d1c")
git_override(module_name="bazel_buildbuddy", remote="https://github.com/0-Sacha/bazel_buildbuddy.git", commit="a2fd3aff972d23d9c0c8acaa5bdf6f6d8828b5ac")

bazel_dep(name = "bazel_utilities", version = "0.0.1", dev_dependency = True)
bazel_dep(name = "bazel_buildbuddy", dev_dependency = True)

buildbuddy_toolchain_extension = use_extension("@bazel_buildbuddy//:rules.bzl", "buildbuddy_toolchain_extension", dev_dependency = True)
inject_repo(buildbuddy_toolchain_extension, "platforms", "bazel_utilities")
buildbuddy_toolchain_extension.buildbuddy_toolchain(name = "buildbuddy")
use_repo(buildbuddy_toolchain_extension, "buildbuddy")
#register_toolchains("@buildbuddy//:gcc-toolchain")
```
It provide only the `gcc` toolchain for now `@<repo>//:gcc-toolchain`.
You can use these toolchains to compile any cc_rules in your project.

#### Workspace status
You will need to add your `buildbuddy.yaml` config file to define your pipeline, see `buildbuddy.template`.
Buildbuddy needs to knows informations about your repo, like the branch name. To do this you can copy the folder `.buildbuddy` containing the scripts to send thoses info.
To link this correctly you may need to follow the `.bazelrc.template` provided file:
```
common:buildbuddy --extra_execution_platforms=@buildbuddy//:platform
common:buildbuddy --extra_toolchains=@buildbuddy//:gcc-toolchain
common:buildbuddy --platforms=@buildbuddy//:platform
```
The `register_toolchains` is only needed if your not registering the toolchain `register_toolchains("@buildbuddy//:gcc-toolchain")` like above.

! Don't forget to set the scripts inside `.buildbuddy` as executable:
```
git update-index --chmod=+x .\.buildbuddy\workspace_status.ps1
git update-index --chmod=+x .\.buildbuddy\workspace_status.bat
git update-index --chmod=+x .\.buildbuddy\workspace_status.sh
```
