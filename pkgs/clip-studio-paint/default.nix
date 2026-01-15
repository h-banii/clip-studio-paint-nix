{
  lib,
  callPackage,
  programFilesCallPackage ? callPackage,
  linkFarm,
}:
let
  builders = callPackage ./builders.nix { };

  # winetricks requires the basename to be "trick-name.verb"
  tricks = linkFarm "tricks" [
    {
      name = "webview2.verb";
      path = ./tricks/webview2.verb;
    }
    {
      name = "lightcjk.verb";
      path = ./tricks/lightcjk.verb;
    }
  ];

  getTrick = name: "${tricks}/${name}.verb";
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
      (getTrick "webview2")
      (getTrick "lightcjk")
      "dxvk"
    ];
    windowsVersion = "win7";
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    installerHash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
    tricks = [
      (getTrick "webview2")
      (getTrick "lightcjk")
      "dxvk"
    ];
    windowsVersion = "win7";
  };
}
