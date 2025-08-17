{
  lib,
  buildWineApplication,
  fetchurl,
  wineWowPackages,
  makeDesktopItem,
  ...
}:
buildWineApplication rec {
  pname = "clip-studio-paint";
  version = "1.13.2";

  # In theory, 1.13.2 has windows 10 support, but it's crashing...
  windowsVersion = "win81";
  winePackage = wineWowPackages.unstable;

  withCjk = true;

  installer = fetchurl {
    url = "https://vd.clipstudio.net/clipcontent/paint/app/1132/CSP_1132w_setup.exe";
    hash = "sha256-cFJcShjYMxwUKo7OJVRxQE3R/nrKa8cuqZWjA9Gmq/g=";
  };

  executable = ''C:\Program Files\CELSYS\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe'';

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
      exec = ''${pname} "C:/Program Files/CELSYS/CLIP STUDIO 1.5/CLIP STUDIO/CLIPStudio.exe"'';
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
