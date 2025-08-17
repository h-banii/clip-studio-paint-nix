{ callPackage, fetchurl, ... }:
let
  builders = callPackage ./builders.nix { };
in
{
  clip-studio-paint-v1 = callPackage ./base.nix {
    inherit (builders) buildWineApplication buildInstallShield;
    version = "1.13.2";
    installer = fetchurl {
      url = "https://vd.clipstudio.net/clipcontent/paint/app/1132/CSP_1132w_setup.exe";
      hash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
    };
  };
  clip-studio-paint-v2 = callPackage ./base.nix {
    inherit (builders) buildWineApplication buildInstallShield;
    version = "2.0.6";
    installer = fetchurl {
      url = "https://vd.clipstudio.net/clipcontent/paint/app/206/CSP_206w_setup.exe";
      hash = "sha256-7aljWvkwjqOKIofUk202Cw4iIq6qxBwYB8Q8K2gqPEw=";
    };
  };
}
