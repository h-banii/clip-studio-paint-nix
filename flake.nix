{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-program-files.url = "github:NixOS/nixpkgs/25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-program-files,
      systems,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs (import systems);
      pkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
      programFilesPkgsFor = forAllSystems (system: nixpkgs-program-files.legacyPackages.${system});
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
          csp = pkgs.callPackage ./pkgs/clip-studio-paint {
            programFilesCallPackage = programFilesPkgsFor.${system}.callPackage;
          };
        in
        {
          default = self.packages.${system}.clip-studio-paint-v1;
          inherit (csp)
            clip-studio-paint-v1
            clip-studio-paint-v2
            clip-studio-paint-v3
            clip-studio-paint-v4
            ;
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
