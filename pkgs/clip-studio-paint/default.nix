{
  lib,
  callPackage,
  programFilesCallPackage ? callPackage,
  webview2-verb,
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
      withWebview2 ? false,
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
        inherit pname version programFiles;
        extraTricks = lib.optional withWebview2 "${webview2-verb}/webview2.verb";
        windowsVersion = if withWebview2 then "win7" else "win81";
      }
      // builders
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
    withWebview2 = true;
  };

  clip-studio-paint-v4 = buildClipStudioPaint {
    version = "4.0.3";
    installerHash = "sha256-swSj3j6xO56LQPhm5QqONMZ5i3m45McPx7yeDCZl6NA=";
    withWebview2 = true;
  };
}
