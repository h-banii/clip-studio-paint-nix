{
  lib,
  buildWineApplication,
  buildInstallShield,
  callPackage,
  fetchurl,
  wineWowPackages,
  makeDesktopItem,

  pname ? "clip-studio-paint",
  version,
  installer,
  winePackage ? wineWowPackages.unstable,
  windowsVersion ? "win81",
  setupLanguage ? "english",
  ...
}:
let
  programFiles = buildInstallShield {
    name = "${pname}-${version}";

    inherit winePackage;

    installerExecutable = installer;

    installerResponse = callPackage ./iss.nix {
      inherit version;
      langCode =
        {
          chinese = "0404";
          english = "0409";
          french = "040c";
          german = "0407";
          japanese = "0411";
          korean = "0412";
          spanish = "040a";
        }
        .${setupLanguage} or "0409";
    };

    installerOut = "Program Files/CELSYS/CLIP STUDIO 1.5";
  };
in
buildWineApplication rec {
  inherit
    pname
    version
    winePackage
    windowsVersion
    ;

  withCjk = true;

  executable = ''${programFiles}/CLIP STUDIO PAINT/CLIPStudioPaint.exe'';

  desktopItems = [
    (makeDesktopItem {
      name = "clip-studio-paint";
      exec = pname;
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
      exec = ''${pname} "${programFiles}/CLIP STUDIO/CLIPStudio.exe"'';
      icon = fetchurl {
        url = "https://assets.clip-studio.com/favicon.ico";
        hash = "sha256-YESOiN4bEIlheWbDg7iNhjIPUmbeRyVDTUqS+9sa+qk=";
      };
      desktopName = "CLIP STUDIO";
      startupWMClass = "clipstudio.exe";
      categories = [ "Graphics" ];
    })
  ];

  meta = {
    licenses = lib.licenses.unfree;
    description = "Digital art studio made by Celsys";
  };
}
