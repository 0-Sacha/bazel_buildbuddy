""

load("@bazel_utilities//toolchains:extras_filegroups.bzl", "filegroup_translate_to_starlark")
load("@bazel_buildbuddy//:registry.bzl", "BUILDBUDDY_REGISTRY")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx", "HOST_EXTENSION")
load("@bazel_utilities//toolchains:registry.bzl", "get_archive_from_registry")
load("@bazel_skylib//lib:sets.bzl", "sets")

def _buidbuddy_toolchain_impl(rctx):
    host_os, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)

    registry = json.decode(rctx.attr.registry_json)
    archive = get_archive_from_registry(registry, "BuildBuddy", rctx.attr.version)

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{rctx_path}": "external/{}/".format(rctx.name),
        "%{extention}": HOST_EXTENSION[host_os],
        "%{host_name}": host_name,
        "%{toolchain_id}": "buildbuddy_{}".format(compiler_version),
        "%{gcc_version}": archive["details"]["gcc_version"]
        "%{clang_version}": archive["details"]["clang_version"]

        "%{host_os_capitalize}": host_os.capitalize(),
        "%{docker_network}": "off",
        "%{docker_container}": archive["details"]["docker_container"],

        "%{exec_compatible_with}": json.encode(rctx.attr.exec_compatible_with),
        "%{target_compatible_with}": json.encode(rctx.attr.target_compatible_with),

        "%{copts}": json.encode(rctx.attr.copts),
        "%{conlyopts}": json.encode(rctx.attr.conlyopts),
        "%{cxxopts}": json.encode(rctx.attr.cxxopts),
        "%{linkopts}": json.encode(rctx.attr.linkopts),
        "%{defines}": json.encode(rctx.attr.defines),
        "%{includedirs}": json.encode(rctx.attr.includedirs),
        "%{linkdirs}": json.encode(rctx.attr.linkdirs),
        "%{linklibs}": json.encode(rctx.attr.linklibs),

        "%{toolchain_extras_filegroups}": json.encode(filegroup_translate_to_starlark(rctx.attr.toolchain_extras_filegroups)),
    }
    rctx.template(
        "BUILD.bazel",
        Label("//templates:BUILD.bazel.tpl"),
        substitutions
    )

_buildbuddy_toolchain = repository_rule(
    implementation = _buidbuddy_toolchain_impl,
    attrs = {
        'registry_json': attr.string(mandatory = True),

        'exec_compatible_with': attr.string_list(default = []),
        'target_compatible_with': attr.string_list(default = []),

        'copts': attr.string_list(default = []),
        'conlyopts': attr.string_list(default = []),
        'cxxopts': attr.string_list(default = []),
        'linkopts': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'includedirs': attr.string_list(default = []),
        'linkdirs': attr.string_list(default = []),
        'linklibs': attr.string_list(default = []),
    
        'toolchain_extras_filegroups': attr.label_list(default = []),
    },
)

def buildbuddy_toolchain(
        name,
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
        linklibs = [],

        toolchain_extras_filegroups = [],
        
        registry = BUILDBUDDY_REGISTRY,
    ):
    """arm Toolchain

    This macro create a repository containing all files needded to get an hermetic toolchain

    Args:
        name: Name of the repo that will be created
        
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
        linklibs: linklibs

        toolchain_extras_filegroups: filegroup added to the cc_toolchain rule to get access to thoses files when sandboxed

        registry: The registry to use
    """


    _buildbuddy_toolchain(
        name = name,
        registry_json = json.encode(registry),

        exec_compatible_with = exec_compatible_with,
        target_compatible_with = target_compatible_with,

        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
        defines = defines,
        includedirs = includedirs,
        linkdirs = linkdirs,
        linklibs = linklibs,

        toolchain_extras_filegroups = toolchain_extras_filegroups,
    )


def _buildbuddy_toolchain_extension_impl(module_ctx):
    for mod in module_ctx.modules:
        for toolchain in mod.tags.buildbuddy_toolchain:
            buildbuddy_toolchain(
                name = toolchain.name,
                registry_json = toolchain.registry_json,

                exec_compatible_with = toolchain.exec_compatible_with,
                target_compatible_with = toolchain.target_compatible_with,
                
                copts = toolchain.copts,
                conlyopts = toolchain.conlyopts,
                cxxopts = toolchain.cxxopts,
                linkopts = toolchain.linkopts,
                defines = toolchain.defines,
                includedirs = toolchain.includedirs,
                linkdirs = toolchain.linkdirs,
                linklibs = toolchain.linklibs,

                toolchain_extras_filegroups = toolchain.toolchain_extras_filegroups,
            )
    
buildbuddy_toolchain_extension = module_extension(
    implementation = _buildbuddy_toolchain_extension_impl,
    tag_classes = {
        "buildbuddy_toolchain": tag_class(attrs = {
            'name': attr.string(mandatory = True),

            'exec_compatible_with': attr.string_list(default = []),
            'target_compatible_with': attr.string_list(default = []),

            'copts': attr.string_list(default = []),
            'conlyopts': attr.string_list(default = []),
            'cxxopts': attr.string_list(default = []),
            'linkopts': attr.string_list(default = []),
            'defines': attr.string_list(default = []),
            'includedirs': attr.string_list(default = []),
            'linkdirs': attr.string_list(default = []),
            'linklibs': attr.string_list(default = []),
        
            'toolchain_extras_filegroups': attr.label_list(default = []),
        }),
    },
)
