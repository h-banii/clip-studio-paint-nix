{
  lib,
  callPackage,
  programFilesCallPackage ? callPackage,
  webview2-verb,
}:
let
  builders = callPackage ./builders.nix { };
  webview2 = "${webview2-verb}/webview2.verb";
in
rec {
  buildClipStudioPaint =
    {
      pname ? "clip-studio-paint",
      version,
      installerHash,
      tricks ? [ ],
      windowsVersion ? "win81",
      ...
    }:
    let
      programFiles = programFilesCallPackage ./programFiles.nix (
        {
          inherit pname version;
          installer =
            let
              ver = builtins.replaceStrings [ "." ] [ "" ] version;
            in
            {
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
          tricks
          windowsVersion
          ;
      }
      // builders
    );

  clip-studio-paint-v1 = buildClipStudioPaint {
    version = "1.13.2";
    installerHash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v2 = buildClipStudioPaint {
    version = "2.0.6";
    installerHash = "sha256-7aljWvkwjqOKIofUk202Cw4iIq6qxBwYB8Q8K2gqPEw=";
    tricks = [ "cjkfonts" ];
  };

  clip-studio-paint-v3 = buildClipStudioPaint {
    version = "3.0.4";
    installerHash = "sha256-Es3QcpTReNi2RgVP0PtInLU/OFAl6beLs2jultKcV+4=";
    tricks = [
      webview2
      "dxvk"
    ];
    windowsVersion = "win7";
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    installerHash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
    tricks = [
      webview2
      "dxvk"
    ];
    windowsVersion = "win7";
  };
}
