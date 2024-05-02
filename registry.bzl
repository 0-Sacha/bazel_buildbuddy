"""Buildbuddy registry
"""

load("@bazel_utilities//toolchains:registry.bzl", "gen_archives_registry")

VERSION_1_0 = {
    "toolchain": "BuildBuddy",
    "version": "1.0",
    "latest": True,
    "details": {
        "docker_container": "docker://docker.io/sachabellier/buildbuddy-rbe-images:latest",
        "gcc_version": "12",
        "clang_version": "14",
    }
}

BUILDBUDDY_REGISTRY = gen_archives_registry([
    VERSION_1_0
])