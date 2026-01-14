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

          webview2 = stablePkgs.callPackage ./pkgs/webview2 { };
          csp = pkgs.callPackage ./pkgs/clip-studio-paint {
            programFilesCallPackage = stablePkgs.callPackage;
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
          inherit webview2;
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
