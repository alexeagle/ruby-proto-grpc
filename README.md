# Bazel Ruby with Proto/gRPC

We purely follow
https://grpc.io/docs/languages/ruby/basics/

with no weird Bazel stuff other than plain `proto_library`.

1. proto/foo.proto declares a trivial service
1. proto/ruby.bzl adds an aspect that puts Ruby codegen in the output
1. rules_ruby.patch is required to get the providers of that aspect into the deps of ruby rules (?)
1. the app/BUILD just refers to the proto_library target, but finds the RubyFilesInfo provider on it
 
### Demo

% bazel run app:hello &

% buf curl --schema proto --protocol grpc --http2-prior-knowledge \
  -d '{"empty":{}}' \
  http://localhost:50051/foo.FooService/GetFoo
{
  "name": "Hello from Bazel + Ruby gRPC server!"
}
```
