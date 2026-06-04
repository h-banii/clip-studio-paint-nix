{
  pname,
  version,
  src,

  setupLanguage ? "english",

  wineWow64Packages,

  winePackage ? wineWow64Packages.minimal,
  buildInstallShield,

  replaceVars,
  ...
}:
let
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
in
buildInstallShield {
  name = "${pname}-${version}";

  inherit winePackage src;

  iss = replaceVars ./response.iss {
    inherit version langCode;
  };

  programFiles = "Program Files/CELSYS/CLIP STUDIO 1.5";
}
