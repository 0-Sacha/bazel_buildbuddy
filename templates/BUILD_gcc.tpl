""

load("@bazel_utilities//toolchains:cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

platform(
    name = "buildbuddy_%{host_name}",
    constraint_values = %{exec_compatible_with},
    exec_properties = {
        "OSFamily": "%{host_os_capitalize}",
        "dockerNetwork": "%{docker_network}",
        "container-image": "%{docker_container}"
    },
)

cc_toolchain_config(
    name = "cc_toolchain_config_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",

    compiler_type = "gcc",

    toolchain_paths = {
        "cpp": "/usr/bin/cpp",
        "cc": "/usr/bin/gcc",
        "cxx": "/usr/bin/g++",
        "cov": "/usr/bin/gcov",
        "ar": "/usr/bin/ar",
        "ld": "/usr/bin/ld",
        "nm": "/usr/bin/nm",
        "objcopy": "/usr/bin/objcopy",
        "objdump": "/usr/bin/objdump",
        "strip": "/usr/bin/strip",
        "as": "/usr/bin/as",
        "size": "/usr/bin/size",
        "dwp": "/usr/bin/dwp",
    },

    cxx_builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/%{gcc_version}/include",
        "/usr/include/x86_64-linux-gnu/c++/%{gcc_version}",
        "/usr/include/c++/%{gcc_version}",
        "/usr/include/c++/%{gcc_version}/backward",
        "/usr/local/include",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],

    copts = %{copts},
    conlyopts = %{conlyopts},
    cxxopts = %{cxxopts},
    linkopts = %{linkopts},
    defines = %{defines},
    includedirs = %{includedirs},
    linkdirs = %{linkdirs},

    toolchain_libs = %{toolchain_libs},
)

cc_toolchain(
    name = "cc_toolchain_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    toolchain_config = ":cc_toolchain_config_%{toolchain_id}",
    
    all_files = ":toolchain_every_files",
    compiler_files = ":toolchain_every_files",
    linker_files = ":toolchain_every_files",
    ar_files = ":toolchain_every_files",
    as_files = ":toolchain_every_files",
    objcopy_files = ":toolchain_every_files",
    strip_files = ":toolchain_every_files",
    dwp_files = ":toolchain_every_files",
    coverage_files = ":toolchain_every_files",

    # dynamic_runtime_lib
    # static_runtime_lib
    # supports_param_files
)

toolchain(
    name = "toolchain_%{toolchain_id}",
    toolchain = ":cc_toolchain_%{toolchain_id}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",

    exec_compatible_with = %{exec_compatible_with},
    target_compatible_with = %{target_compatible_with},
)


filegroup(
    name = "toolchain_every_files",
    srcs = [
        "%{toolchain_extras_filegroup}",
    ]
)
