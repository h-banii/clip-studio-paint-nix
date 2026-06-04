{
  lib,
  pkgs,
  stablePkgs,
  linkFarm,
  replaceVars,
}:
let
  builders = pkgs.callPackage ./builders.nix { };
in
rec {
  buildClipStudioPaint =
    {
      pname ? "clip-studio-paint",
      version,
      hash,
      rawInstallerHash ? "",
      tricks ? [ ],
      customTricks ? [ ],
      windowsVersion ? "win81",
      ...
    }:
    let
      ver = builtins.replaceStrings [ "." ] [ "" ] version;

      tricksPackage = pkgs.callPackage ./tricks {
        inherit version;
        cspHash = hash;
      };

      programFiles =
        with stablePkgs;
        callPackage ./programFiles (
          {
            inherit pname version;

            src = fetchurl {
              name = "clip-studio-paint-installer-${version}";
              url = "https://vd.clipstudio.net/clipcontent/paint/app/${ver}/CSP_${ver}w_setup.exe";
              inherit hash;
            };
          }
          // builders
        );
    in
    pkgs.callPackage ./base.nix (
      {
        inherit
          pname
          version
          programFiles
          windowsVersion
          ;
        tricks = tricks ++ (builtins.map (trick: "${tricksPackage}/${trick}.verb") customTricks);
        derivationArgs.passthru.tricks = tricksPackage;
      }
      // builders
    );

  clip-studio-paint-v1 = buildClipStudioPaint {
    version = "1.13.2";
    hash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v2 = buildClipStudioPaint {
    version = "2.0.6";
    hash = "sha256-7aljWvkwjqOKIofUk202Cw4iIq6qxBwYB8Q8K2gqPEw=";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v3 = buildClipStudioPaint {
    version = "3.0.8";
    hash = "sha256-SkdYGCDyCmC/pWi9tLPz9e5e/rExDN4E1ZvVM4Kmu58=";
    tricks = [
      "dxvk"
    ];
    customTricks = [
      "webview2"
      "lightcjk"
    ];
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    hash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
    tricks = [
      "dxvk"
    ];
    customTricks = [
      "webview2"
      "lightcjk"
    ];
  };

  clip-studio-paint-v5 = buildClipStudioPaint {
    version = "4.2.5";
    hash = "sha256-/JVkt+s4Kz/SwvpGP+tz9Ou4u9piQYvz9NlC5oVPN38=";
    tricks = [
      "dxvk"
    ];
    customTricks = [
      "webview2"
      "lightcjk"
    ];
  };
}
