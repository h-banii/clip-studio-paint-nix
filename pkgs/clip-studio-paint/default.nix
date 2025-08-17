{ callPackage, ... }:
rec {
  builders = callPackage ./builders.nix { };
  clip-studio-paint-v1 = callPackage ./base.nix { inherit (builders) buildWineApplication; };
}
