""

load("@bazel_buildbuddy//:registry.bzl", "BUILDBUDDY_REGISTRY")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx", "HOST_EXTENTION")
load("@bazel_utilities//toolchains:registry.bzl", "get_archive_from_registry")

def _buidbuddy_toolchain_impl(rctx):
    host_os, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    compiler_version = rctx.attr.gcc_version
    if rctx.attr.compiler == "clang":
        compiler_version = rctx.attr.clang_version

    toolchain_id = "buildbuddy_{}_{}".format(rctx.attr.compiler, compiler_version)

    toolchain_extras_filegroup = "@{}//{}:{}".format(
        rctx.attr.toolchain_extras_filegroup.repo_name,
        rctx.attr.toolchain_extras_filegroup.package,
        rctx.attr.toolchain_extras_filegroup.name,
    )

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{rctx_path}": "external/{}/".format(rctx.name),
        "%{extention}": HOST_EXTENTION[host_os],
        "%{host_name}": host_name,
        "%{toolchain_id}": toolchain_id,
        "%{gcc_version}": rctx.attr.gcc_version,
        "%{clang_version}": rctx.attr.clang_version,

        "%{host_os_capitalize}": host_os.capitalize(),
        "%{docker_network}": "off",
        "%{docker_container}": "docker://docker.io/sachabellier/buildbuddy-rbe-images:latest",

        "%{exec_compatible_with}": json.encode(rctx.attr.exec_compatible_with),
        "%{target_compatible_with}": json.encode(rctx.attr.target_compatible_with),

        "%{copts}": json.encode(rctx.attr.copts),
        "%{conlyopts}": json.encode(rctx.attr.conlyopts),
        "%{cxxopts}": json.encode(rctx.attr.cxxopts),
        "%{linkopts}": json.encode(rctx.attr.linkopts),
        "%{defines}": json.encode(rctx.attr.defines),
        "%{includedirs}": json.encode(rctx.attr.includedirs),
        "%{linkdirs}": json.encode(rctx.attr.linkdirs),
        "%{toolchain_libs}": json.encode(rctx.attr.toolchain_libs),

        "%{toolchain_extras_filegroup}": toolchain_extras_filegroup,
    }
    rctx.template(
        "BUILD",
        Label("//templates:BUILD_{}.tpl".format(rctx.attr.compiler)),
        substitutions
    )

_buildbuddy_toolchain = repository_rule(
    implementation = _buidbuddy_toolchain_impl,
    attrs = {
        'compiler': attr.string(default = "gcc"),
        'gcc_version': attr.string(mandatory = True),
        'clang_version': attr.string(mandatory = True),
        'docker_container': attr.string(mandatory = True),

        'exec_compatible_with': attr.string_list(default = []),
        'target_compatible_with': attr.string_list(default = []),

        'copts': attr.string_list(default = []),
        'conlyopts': attr.string_list(default = []),
        'cxxopts': attr.string_list(default = []),
        'linkopts': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'includedirs': attr.string_list(default = []),
        'linkdirs': attr.string_list(default = []),
        'toolchain_libs': attr.string_list(default = []),
    
        'toolchain_extras_filegroup': attr.label(),
    },
    local = False,
)

def buildbuddy_toolchain(
        name,
        compiler = "gcc",
        version = "latest",

        exec_compatible_with = [],
        target_compatible_with = [],

        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
        defines = [],
        includedirs = [],
        linkdirs = [],
        toolchain_libs = [],

        toolchain_extras_filegroup = "@bazel_utilities//:empty",
        
        registry = BUILDBUDDY_REGISTRY,

        auto_register_toolchain = True
    ):
    """arm Toolchain

    This macro create a repository containing all files needded to get an hermetic toolchain

    Args:
        name: Name of the repo that will be created
        
        compiler:
        version: 

        exec_compatible_with: The exec_compatible_with list for the toolchain
        target_compatible_with: The target_compatible_with list for the toolchain

        copts: copts
        conlyopts: conlyopts
        cxxopts: cxxopts
        linkopts: linkopts
        defines: defines
        includedirs: includedirs
        linkdirs: linkdirs
        toolchain_libs: toolchain_libs

        toolchain_extras_filegroup: filegroup added to the cc_toolchain rule to get access to thoses files when sandboxed

        registry: The registry to use

        auto_register_toolchain: If the toolchain is registered to bazel using `register_toolchains`
    """

    archive = get_archive_from_registry(registry, "BuildBuddy", version)

    _buildbuddy_toolchain(
        name = name,
        compiler = compiler,
        gcc_version = archive["details"]["gcc_version"],
        clang_version = archive["details"]["clang_version"],
        docker_container = archive["details"]["docker_container"],

        exec_compatible_with = exec_compatible_with,
        target_compatible_with = target_compatible_with,

        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
        defines = defines,
        includedirs = includedirs,
        linkdirs = linkdirs,
        toolchain_libs = toolchain_libs,

        toolchain_extras_filegroup = toolchain_extras_filegroup,
    )
    
    if auto_register_toolchain:
        compiler_version = archive["details"]["gcc_version"]
        if compiler == "clang":
            compiler_version = archive["details"]["clang_version"]

        native.register_toolchains("@{}//:toolchain_buildbuddy_{}_{}".format(name, compiler, compiler_version))
