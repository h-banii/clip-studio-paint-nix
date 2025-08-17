{ callPackage, ... }:
let
  builders = callPackage ./builders.nix { };
in
{
  clip-studio-paint-v1 = callPackage ./base.nix {
    inherit (builders) buildWineApplication buildInstallShield;
  };
}
