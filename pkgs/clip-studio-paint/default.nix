{ callPackage, fetchurl, ... }:
let
  builders = callPackage ./builders.nix { };
in
rec {
  buildClipStudioPaint =
    {
      version,
      installerHash,

      buildWineApplication ? builders.buildWineApplication,
      buildInstallShield ? builders.buildInstallShield,

      ...
    }@args:
    let
      ver = builtins.replaceStrings [ "." ] [ "" ] version;
    in
    callPackage ./base.nix (
      {
        inherit buildWineApplication buildInstallShield;
        inherit version;
        installer = fetchurl {
          url = "https://vd.clipstudio.net/clipcontent/paint/app/${ver}/CSP_${ver}w_setup.exe";
          hash = installerHash;
        };
      }
      // args
    );

  clip-studio-paint-v1 = buildClipStudioPaint {
    version = "1.13.2";
    installerHash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
  };

  clip-studio-paint-v2 = buildClipStudioPaint {
    version = "2.0.6";
    installerHash = "sha256-7aljWvkwjqOKIofUk202Cw4iIq6qxBwYB8Q8K2gqPEw=";
  };

  clip-studio-paint-v3 = buildClipStudioPaint {
    version = "3.0.4";
    installerHash = "sha256-Es3QcpTReNi2RgVP0PtInLU/OFAl6beLs2jultKcV+4=";
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    installerHash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
  };
}
