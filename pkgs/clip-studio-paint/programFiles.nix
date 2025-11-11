{
  pname,
  version,
  installer,
  setupLanguage ? "english",

  buildInstallShield,
  fetchurl,
  winePackage,
  ...
}@args:
buildInstallShield {
  name = "${pname}-${version}";

  inherit winePackage;

  installerExecutable = fetchurl installer;

  installerResponse = import ./iss.nix (
    {
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
    }
    // args
  );

  programFiles = "Program Files/CELSYS/CLIP STUDIO 1.5";
}
