{
  version,
  cspHash, # installer hash used by csp.verb for caching

  linkFarm,
  runCommand,
}:
let
  ver = builtins.replaceStrings [ "." ] [ "" ] version;
in
linkFarm "clip-studio-paint-tricks" [
  {
    name = "csp.verb";
    path = runCommand "csp.verb" { } ''
      CSP_HASH=$(base64 -d <<< ${cspHash} | xxd -p)

      substitute ${./csp.verb} \
        --replace ver ${ver} \
        --replace version ${version}
        --replace hash $CSP_HASH
    '';
  }
  {
    name = "webview2.verb";
    path = ./webview2.verb;
  }
  {
    name = "lightcjk.verb";
    path = ./lightcjk.verb;
  }
]
