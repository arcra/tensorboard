workspace(name = "org_tensorflow_tensorboard")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "07b4117379dde7ab382345c3b0f5edfc6b7cff6c93756eac63da121e0bbcc5de",
    strip_prefix = "bazel-skylib-1.1.1",
    urls = [
        "http://mirror.tensorflow.org/github.com/bazelbuild/bazel-skylib/archive/1.1.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",  # 2021-09-27
    ],
)

load("@bazel_skylib//lib:versions.bzl", "versions")

versions.check(
    # Preemptively assume the next Bazel major version will break us, since historically they do,
    # and provide a clean error message in that case. Since the maximum version is inclusive rather
    # than exclusive, we set it to the 999th patch release of the current major version.
    maximum_bazel_version = "7.999.0",
    # Keep this version in sync with:
    #  * The BAZEL environment variable defined in .github/workflows/ci.yml, which is used for CI and nightly builds.
    minimum_bazel_version = "7.0.0",
)

http_archive(
    name = "io_bazel_rules_webtesting",
    sha256 = "85b773786b161507364e89d36205028dc3e513599cb888089152cf5827e1334f",
    # This is a snapshot of the code at this particular commit, which is after the fix from PR#469
    # and before updating the code to work only with bazel modules in PR#478
    # (This is the commit right before this last one, to be precise.)
    #
    # PR#469: https://github.com/bazelbuild/rules_webtesting/pull/469
    # PR#478: https://github.com/bazelbuild/rules_webtesting/pull/478
    #
    # The releases 0.3.5 is before both of these, and the next release, 0.4.0 is after both of them.
    # We should update this to a new way to integrate with karma tests.
    # Gemini suggested using Bazel modules with puppeteer, but we'll need to look into it more.
    strip_prefix = "rules_webtesting-d8208bddac1e44b3327430cc422f952b3244536a",
    urls = [
        "https://github.com/bazelbuild/rules_webtesting/archive/d8208bddac1e44b3327430cc422f952b3244536a.tar.gz",
    ],
)

load("@io_bazel_rules_webtesting//web:repositories.bzl", "web_test_repositories")

web_test_repositories(omit_bazel_skylib = True)

# These are common dependencies that are required by others below.
#
# In particular, rules_java seemed to be required by the grpc package.
#
# Also at some point there was an issue where rules_python had to be placed before
# load("@io_bazel_rules_closure//closure:repositories.bzl") in the dependencies list,
# otherwise we'd get "cannot load '@rules_python//python:py_xxx.bzl': no such file" errors.

http_archive(
    name = "rules_java",
    urls = [
        "https://github.com/bazelbuild/rules_java/releases/download/7.12.0/rules_java-7.12.0.tar.gz",
    ],
    sha256 = "c999cdbb4e8414d49c4117bb73800cff95c438c15da075531ae004275ab23144",
)
load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
rules_java_dependencies()
rules_java_toolchains()

http_archive(
    name = "rules_cc",
    strip_prefix = "rules_cc-0.0.17",
    urls = [
        "https://github.com/bazelbuild/rules_cc/releases/download/0.0.17/rules_cc-0.0.17.tar.gz",
    ],
    sha256 = "abc605dd850f813bb37004b77db20106a19311a96b2da1c92b789da529d28fe1",
)
load("@rules_cc//cc:repositories.bzl", "rules_cc_dependencies", "rules_cc_toolchains")
rules_cc_dependencies()
rules_cc_toolchains()

http_archive(
    name = "rules_python",
    strip_prefix = "rules_python-0.36.0",
    urls = [
        "https://github.com/bazelbuild/rules_python/releases/download/0.36.0/rules_python-0.36.0.tar.gz",
    ],
    sha256 = "ca77768989a7f311186a29747e3e95c936a41dffac779aff6b443db22290d913",
)
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()

http_archive(
    name = "io_bazel_rules_closure",
    sha256 = "38c3b21ea0dcf79bbc22d75f36fa57fb53ef2bf5f75e47f8b76af02c4a2abc1b",
    strip_prefix = "rules_closure-0.15.0",
    urls = [
        "https://github.com/bazelbuild/rules_closure/releases/download/0.15.0/rules_closure-0.15.0.tar.gz",
    ],
)

http_archive(
    name = "build_bazel_rules_nodejs",
    sha256 = "c29944ba9b0b430aadcaf3bf2570fece6fc5ebfb76df145c6cdad40d65c20811",
    urls = [
        "http://mirror.tensorflow.org/github.com/bazelbuild/rules_nodejs/releases/download/5.7.0/rules_nodejs-5.7.0.tar.gz",
        "https://github.com/bazelbuild/rules_nodejs/releases/download/5.7.0/rules_nodejs-5.7.0.tar.gz",
    ],
)

load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

yarn_install(
    name = "npm",
    data = [
        "//patches:@angular+build-tooling+0.0.0-7d103b83a07f132629592fc9918ce17d42a5e382.patch",
        "//patches:@bazel+concatjs+5.7.0.patch",
    ],
    # "Some rules only work by referencing labels nested inside npm packages
    # and therefore require turning off exports_directories_only."
    # This includes "ts_library".
    # See: https://github.com/bazelbuild/rules_nodejs/wiki/Migrating-to-5.0#exports_directories_only
    exports_directories_only = False,
    package_json = "//:package.json",
    yarn_lock = "//:yarn.lock",
)

# Load esbuild rules for bazel.
# https://bazelbuild.github.io/rules_nodejs/esbuild.html
load("@build_bazel_rules_nodejs//toolchains/esbuild:esbuild_repositories.bzl", "esbuild_repositories")

esbuild_repositories(npm_repository = "npm")

# rules_sass release information is difficult to find but it does seem to
# regularly release with same cadence and version as core sass.
# We typically upgrade this library whenever we upgrade rules_nodejs.
#
# rules_sass 1.55.0: https://github.com/bazelbuild/rules_sass/tree/1.55.0
http_archive(
    name = "io_bazel_rules_sass",
    sha256 = "1ea0103fa6adcb7d43ff26373b5082efe1d4b2e09c4f34f8a8f8b351e9a8a9b0",
    strip_prefix = "rules_sass-1.55.0",
    urls = [
        "http://mirror.tensorflow.org/github.com/bazelbuild/rules_sass/archive/1.55.0.zip",
        "https://github.com/bazelbuild/rules_sass/archive/1.55.0.zip",
    ],
)

load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")

sass_repositories()

# This dependency specifies the version of protobuf that will be used to compile
# protos as part of TensorBoard's build (i.e., the protoc version).
#
# The generated Python code for those protos relies on a Python runtime library,
# which is provided by the `protobuf` pip package. To ensure compatibility, the
# protoc version must be <= the runtime version. In our case, that means we must
# set the minimum `protobuf` version in our requirements.txt to be at least as
# high as the version of protobuf we depend on below, and we cannot increase the
# version below without bumping the requirements.txt version.
#
# We try to use the lowest "minor" version compatible with the version used by
# the TF release. It should also match the version used in the grpc dep below.
http_archive(
    name = "com_google_protobuf",
    sha256 = "fb06709acc393cc36f87c251bb28a5500a2e12936d4346099f2c6240f6c7a941",
    strip_prefix = "protobuf-30.2",
    urls = [
        "https://github.com/protocolbuffers/protobuf/releases/download/v30.2/protobuf-30.2.tar.gz",
    ],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# gRPC.
#
# NOTE: The version used here must be cross-compatible with our protobuf version.
# Version 1.72.x is the most recent release that requires the lowest
# protobuf 6.x minor version (TF 2.21 uses a version of protobuf in the 6.x range).
#
# Release notes for protobuf note that v30 has breaking changes for python:
# https://github.com/protocolbuffers/protobuf/releases/tag/v30.0
#
# The release charts here, also shows that 6.30 is the first 6.x release for python:
# https://protobuf.dev/support/version-support/#python
#
# On the other hand, grpc release 1.72.x is the first one who upgraded the protobuf
# depenrency to 30+:
# https://github.com/grpc/grpc/blob/d6b42b2fd3e522a60318c7e2f2021219c6b5c470/bazel/grpc_deps.bzl#L64
http_archive(
    name = "com_github_grpc_grpc",
    sha256 = "ae14a0de222485fd6e3baf52028c74acbd9ad8d685c813580401d3832cfae9f1",
    strip_prefix = "grpc-1.72.2",
    urls = [
        "https://github.com/grpc/grpc/archive/refs/tags/v1.72.2.tar.gz",
    ],
)

load("@com_github_grpc_grpc//bazel:grpc_deps.bzl", "grpc_deps")
grpc_deps()

load("@com_github_grpc_grpc//bazel:grpc_python_deps.bzl", "grpc_python_deps")
grpc_python_deps()

http_archive(
    name = "rules_rust",
    integrity = "sha256-yKqAbPYGZnmsI0YyQe6ArWkiZdrQRl9RERy74wuJA1I=",
    urls = ["https://github.com/bazelbuild/rules_rust/releases/download/0.68.1/rules_rust-0.68.1.tar.gz"],
)

# Please add all new dependencies in workspace.bzl.
load("//third_party:workspace.bzl", "tensorboard_workspace")

tensorboard_workspace()
