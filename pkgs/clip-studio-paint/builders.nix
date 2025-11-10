{
  lib,
  symlinkJoin,
  stdenvNoCC,
  runCommand,
  writeShellApplication,
  copyDesktopItems,
  wineWowPackages,
  winetricks,
  fetchurl,
  callPackage,
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
      programFiles,
    }:
    runCommand "${name}" { nativeBuildInputs = [ winePackage ]; } ''
      export WINEPREFIX="$TEMPDIR/wineprefix"
      wineboot -u

      cp "${installerResponse}" "$WINEPREFIX/drive_c/response.iss"
      wine "${installerExecutable}" /s /f1"C:\response.iss"

      mv "$WINEPREFIX/drive_c/${programFiles}" $out
    '';

  buildWineApplication =
    {
      pname,
      version,

      executable,
      extraExecutables ? { },

      desktopItems ? [ ],

      winePackage ? wineWowPackages.staging,
      winetricksPackage ? winetricks,

      withCjk ? false,
      extraTricks ? [ ],

      use32Bit ? false,
      windowsVersion ? "win10",
      wineprefix ? "$HOME/.nix-wine/${pname}-${version}",

      meta,
      derivationArgs ? { },
    }:
    let
      mkRunner =
        let
          buildScript =
            let
              tricks = [ ] ++ lib.optional withCjk "cjkfonts" ++ extraTricks;
              tricksString = lib.lists.foldl (elm: acc: acc + toString (elm)) "" tricks;
            in
            ''
              mkdir -p "$WINEPREFIX"
              wineboot -u
              winecfg /v ${windowsVersion}
            ''
            + lib.optionalString (tricks != [ ]) ''
              winetricks --unattended ${tricksString}
            '';
        in
        { name, command }:
        writeWineScript {
          inherit
            name
            winePackage
            wineprefix
            use32Bit
            ;

          text = ''
            for var in WINEPREFIX WINEARCH; do
              printf '\e[1;35m%s: \e[0m%s\n' "$var" "''${!var:-""}"
            done

            COMMAND="''${1:-${command}}"

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
                eval "$COMMAND"
                ;;
            esac

            wineserver -k
          '';
        };

      desktopEntries = stdenvNoCC.mkDerivation {
        pname = "${pname}-desktop-entries";
        inherit version desktopItems;

        allowSubstitutes = false;
        preferLocalBuild = true;

        nativeBuildInputs = [ copyDesktopItems ];

        buildCommand = ''
          mkdir $out
          runHook postInstall
        '';
      };

      mainRunner = mkRunner {
        name = pname;
        command = "wine '${executable}'";
      };

      extraRunners = lib.attrsets.mapAttrsToList (
        name: value:
        mkRunner {
          inherit name;
          command = "wine '${value}'";
        }
      ) extraExecutables;
    in
    symlinkJoin {
      name = "${pname}-${version}";

      paths = [
        mainRunner
      ]
      ++ lib.optional (desktopItems != [ ]) desktopEntries
      ++ extraRunners;

      meta = {
        mainProgram = pname;
      }
      // meta;
    }
    // derivationArgs;

  buildClipStudioPaint =
    { version, installerHash }:
    let
      ver = builtins.replaceStrings [ "." ] [ "" ] version;
    in
    callPackage ./base.nix {
      inherit buildWineApplication buildInstallShield;
      inherit version;
      installer = fetchurl {
        url = "https://vd.clipstudio.net/clipcontent/paint/app/${ver}/CSP_${ver}w_setup.exe";
        hash = installerHash;
      };
    };
}
