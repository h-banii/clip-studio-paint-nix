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
  ...
}:
buildWineApplication rec {
  inherit
    pname
    version
    winePackage
    windowsVersion
    ;

  wineprefix = "$HOME/.nix-csp-wine/${pname}-v${lib.versions.major version}";

  withCjk = true;

  executable = ''${programFiles}/CLIP STUDIO PAINT/CLIPStudioPaint.exe'';
  extraExecutables = {
    "clip-studio" = ''${programFiles}/CLIP STUDIO/CLIPStudio.exe'';
  };

  desktopItems =
    let
      clip-studio-icon = fetchurl {
        url = "https://assets.clip-studio.com/favicon.ico";
        hash = "sha256-YESOiN4bEIlheWbDg7iNhjIPUmbeRyVDTUqS+9sa+qk=";
      };
    in
    [
      (makeDesktopItem {
        name = "clip-studio-paint";
        exec = "${pname} %U";
        icon = fetchurl {
          url = "https://www.clipstudio.net/view/img/common/favicon.ico";
          hash = "sha256-VKeb/CS3Jh/NW2/oa+lfQStJkwAf6+IKOQuuMNcYSGg=";
        };
        desktopName = "CLIP STUDIO PAINT";
        startupWMClass = "clipstudiopaint.exe";
        categories = [ "Graphics" ];
      })
      (makeDesktopItem {
        name = "clip-studio";
        exec = "clip-studio %U";
        icon = clip-studio-icon;
        desktopName = "CLIP STUDIO";
        startupWMClass = "clipstudio.exe";
        categories = [ "Graphics" ];
      })
      (makeDesktopItem {
        name = "clip-studio-protocol";
        exec = "clip-studio -url %u";
        icon = clip-studio-icon;
        desktopName = "CLIP STUDIO";
        mimeTypes = [ "x-scheme-handler/clipstudio" ];
        noDisplay = true;
      })
    ];

  meta = {
    licenses = lib.licenses.unfree;
    description = "Digital art studio made by Celsys";
  };
}
