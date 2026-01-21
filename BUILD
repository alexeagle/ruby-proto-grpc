"""Targets in the repository root"""

load("@gazelle//:def.bzl", "gazelle")

# We prefer BUILD instead of BUILD.bazel
# gazelle:build_file_name BUILD
# gazelle:exclude githooks/*
# Workaround https://github.com/bazel-contrib/bazel-gazelle/issues/2001
# gazelle:map_kind proto_library proto_library @protobuf//bazel:proto_library.bzl
gazelle(
    name = "gazelle",
    env = {"ENABLE_LANGUAGES": "proto"},
    gazelle = "@multitool//tools/gazelle",
)
