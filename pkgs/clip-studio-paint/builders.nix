{
  lib,
  stdenvNoCC,
  runCommand,
  writeShellApplication,
  copyDesktopItems,
  wineWowPackages,
  winetricks,
  ...
}:
rec {
  writeWineScript =
    {
      winePackage,
      wineprefix,
      use32Bit,
      text,
      derivationArgs ? { },
      runtimeInputs ? [ ],
      ...
    }@args:
    let
      WINEPREFIX = wineprefix;
      WINEARCH = if use32Bit then "win32" else "win64";
    in
    writeShellApplication (
      {
        derivationArgs = {
          allowSubstitutes = false;
          preferLocalBuild = true;
        }
        // derivationArgs;

        runtimeInputs = [ winePackage ] ++ runtimeInputs;

        runtimeEnv = {
          inherit WINEARCH;
        };

        # We need to do it this way because runtimeEnv uses single quotes
        text = ''
          export WINEPREFIX="${WINEPREFIX}"
        ''
        + text;
      }
      // (builtins.removeAttrs args [
        "winePackage"
        "wineprefix"
        "use32Bit"
        "text"
        "derivationArgs"
        "runtimeInputs"
      ])
    );

  buildInstallShield =
    {
      name,
      winePackage,
      installerExecutable, # setup.exe file
      installerResponse, # .iss file
      installerOut,
    }:
    runCommand "${name}" { nativeBuildInputs = [ winePackage ]; } ''
      export WINEPREFIX="$TEMPDIR/wineprefix"
      wineboot -u

      cp "${installerResponse}" "$WINEPREFIX/drive_c/response.iss"
      wine "${installerExecutable}" /s /f1"C:\response.iss"

      mv "$WINEPREFIX/drive_c/${installerOut}" $out
    '';

  buildWineApplication =
    {
      pname,
      version,

      executable,

      desktopItems ? [ ],

      winePackage ? wineWowPackages.staging,
      winetricksPackage ? winetricks,

      withCjk ? false,
      extraTricks ? [ ],

      use32Bit ? false,
      windowsVersion ? "win10",
      wineprefix ? "$HOME/.nix-mink-wine/${pname}-${version}",

      meta,
      derivationArgs ? { },
    }:
    let
      buildScript =
        let
          tricks = [ ] ++ lib.optional withCjk "cjkfonts" ++ extraTricks;
          tricksString = lib.lists.foldl (elm: acc: acc + toString (elm)) "" tricks;
        in
        ''
          wineboot -u
          winecfg /v ${windowsVersion}
        ''
        + lib.optionalString (tricks != [ ]) ''
          winetricks --unattended ${tricksString}
        '';

      runner = writeWineScript {
        inherit winePackage wineprefix use32Bit;

        name = pname;

        text = ''
          for var in WINEPREFIX WINEARCH; do
            printf '\e[1;35m%s: \e[0m%s\n' "$var" "''${!var:-""}"
          done

          COMMAND="''${1:-${executable}}"

          build() {
          ${buildScript}
          }

          case "$COMMAND" in
            boot|build|rebuild)
              build
              ;;
            *)
              if [ ! -d "$WINEPREFIX" ]; then
                build
              fi
              wine "$COMMAND"
              ;;
          esac

          wineserver -k
        '';
      };
    in
    stdenvNoCC.mkDerivation {
      inherit pname version desktopItems;

      nativeBuildInputs = lib.optional (desktopItems != [ ]) copyDesktopItems;

      buildCommand = ''
        mkdir $out
        ln -s ${runner}/bin $out/bin

        runHook postInstall
      '';

      meta = {
        mainProgram = pname;
      }
      // meta;
    }
    // derivationArgs;
}
