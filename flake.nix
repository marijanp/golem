{
  description = "golem";

  nixConfig = {
    extra-substituters = [
    ];
    extra-trusted-public-keys = [
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # eachSystem :: [ System ] -> (System -> FlakeOutputs)
      eachSystem = systems: f:
        let
          # Merge together the outputs for all systems.
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key: attrs //
                {
                  ${key} = (attrs.${key} or { })
                    // { ${system} = ret.${key}; };
                }
              ;
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      herculesCI.ciSystems = [ "x86_64-linux" "aarch64-linux" ];
      overlays.default = import ./overlay.nix;
    }
    // eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
      in
      {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.golem ];
        };
        packages = {
          inherit (pkgs) golem;
          default = pkgs.golem;
        };

        formatter = pkgs.nixpkgs-fmt;

        checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
          set -euo pipefail
          cd ${self}
          nixpkgs-fmt --check .
          touch $out
        '';
      });
}
