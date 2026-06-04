{
  lib,
  callPackage,
  stablePkgs,
  linkFarm,
  replaceVars,

  runCommand,
  toybox,
}:
let
  builders = callPackage ./builders.nix { };
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

      installer = stablePkgs.fetchurl {
        name = "clip-studio-paint-installer-${version}";
        url = "https://vd.clipstudio.net/clipcontent/paint/app/${ver}/CSP_${ver}w_setup.exe";
        inherit hash;
      };

      hexHash = runCommand "csp-hex-hash" {
        buildInputs = [ toybox ];
      } "base64 -d <<< ${hash} | xxd -p > $out";

      # winetricks requires the basename to be "trick-name.verb"
      tricksPackage = linkFarm "clip-studio-paint-tricks" [
        {
          name = "csp.verb";
          path = replaceVars ./tricks/csp.verb {
            inherit ver version;
            # IFD: This could be removed with a derivation to build csv.verb
            hash = builtins.readFile hexHash;
          };
        }
        {
          name = "webview2.verb";
          path = ./tricks/webview2.verb;
        }
        {
          name = "lightcjk.verb";
          path = ./tricks/lightcjk.verb;
        }
      ];

      programFiles = stablePkgs.callPackage ./programFiles (
        {
          inherit pname version;
          src = installer;
        }
        // builders
      );
    in
    callPackage ./base.nix (
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
    version = "3.0.4";
    hash = "sha256-Es3QcpTReNi2RgVP0PtInLU/OFAl6beLs2jultKcV+4=";
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
