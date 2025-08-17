{
  lib,
  stdenvNoCC,
  writeShellApplication,
  copyDesktopItems,
  wineWowPackages,
  winetricks,
  ...
}:
{
  buildWineApplication =
    {
      pname,
      version,
      installer,
      installerFlags ? "",
      executable ? "explorer",

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
      writeWineApplication =
        let
          WINEPREFIX = wineprefix;
          WINEARCH = if use32Bit then "win32" else "win64";
        in
        {
          text,
          derivationArgs ? { },
          runtimeInputs ? [ ],
          ...
        }@args:
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
            "text"
            "derivationArgs"
            "runtimeInputs"
          ])
        );

      builder =
        let
          tricks = [ ] ++ lib.optional withCjk "cjkfonts" ++ extraTricks;
          tricksString = lib.lists.foldl (elm: acc: acc + toString (elm)) "" tricks;
          buildScript = ''
            wineboot -u
            winecfg /v ${windowsVersion}
          ''
          + lib.optionalString (tricks != [ ]) ''
            winetricks --unattended ${tricksString}
          '';
        in
        writeWineApplication {
          name = "wine-build";

          runtimeInputs = [
            winetricksPackage
          ];

          text = ''
            printf "\e[1mModifying wine prefix...\e[0m\n"
            mkdir -pv "$WINEPREFIX"

            COMMAND="''${1:-""}"

            case "$COMMAND" in
              --build)
                ${buildScript}
                ;;
              --install)
                wine ${installer} ${installerFlags}
                ;;
              *)
                ${buildScript}
                wine ${installer} ${installerFlags}
                ;;
            esac
          '';
        };

      runner = writeWineApplication {
        name = pname;

        runtimeInputs = [ builder ];

        text = ''
          for var in WINEPREFIX WINEARCH; do
            printf '\e[1;35m%s: \e[0m%s\n' "$var" "''${!var:-""}"
          done

          COMMAND="''${1:-${executable}}"

          case "$COMMAND" in
            build|update)
              wine-build --build
              ;;
            install)
              wine-build --install
              ;;
            *)
              if [ ! -d "$WINEPREFIX" ]; then
                wine-build
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
