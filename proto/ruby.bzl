"""Ruby proto generation aspect for rules_ruby.

This file is loaded by `rules_ruby` (see its `rb_library` implementation) using
`@@//proto:ruby.bzl`, so it must remain in this workspace at `proto/ruby.bzl`.
"""

load("@protobuf//bazel/common:proto_info.bzl", "ProtoInfo")
load("@rules_ruby//ruby/private:providers.bzl", "RubyFilesInfo")

PROTO_TOOLCHAIN = "@protobuf//bazel/private:proto_toolchain_type"
RUBY_OUTPUT_FILE = "{proto_file_basename}_pb.rb"
RUBY_SERVICE_OUTPUT_FILE = "{proto_file_basename}_services_pb.rb"

def _ruby_proto_aspect_impl(target, ctx):
    if not ProtoInfo in target:
        return []

    # Use Bazel 9 feature to have a dynamic dependency graph based on file contents
    has_services = ctx.actions.declare_directory(target.label.name + ".has_services")
    ctx.actions.run_shell(
        # TODO: write a more robust parser maybe with tree-sitter
        command = "mkdir -p {out_dir}; touch {out_dir}/has_messages; grep -q 'service' {proto_files} && touch {out_dir}/services".format(
            out_dir = has_services.path,
            proto_files = " ".join([p.path for p in target[ProtoInfo].direct_sources]),
        ),
        inputs = target[ProtoInfo].direct_sources,
        outputs = [has_services],
    )

    proto_info = ctx.toolchains[PROTO_TOOLCHAIN].proto
    proto_srcs = target[ProtoInfo].direct_sources
    proto_deps = target[ProtoInfo].transitive_sources
    outputs = []
    for src in proto_srcs:
        proto_file_basename = src.basename.replace(".proto", "")
        msg_output = ctx.actions.declare_file(RUBY_OUTPUT_FILE.format(proto_file_basename = proto_file_basename))
        service_output = ctx.actions.declare_file(RUBY_SERVICE_OUTPUT_FILE.format(proto_file_basename = proto_file_basename))
        ctx.actions.run_shell(
            # https://grpc.io/docs/languages/ruby/basics/#generating-client-and-server-code
            # grpc_tools_ruby_protoc -I ../../protos --ruby_out=../lib --grpc_out=../lib ../../protos/route_guide.proto
            command = "{protoc} --plugin=protoc-gen-grpc={grpc} --ruby_out={bindir} --grpc_out={bindir} {sources}".format(
                protoc = proto_info.proto_compiler.executable.path,
                sources = " ".join([p.path for p in proto_srcs]),
                grpc = ctx.executable._grpc_ruby_plugin.path,
                bindir = ctx.bin_dir.path,
            ),
            tools = [ctx.executable._grpc_ruby_plugin, proto_info.proto_compiler],
            inputs = depset(proto_srcs + [has_services], transitive = [proto_deps]),
            outputs = [msg_output, service_output],
        )
        outputs.append(msg_output)
        outputs.append(service_output)
    return [
        DefaultInfo(
            files = depset(
                outputs,
            ),
        ),
        RubyFilesInfo(
            transitive_srcs = depset(outputs),
            transitive_deps = depset(),
            transitive_data = depset(),
            bundle_env = {},
        ),
    ]

ruby_proto_aspect = aspect(
    implementation = _ruby_proto_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_grpc_ruby_plugin": attr.label(
            default = "@grpc//src/compiler:grpc_ruby_plugin",
            executable = True,
            cfg = "exec",
        ),
        "_bundle_env": attr.label(
            default = "@bundle",
        ),
    },
    toolchains = [PROTO_TOOLCHAIN],
)
