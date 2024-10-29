[![bazel_buildbuddy](https://github.com/0-Sacha/bazel_buildbuddy/actions/workflows/buildbuddy.yml/badge.svg)](https://github.com/0-Sacha/bazel_buildbuddy/actions/workflows/buildbuddy.yml)

# bazel_buildbuddy

A Bazel module that configures a buildbuddy CI toolchain. using an Ubuntu 23.04 with gcc-14 and clang-18 installed (see the Dockerfile) for use of up to `c++23`.

## How to Use
MODULE.bazel
```python
# use the latest commit avaible
git_override(module_name="bazel_utilities", remote="https://github.com/0-Sacha/bazel_utilities.git", commit="7f6c3585c41278918428ed48d45b12413c197fc0")
bazel_dep(name = "bazel_utilities", version = "0.0.1")

buildbuddy_toolchain_extension = use_extension("@bazel_buildbuddy//:rules.bzl", "buildbuddy_toolchain_extension")
inject_repo(buildbuddy_toolchain_extension, "platforms", "bazel_utilities")
buildbuddy_toolchain_extension.buildbuddy_toolchain(name = "buildbuddy")
use_repo(buildbuddy_toolchain_extension, "buildbuddy")
register_toolchains("@buildbuddy//:gcc-toolchain")
```
It provide only the `gcc` toolchain for now `@<repo>//:gcc-toolchain`.
You can use these toolchains to compile any cc_rules in your project.
