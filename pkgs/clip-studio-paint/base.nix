{
  lib,
  buildWineApplication,
  buildInstallShield,
  callPackage,
  fetchurl,
  wineWowPackages,
  makeDesktopItem,

  version,
  installer,
  winePackage ? wineWowPackages.unstable,
  installShieldWinePackage ? wineWowPackages.minimal,
  windowsVersion ? "win81",
  setupLanguage ? "english",
  ...
}:
let
  pname = "clip-studio-paint";

  programFiles = buildInstallShield {
    name = "${pname}-${version}";

    winePackage = installShieldWinePackage;

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

  wineprefix = "$HOME/.nix-csp-wine/${pname}-v${lib.versions.major version}";

  withCjk = true;

  executable = ''${programFiles}/CLIP STUDIO PAINT/CLIPStudioPaint.exe'';
  extraExecutables = {
    "clip-studio" = ''${programFiles}/CLIP STUDIO/CLIPStudio.exe'';
  };

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
    (makeDesktopItem rec {
      name = "clip-studio";
      exec = name;
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
