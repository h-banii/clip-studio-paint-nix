{
  version,
  cspHash, # installer hash used by csp.verb for caching

  linkFarm,
  runCommand,
  toybox,
}:
let
  ver = builtins.replaceStrings [ "." ] [ "" ] version;
in
linkFarm "clip-studio-paint-tricks" [
  {
    name = "csp.verb";
    path = runCommand "csp.verb" { buildInputs = [ toybox ]; } ''
      CSP_HASH="${cspHash}"
      CSP_HASH="$(base64 -d <<< ''${CSP_HASH#sha256-} | xxd -p -c 0)"

      substitute ${./csp.verb} $out \
        --replace-fail @ver@ ${ver} \
        --replace-fail @version@ ${version} \
        --replace-fail @hash@ "$CSP_HASH"
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
