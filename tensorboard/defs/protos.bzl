# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_proto//proto:defs.bzl", "proto_library")
load("@com_google_protobuf//bazel:py_proto_library.bzl", "py_proto_library")
load("@com_github_grpc_grpc//bazel:python_rules.bzl", "py_grpc_library")

# TODO(#6185): try to reduce the complexity in this rule.
def tb_proto_library(
        name,
        srcs = None,
        deps = [],
        visibility = None,
        testonly = None,
        has_services = False,
        # The `exports` arg is unused here, but required internally for compatibility.
        exports = []):
    # Some targets might include the _proto suffix and some might not.
    # This naming just attempts to avoid any naming clashes, for the sake of
    # clarity.
    # The proto library is generally not referenced outside of this method.
    name_proto = name + "_proto_internal"

    # These are the targets that are expected by TB code when protos are built
    # using this function.
    name_py_pb2 = name + "_py_pb2"
    name_grpc = name_py_pb2 + "_grpc"

    proto_library(
        name = name_proto,
        srcs = srcs,
        deps = deps,
        visibility = visibility,
        testonly = testonly,
    )

    py_proto_library(
        name = name_py_pb2,
        deps = [":" + name_proto],
    )

    if has_services:
        py_grpc_library(
            name = name_grpc,
            srcs = [":" + name_proto],
            deps = [":" + name_py_pb2],
        )

