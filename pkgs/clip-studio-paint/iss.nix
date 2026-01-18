# InstallShield Silent (iss)
{
  writeText,

  version ? "1.13.2",
  productGuid ? "{1E4572D2-28BC-4BC9-B743-13DC6CFD71DB}",

  langCode ? "0409",
}:
writeText "clip-studio-paint-iss" ''
  [InstallShield Silent]
  Version=v7.00
  File=Response File
  [File Transfer]
  OverwrittenReadOnly=NoToAll
  [${productGuid}-DlgOrder]
  Dlg0=${productGuid}-SdWelcome-0
  Count=5
  Dlg1=${productGuid}-LicenseDialog-0
  Dlg2=${productGuid}-SdAskDestPath2-0
  Dlg3=${productGuid}-SdStartCopy2-0
  Dlg4=${productGuid}-SdFinish-0
  [${productGuid}-SdWelcome-0]
  Result=1
  [${productGuid}-LicenseDialog-0]
  Result=1
  [${productGuid}-SdAskDestPath2-0]
  szDir=C:\Program Files\CELSYS
  Result=1
  [${productGuid}-SdStartCopy2-0]
  Result=1
  [Application]
  Name=CLIP STUDIO PAINT
  Version=${version}
  Company=CELSYS
  Lang=${langCode}
  [${productGuid}-SdFinish-0]
  Result=1
  bOpt1=0
  bOpt2=0
''
