{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      systems,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs (import systems);
      pkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
      programFilesPkgsFor = forAllSystems (system: nixpkgs-stable.legacyPackages.${system});
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
          stablePkgs = programFilesPkgsFor.${system};

          csp = pkgs.callPackage ./pkgs/clip-studio-paint {
            programFilesCallPackage = stablePkgs.callPackage;
          };

          mixVersions =
            let
              symlink = input: path: {
                name = path;
                path = "${input}/${path}";
              };
            in
            cs: csp:
            pkgs.linkFarm "clip-studio-paint-mix-${cs.version}-${csp.version}" [
              (symlink cs "bin/clip-studio")
              (symlink cs "share/applications/clip-studio.desktop")
              (symlink cs "share/applications/clip-studio-protocol.desktop")
              (symlink csp "bin/clip-studio-paint")
              (symlink csp "share/applications/clip-studio-paint.desktop")
              (symlink csp "share/applications/clip-studio-paint-protocol.desktop")
              (symlink csp "share/applications/clip-studio-format-file.desktop")
            ];
        in
        rec {
          default = clip-studio-paint-v1;
          inherit (csp)
            clip-studio-paint-v1
            clip-studio-paint-v2
            clip-studio-paint-v3
            clip-studio-paint-v4
            clip-studio-paint-v5
            ;
          clip-studio-paint-latest = self.packages.${system}.clip-studio-paint-v5;
          clip-studio-paint-v1-plus = mixVersions clip-studio-paint-latest csp.clip-studio-paint-v1;
          clip-studio-paint-v2-plus = mixVersions clip-studio-paint-latest csp.clip-studio-paint-v2;
        }
      );

      legacyPackages = forAllSystems (system: {
        inherit (pkgsFor.${system}.callPackage ./pkgs/clip-studio-paint { })
          buildClipStudioPaint
          ;
      });

      formatter = forAllSystems (system: pkgsFor.${system}.nixfmt-tree);
    };
}
