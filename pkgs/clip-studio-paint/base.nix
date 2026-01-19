{
  pname,
  version,
  programFiles,

  lib,
  fetchurl,
  makeDesktopItem,
  wineWowPackages,

  winePackage ? wineWowPackages.unstable,
  buildWineApplication,
  windowsVersion ? "win81",

  tricks ? [ ],
  derivationArgs ? { },
  ...
}:
let
  majorVersion =
    with lib.versions;
    if (minor version) == "0" then
      major version
    else
      builtins.toString ((lib.strings.toInt (major version)) + 1);
in
buildWineApplication rec {
  inherit
    pname
    version
    winePackage
    windowsVersion
    tricks
    derivationArgs
    ;

  wineprefix = "$HOME/.nix-csp-wine/${pname}-v${majorVersion}";

  executable = "${programFiles}/CLIP STUDIO PAINT/CLIPStudioPaint.exe";
  extraExecutables = {
    "clip-studio" = "${programFiles}/CLIP STUDIO/CLIPStudio.exe";
  };

  desktopItems =
    let
      clip-studio-icon = fetchurl {
        url = "https://assets.clip-studio.com/favicon.ico";
        hash = "sha256-YESOiN4bEIlheWbDg7iNhjIPUmbeRyVDTUqS+9sa+qk=";
      };
      clip-studio-paint-icon = fetchurl {
        url = "https://www.clipstudio.net/view/img/common/favicon.ico";
        hash = "sha256-VKeb/CS3Jh/NW2/oa+lfQStJkwAf6+IKOQuuMNcYSGg=";
      };
    in
    [
      (makeDesktopItem {
        name = "clip-studio-paint";
        exec = "${pname} %U";
        icon = clip-studio-paint-icon;
        desktopName = "CLIP STUDIO PAINT ${version}";
        startupWMClass = "clipstudiopaint.exe";
        categories = [ "Graphics" ];
      })
      (makeDesktopItem {
        name = "clip-studio";
        exec = "clip-studio %U";
        icon = clip-studio-icon;
        desktopName = "CLIP STUDIO ${version}";
        startupWMClass = "clipstudio.exe";
        categories = [ "Graphics" ];
      })
      (makeDesktopItem {
        name = "clip-studio-protocol";
        exec = "clip-studio -url %u";
        icon = clip-studio-icon;
        desktopName = "CLIP STUDIO ${version}";
        mimeTypes = [ "x-scheme-handler/clipstudio" ];
        noDisplay = true;
      })
      (makeDesktopItem {
        name = "clip-studio-paint-protocol";
        exec = "clip-studio-paint -url %u";
        icon = clip-studio-paint-icon;
        desktopName = "CLIP STUDIO PAINT ${version}";
        mimeTypes = [ "x-scheme-handler/clipstudiopaint" ];
        noDisplay = true;
      })
      (makeDesktopItem {
        name = "clip-studio-format-file";
        exec = "clip-studio-paint %f";
        icon = clip-studio-paint-icon;
        desktopName = "CLIP STUDIO FORMAT File ${version}";
        mimeTypes = [ "application/x-wine-extension-clip" ];
        noDisplay = true;
      })
    ];

  meta = {
    licenses = lib.licenses.unfree;
    description = "Digital art studio made by Celsys";
  };
}
