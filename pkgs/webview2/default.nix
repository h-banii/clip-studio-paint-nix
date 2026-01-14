{
  fetchurl,
  cabextract,
}:
fetchurl {
  # TODO: Find permanent link
  url = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/ea30811e-a216-4d55-89f3-c1099862c8fc/Microsoft.WebView2.FixedVersionRuntime.143.0.3650.139.x64.cab";
  hash = "sha256-iUiwGqJP0/PAVaDy4YYb1t9jXBONtEy1ZCTUbj9nlkc=";
  recursiveHash = true;
  downloadToTemp = true;
  nativeBuildInputs = [ cabextract ];
  postFetch = ''
    unpackDir="$TMPDIR/unpack"
    mkdir "$unpackDir"
    cabextract -d "$unpackDir" "$downloadedFile"

    root_folder=$(cd "$unpackDir" && ls -A)

    if [ -f "$unpackDir/$root_folder" ]; then
      mkdir $out
    fi

    mv "$unpackDir/$root_folder" "$out"
  '';
}
