"""
Build supporting tools.

The tools subpackage is used to define build rules and configurations for tools
used throughout the repository. Firstparty tools not required for build support
should live elsewhere.

Of special note is that we're using the `bazel_env.bzl` tool to re-export tools
used under Bazel as a `bin/` tree which can be added to the `$PATH`. The
included `.envrc` automates this for you.

"""

load("@bazel_env.bzl", "bazel_env")
load("@bazelrc-preset.bzl", "bazelrc_preset")
load("@multitool//:tools.bzl", MULTITOOL_TOOLS = "TOOLS")
load("@rules_ruby//ruby:defs.bzl", "rb_binary")
load("@rules_ruby//ruby:proto.bzl", "rb_grpc_protoc_plugin_toolchain")

package(default_visibility = ["//visibility:public"])

bazelrc_preset(
    name = "preset",
    doc_link_template = "https://registry.build/flag/bazel?filter={flag}",
)

bazel_env(
    name = "bazel_env",
    toolchains = {
    },
    tools = {
        # Mapping from tool binary name ($PATH entry) to Bazel label
        "buildifier": "@buildifier_prebuilt//:buildifier",
        "format": "//tools/format:format",
        "bundle": "@ruby//:bundle",
        "gem": "@ruby//:gem",
        "ruby": "@ruby",
    } | MULTITOOL_TOOLS,
)

rb_binary(
    name = "grpc_tools_ruby_protoc_plugin",
    main = "@bundle//bin:grpc_tools_ruby_protoc_plugin",
    deps = ["@bundle"],
)

rb_grpc_protoc_plugin_toolchain(
    name = "grpc_protoc_plugin",
    grpc_plugin = ":grpc_tools_ruby_protoc_plugin",
)
