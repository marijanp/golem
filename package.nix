{ lib
, rustPlatform
, pkg-config
, openssl
, stdenv
, darwin
, protobuf
, redis
, fontconfig
}:
rustPlatform.buildRustPackage {
  pname = "golem";
  version = "1.0.8";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./golem-api-grpc
      ./golem-cli
      ./golem-client
      ./golem-common
      ./golem-service-base
      ./golem-component-compilation-service
      ./golem-component-service-base
      ./golem-component-service
      ./golem-rib
      ./golem-test-framework
      ./golem-shard-manager
      ./golem-worker-executor-base
      ./golem-worker-executor
      ./golem-worker-service-base
      ./golem-worker-service
      ./integration-tests
      ./openapi
    ];
  };

  nativeBuildInputs = [ pkg-config protobuf ];
  buildInputs = [
    fontconfig
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;
  checkInputs = [ redis ];

  GOLEM_WASM_AST_ROOT = "/build/cargo-vendor-dir/golem-wasm-ast-1.0.0";
  GOLEM_WIT_ROOT = "/build/cargo-vendor-dir/golem-wit-1.0.0";

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "cranelift-bforest-0.108.1" = "sha256-WVRj6J7yXLFOsud9qKugmYja0Pe7AqZ0O2jgkOtHRg8=";
      "libtest-mimic-0.7.0" = "sha256-xUAyZbti96ky6TFtUjyT6Jx1g0N1gkDPjCMcto5SzxE=";
      "golem-examples-1.0.4" = "sha256-LHqczWXp6x6xTZMm+0wCFEn/m9DV2SzRu9CWHQNuD44=";
      "golem-wasm-rpc-1.0.2" = "sha256-n2YxF3oH7n6hsQjpqNFDjKlZPeQVvYq7NJKvWpOs9g8=";
    };
  };

  meta = with lib; {
    description = "Golem is an open source durable computing platform that makes it easy to build and deploy highly reliable distributed systems.";
    homepage = "https://www.golem.cloud/";
    license = licenses.asl20;
    mainProgram = "golem-cli";
  };
}
