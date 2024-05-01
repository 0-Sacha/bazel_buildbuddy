""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
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
    host_name = "%{host_name}",
    target_name = "%{target_name}",
    target_cpu = "%{target_cpu}",
    compiler = None,
    toolchain_bins = None,
    compiler_paths = {
        "cpp": "/usr/bin/cpp",
        "cc": "/usr/bin/gcc",
        "cxx": "/usr/bin/g++",
        "cov": "/usr/bin/gcov",
        "ar": "/usr/bin/ar",
        "ld": "/usr/bin/ld",
        "nm": "/usr/bin/nm",
        "objcopy": "/usr/bin/objcopy",
        "objdump": "/usr/bin/objdump",
        "strip": "/usr/bin/strip"
        "as": "/usr/bin/as",
        "size": "/usr/bin/size"
        "dwp": "/usr/bin/dwp",
    },
    flags = dicts.add(
        %{flags_packed},
        {
            "##cov": "--coverage",
            "##linkopts;copts":  "-no-canonical-prefixes;-fno-canonical-system-headers",
            "##linkopts/opt": "-Wl,--gc-sections",
            "##linkopts;copts/dbg": "-g",
            "##copts/dbg": "-g0;-O2;-ffunction-sections;-fdata-sections",
            "##defines/dbg": "-g0;-O2;-D_FORTIFY_SOURCE=1;-DNDEBUG;-ffunction-sections;-fdata-sections",
        }
    ),
    enable_features = [
        "supports_start_end_lib"    
    ],
    cxx_builtin_include_directories = [
        "/usr/lib/gcc/x86_64-linux-gnu/%{gcc_version}/include",
        "/usr/include/x86_64-linux-gnu/c++/%{gcc_version}",
        "/usr/include/c++/%{gcc_version}",
        "/usr/include/c++/%{gcc_version}/backward",
        "/usr/local/include",
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ],

    copts = [
        "-fstack-protector",
        "-Wall",
        "-Wunused-but-set-parameter",
        "-Wno-free-nonheap-object",
        "-fno-omit-frame-pointer",
        "-fno-canonical-system-headers",
        "-Wno-builtin-macro-redefined",
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\""
    ] + %{copts},
    conlyopts = %{conlyopts},
    cxxopts = %{cxxopts},
    linkopts = [
        "-fuse-ld=gold",
        "-B/usr/bin",
        "-Wl,-no-as-needed",
        "-Wl,-z,relro,-z,now",
        "-pass-exit-codes"
    ] + %{linkopts},
    defines = %{defines},
    includedirs = %{includedirs},
    linkdirs = %{linkdirs},

    toolchain_libs = [
        "-Wl,--push-state,-as-needed",
        "-lstdc++",
        "-Wl,--pop-state",
        "-Wl,--push-state,-as-needed",
        "-lm",
        "-Wl,--pop-state"
    ]
)

filegroup(name = "empty")

cc_toolchain(
    name = "cc_toolchain_%{toolchain_id}",
    toolchain_identifier = "%{toolchain_id}",
    toolchain_config = ":cc_toolchain_config_%{toolchain_id}",
    
    all_files = ":empty",
    compiler_files = ":empty",
    linker_files = ":empty",
    ar_files = ":empty",
    as_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    dwp_files = ":empty",
    coverage_files = ":empty",
    supports_param_files = 1,
    module_map = None,
)

toolchain(
    name = "toolchain_%{toolchain_id}",
    toolchain = ":cc_toolchain_%{toolchain_id}",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",

    exec_compatible_with = %{exec_compatible_with},
    target_compatible_with = %{target_compatible_with},
)
