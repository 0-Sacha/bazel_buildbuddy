""

load("@bazel_buildbuddy//:registry.bzl", "BUILDBUDDY_REGISTRY")
load("@bazel_utilities//toolchains:extras_filegroups.bzl", "filegroup_translate_to_starlark")
load("@bazel_utilities//toolchains:hosts.bzl", "get_host_infos_from_rctx", "split_host_name", "HOST_EXTENSION")
load("@bazel_utilities//toolchains:registry.bzl", "get_archive_from_registry")

def _buildbuddy_toolchain_impl(rctx):
    host_os, _, host_name = get_host_infos_from_rctx(rctx.os.name, rctx.os.arch)
    if rctx.attr.override_host_name != "" and rctx.attr.override_host_name != "local":
        host_os, _, host_name = split_host_name(rctx.attr.override_host_name)

    registry = json.decode(rctx.attr.registry_json)
    archive = get_archive_from_registry(registry, "BuildBuddy", rctx.attr.version)

    substitutions = {
        "%{rctx_name}": rctx.name,
        "%{rctx_path}": "external/{}/".format(rctx.name),
        "%{extension}": HOST_EXTENSION[host_os],
        "%{host_name}": host_name,
        "%{toolchain_id}": "buildbuddy_{}".format(rctx.attr.version),
        "%{gcc_version}": archive["details"]["gcc_version"],
        "%{clang_version}": archive["details"]["clang_version"],

        "%{host_os_capitalize}": host_os.capitalize(),
        "%{docker_network}": "off",
        "%{docker_container}": archive["details"]["docker_container"],

        "%{exec_compatible_with}": json.encode(rctx.attr.exec_compatible_with),
        "%{target_compatible_with}": json.encode(rctx.attr.target_compatible_with),

        "%{toolchain_builtin_includedirs_isystem}": json.encode(rctx.attr.toolchain_builtin_includedirs_isystem),
        "%{toolchain_builtin_includedirs}": json.encode(rctx.attr.toolchain_builtin_includedirs),

        "%{copts}": json.encode(rctx.attr.copts),
        "%{conlyopts}": json.encode(rctx.attr.conlyopts),
        "%{cxxopts}": json.encode(rctx.attr.cxxopts),
        "%{linkopts}": json.encode(rctx.attr.linkopts),
        "%{defines}": json.encode(rctx.attr.defines),
        "%{includedirs}": json.encode(rctx.attr.includedirs),
        "%{linkdirs}": json.encode(rctx.attr.linkdirs),
        "%{linklibs}": json.encode(rctx.attr.linklibs),
        # dbg / opt
        "%{dbg_copts}": json.encode(rctx.attr.dbg_copts),
        "%{dbg_linkopts}": json.encode(rctx.attr.dbg_linkopts),
        "%{opt_copts}": json.encode(rctx.attr.opt_copts),
        "%{opt_linkopts}": json.encode(rctx.attr.opt_linkopts),

        "%{toolchain_extras_filegroups}": json.encode(filegroup_translate_to_starlark(rctx.attr.toolchain_extras_filegroups)),
    }
    rctx.template(
        "BUILD.bazel",
        Label("//templates:BUILD.bazel.tpl"),
        substitutions
    )

buildbuddy_toolchain = repository_rule(
    implementation = _buildbuddy_toolchain_impl,
    attrs = {
        'override_host_name': attr.string(default = ""),

        'version': attr.string(default = "latest"),
        'registry_json': attr.string(default = json.encode(BUILDBUDDY_REGISTRY)),

        'exec_compatible_with': attr.string_list(default = []),
        'target_compatible_with': attr.string_list(default = []),

        'toolchain_builtin_includedirs_isystem': attr.string_list(default = []),
        'toolchain_builtin_includedirs': attr.string_list(default = []),

        'copts': attr.string_list(default = []),
        'conlyopts': attr.string_list(default = []),
        'cxxopts': attr.string_list(default = []),
        'linkopts': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'includedirs': attr.string_list(default = []),
        'linkdirs': attr.string_list(default = []),
        'linklibs': attr.string_list(default = []),
        # dbg / opt
        'dbg_copts': attr.string_list(default = []),
        'dbg_linkopts': attr.string_list(default = []),
        'opt_copts': attr.string_list(default = []),
        'opt_linkopts': attr.string_list(default = []),
    
        'toolchain_extras_filegroups': attr.label_list(default = []),
    },
)

def _buildbuddy_toolchain_extension_impl(module_ctx):
    for mod in module_ctx.modules:
        for toolchain in mod.tags.buildbuddy_toolchain:
            buildbuddy_toolchain(
                name = toolchain.name,

                exec_compatible_with = toolchain.exec_compatible_with,
                target_compatible_with = toolchain.target_compatible_with,

                toolchain_builtin_includedirs_isystem = toolchain.toolchain_builtin_includedirs_isystem,
                toolchain_builtin_includedirs = toolchain.toolchain_builtin_includedirs,
                
                copts = toolchain.copts,
                conlyopts = toolchain.conlyopts,
                cxxopts = toolchain.cxxopts,
                linkopts = toolchain.linkopts,
                defines = toolchain.defines,
                includedirs = toolchain.includedirs,
                linkdirs = toolchain.linkdirs,
                linklibs = toolchain.linklibs,
                # dbg / opt
                dbg_copts = toolchain.dbg_copts,
                dbg_linkopts = toolchain.dbg_linkopts,
                opt_copts = toolchain.opt_copts,
                opt_linkopts = toolchain.opt_linkopts,

                toolchain_extras_filegroups = toolchain.toolchain_extras_filegroups,

                override_host_name = toolchain.override_host_name,
            )
    
buildbuddy_toolchain_extension = module_extension(
    implementation = _buildbuddy_toolchain_extension_impl,
    tag_classes = {
        "buildbuddy_toolchain": tag_class(attrs = {
            'override_host_name': attr.string(default = "local"),
            
            'name': attr.string(mandatory = True),

            'exec_compatible_with': attr.string_list(default = []),
            'target_compatible_with': attr.string_list(default = []),

            'toolchain_builtin_includedirs_isystem': attr.string_list(default = []),
            'toolchain_builtin_includedirs': attr.string_list(default = []),

            'copts': attr.string_list(default = []),
            'conlyopts': attr.string_list(default = []),
            'cxxopts': attr.string_list(default = []),
            'linkopts': attr.string_list(default = []),
            'defines': attr.string_list(default = []),
            'includedirs': attr.string_list(default = []),
            'linkdirs': attr.string_list(default = []),
            'linklibs': attr.string_list(default = []),
            # dbg / opt
            'dbg_copts': attr.string_list(default = []),
            'dbg_linkopts': attr.string_list(default = []),
            'opt_copts': attr.string_list(default = []),
            'opt_linkopts': attr.string_list(default = []),
        
            'toolchain_extras_filegroups': attr.label_list(default = []),
        }),
    },
)
