function VWOCMBB-updater([array]$params){
  cls
Write-host "Check for updates!"
  $url = "https://easy-develope.ch/ps_bot_update/meta.xml"
  $output = "$PSScriptRoot\meta.xml"
  Invoke-WebRequest -Uri $url -OutFile $output

  $xml = new-object System.Xml.XmlDocument
  $path = "$PSScriptRoot\meta.xml"
  $xml = [xml](Get-Content $path)
  $global:newversion = $xml.Meta.Version.Value
  if($xml.Meta.Version.Value -eq $params[0]){
    cls
    Write-host "No Update available"
    Start-Sleep -s 3
    cls
  } else {
    cls
    Write-host "Update available. Update now?"
    write-host ""
    write-host $global:newversion
    write-host "Changelog:"
    write-host ""
    foreach ($cline in ($xml.Meta.Changelog.Info)){
      Write-host ("- " + $cline.Value)
    }
	  write-host ""
    $updateq = menu @("Yes","No")
    if($updateq -eq "Yes"){
      cls
      Write-host "Backup current bot!"
      write-host $params[1]
      $zippath = ($params[1]+'\backup\backup_'+$params[0]+'.zip')
      $bk_path = $params[1]
      & $PSScriptRoot\7za.exe a $zippath $bk_path '-xr!*.zip'
      start-sleep -s 4
      cls
      Write-host "Dowloading update..."
      $url = $xml.Meta.Path.Value
      $name = $xml.Meta.Version.Value
      $output = "$PSScriptRoot\update-$name.zip"
      Invoke-WebRequest -Uri $url -OutFile $output
      cls
      Write-host "Extract update..."
      Expand-Archive -Path "$PSScriptRoot\update-$name.zip" -DestinationPath $params[1] -Force
      $xml = new-object System.Xml.XmlDocument
      $path = $params[1]+'\data\settings.xml'
      $xml = [xml](Get-Content $path)
      $vers = $global:newversion
      $xml.OPT.Version.Value = "$vers"
      $xml.Save($path)
      cls
      Write-host "Update was succesfully!"
      Write-host "Please restart the bot"
      Write-host "Terminate updater in 4 seconds Please wait!"
      start-sleep -s 4
      Break
    }
  }
}
