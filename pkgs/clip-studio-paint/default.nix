{
  lib,
  callPackage,
  programFilesCallPackage ? callPackage,
  linkFarm,
  replaceVars,
}:
let
  builders = callPackage ./builders.nix { };
in
rec {
  buildClipStudioPaint =
    {
      pname ? "clip-studio-paint",
      version,
      installerHash,
      rawInstallerHash ? "",
      tricks ? [ ],
      customTricks ? [ ],
      windowsVersion ? "win81",
      ...
    }:
    let
      ver = builtins.replaceStrings [ "." ] [ "" ] version;

      # winetricks requires the basename to be "trick-name.verb"
      tricksPackage = linkFarm "clip-studio-paint-tricks" [
        {
          name = "csp.verb";
          path = replaceVars ./tricks/csp.verb {
            inherit ver version;
            hash = rawInstallerHash;
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

      programFiles = programFilesCallPackage ./programFiles.nix (
        {
          inherit pname version;
          installer = {
            name = "clip-studio-paint-installer-${version}";
            url = "https://vd.clipstudio.net/clipcontent/paint/app/${ver}/CSP_${ver}w_setup.exe";
            hash = installerHash;
          };
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
    installerHash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
    rawInstallerHash = "70525c4a18d8331c142a8ece255471404dd1fe7aca6bc72ea995a303d1a6abf8";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v2 = buildClipStudioPaint {
    version = "2.0.6";
    installerHash = "sha256-7aljWvkwjqOKIofUk202Cw4iIq6qxBwYB8Q8K2gqPEw=";
    rawInstallerHash = "eda9635af9308ea38a2287d4936d360b0e2222aeaac41c1807c43c2b682a3c4c";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v3 = buildClipStudioPaint {
    version = "3.0.4";
    installerHash = "sha256-Es3QcpTReNi2RgVP0PtInLU/OFAl6beLs2jultKcV+4=";
    rawInstallerHash = "12cdd07294d178d8b646054fd0fb489cb53f385025e9b78bb368ee96d29c57ee";
    tricks = [
      "dxvk"
    ];
    customTricks = [
      "webview2"
      "lightcjk"
    ];
    windowsVersion = "win7";
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    installerHash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
    rawInstallerHash = "b304a3de3eb13b9e8b40f866e50a8e34c6798b79b8e4c70fc7bc9e0c2665e8d0";
    tricks = [
      "dxvk"
    ];
    customTricks = [
      "webview2"
      "lightcjk"
    ];
    windowsVersion = "win7";
  };
}
