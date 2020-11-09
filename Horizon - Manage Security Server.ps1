
<#
.SYNOPSIS
Script to update existing Horizon Security Servers
	
.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
                  with help from Andrew Morgan Twitter: @andyjmorgan
  Creation Date:  11/2/2020
  Purpose/Change: Initial script development

  This script requires Horizon 7 PowerCLI - https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html
  
 #>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()
import-module vmware.powercli
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function LogintoHorizon {

#Capture Login Information
$script:HorizonServer = Read-Host -Prompt 'Enter the Horizon Connection Server Name'
$Username = Read-Host -Prompt 'Enter the Username'
$Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = Read-Host -Prompt 'Enter the Horizon Domain'

#Convert Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

try {
    
    $script:hvServer = Connect-HVServer -Server $horizonserver -User $username -Password $UnsecurePassword -Domain $domain
    $script:hvServices = $hvServer.ExtensionData
    $script:cs = $script:hvServices.connectionserver.ConnectionServer_List()[0].general.name
    $script:csid = $script:hvServices.connectionserver.ConnectionServer_List()[0].id

    }

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

write-host "Successfully Logged In"

} 

Function GetSSInfo {

   
        if ([string]::IsNullOrEmpty($hvserver))
        {
           write-host "You are not logged into Horizon"
            break   
           
        }
    
                
        try {
                      
        $ss = $hvservices.SecurityServer.SecurityServer_List()

         if ($ss.Count -eq 0)
         
         {
          
          write-host "No Security Servers Found"
          return

        }

          $script:sslookup = @{}



          foreach ($item in $ss) {
      
            $sslookup.add($item.general.name,$item.id)
            
        }

$Main                            = New-Object system.Windows.Forms.Form
$Main.ClientSize                 = New-Object System.Drawing.Point(490,363)
$Main.text                       = "Horizon Security Servers for "+$cs
$Main.TopMost                    = $true

$lblsecurityservers              = New-Object system.Windows.Forms.Label
$lblsecurityservers.text         = "Security Servers: "
$lblsecurityservers.AutoSize     = $true
$lblsecurityservers.width        = 25
$lblsecurityservers.height       = 10
$lblsecurityservers.location     = New-Object System.Drawing.Point(18,24)
$lblsecurityservers.Font         = New-Object System.Drawing.Font('Tahoma',10)
        
$btnSave                         = New-Object system.Windows.Forms.Button
$btnSave.text                    = "OK"
$btnSave.width                   = 60
$btnSave.height                  = 30
$btnSave.location                = New-Object System.Drawing.Point(355,320)
$btnSave.Font                    = New-Object System.Drawing.Font('Tahoma',10)
        
$cmdGetSS                        = New-Object system.Windows.Forms.Button
$cmdGetSS.text                   = "Get Details"
$cmdGetSS.width                  = 90
$cmdGetSS.height                 = 30
$cmdGetSS.location               = New-Object System.Drawing.Point(381,21)
$cmdGetSS.Font                   = New-Object System.Drawing.Font('Tahoma',10)
        
$pcoipsecuregw                   = New-Object system.Windows.Forms.Label
$pcoipsecuregw.text              = "PCoIP Secure Gateway Installed:"
$pcoipsecuregw.AutoSize          = $true
$pcoipsecuregw.width             = 25
$pcoipsecuregw.height            = 10
$pcoipsecuregw.location          = New-Object System.Drawing.Point(18,62)
$pcoipsecuregw.Font              = New-Object System.Drawing.Font('Tahoma',10)
        
$script:chdpgw                   = New-Object system.Windows.Forms.CheckBox
$script:chdpgw.AutoSize          = $false
$script:chdpgw.width             = 95
$script:chdpgw.height            = 20
$script:chdpgw.location          = New-Object System.Drawing.Point(231,63)
$script:chdpgw.Font              = New-Object System.Drawing.Font('Tahoma',12)
$script:chdpgw.Enabled           = $false
        
$cmbSS                           = New-Object system.Windows.Forms.ComboBox
$cmbSS.width                     = 237
$cmbSS.height                    = 20
$cmbSS.location                  = New-Object System.Drawing.Point(135,21)
$cmbSS.Font                      = New-Object System.Drawing.Font('Tahoma',10)

#Populate Security Servers into Combobox
foreach ($item in $script:sslookup.keys) {$cmbss.items.add($item)}
$cmbss.text = $item
        
$hsc                             = New-Object system.Windows.Forms.Label
$hsc.text                        = "HTTP(s) Secure Tunnel"
$hsc.AutoSize                    = $true
$hsc.width                       = 25
$hsc.height                      = 10
$hsc.location                    = New-Object System.Drawing.Point(10,95)
$hsc.Font                        = New-Object System.Drawing.Font('Tahoma',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
        
$httpexturl                      = New-Object system.Windows.Forms.Label
$httpexturl.text                 = "External URL:"
$httpexturl.AutoSize             = $true
$httpexturl.width                = 25
$httpexturl.height               = 10
$httpexturl.location             = New-Object System.Drawing.Point(75,120)
$httpexturl.Font                 = New-Object System.Drawing.Font('Tahoma',10)
        
$script:txtexternalurl           = New-Object system.Windows.Forms.TextBox
$script:txtexternalurl.multiline = $false
$script:txtexternalurl.width     = 294
$script:txtexternalurl.height    = 20
$script:txtexternalurl.location  = New-Object System.Drawing.Point(165,118)
$script:txtexternalurl.Font      = New-Object System.Drawing.Font('Tahoma',10)
        
$psgw                            = New-Object system.Windows.Forms.Label
$psgw.text                       = "PCoIP Secure Gateway"
$psgw.AutoSize                   = $true
$psgw.width                      = 25
$psgw.height                     = 10
$psgw.location                   = New-Object System.Drawing.Point(10,160)
$psgw.Font                       = New-Object System.Drawing.Font('Tahoma',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
        
$peurl                           = New-Object system.Windows.Forms.Label
$peurl.text                      = "PCoIP External URL:"
$peurl.AutoSize                  = $true
$peurl.width                     = 25
$peurl.height                    = 10
$peurl.location                  = New-Object System.Drawing.Point(35,188)
$peurl.Font                      = New-Object System.Drawing.Font('Tahoma',10)
        
$script:txtpcoipexternalurl             = New-Object system.Windows.Forms.TextBox
$script:txtpcoipexternalurl.multiline   = $false
$script:txtpcoipexternalurl.width       = 293
$script:txtpcoipexternalurl.height      = 20
$script:txtpcoipexternalurl.location    = New-Object System.Drawing.Point(165,184)
$script:txtpcoipexternalurl.Font        = New-Object System.Drawing.Font('Tahoma',10)
        
$lblbsg                          = New-Object system.Windows.Forms.Label
$lblbsg.text                     = "Blast Secure Gateway"
$lblbsg.AutoSize                 = $true
$lblbsg.width                    = 25
$lblbsg.height                   = 10
$lblbsg.location                 = New-Object System.Drawing.Point(10,236)
$lblbsg.Font                     = New-Object System.Drawing.Font('Tahoma',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
        
$lblbeurl                        = New-Object system.Windows.Forms.Label
$lblbeurl.text                   = "Blast External URL:"
$lblbeurl.AutoSize               = $true
$lblbeurl.width                  = 25
$lblbeurl.height                 = 10
$lblbeurl.location               = New-Object System.Drawing.Point(40,255)
$lblbeurl.Font                   = New-Object System.Drawing.Font('Tahoma',10)
        
$script:txtblastexternalurl             = New-Object system.Windows.Forms.TextBox
$script:txtblastexternalurl.multiline   = $false
$script:txtblastexternalurl.width       = 290
$script:txtblastexternalurl.height      = 20
$script:txtblastexternalurl.location    = New-Object System.Drawing.Point(165,253)
$script:txtblastexternalurl.Font        = New-Object System.Drawing.Font('Tahoma',10)
        
$Lblex1                          = New-Object system.Windows.Forms.Label
$Lblex1.text                     = "Example: https://myserver.com:443"
$Lblex1.AutoSize                 = $true
$Lblex1.width                    = 25
$Lblex1.height                   = 10
$Lblex1.location                 = New-Object System.Drawing.Point(174,143)
$Lblex1.Font                     = New-Object System.Drawing.Font('Tahoma',9)
        
$lblex2                          = New-Object system.Windows.Forms.Label
$lblex2.text                     = "Example: 10.0.0.1:4172"
$lblex2.AutoSize                 = $true
$lblex2.width                    = 25
$lblex2.height                   = 10
$lblex2.location                 = New-Object System.Drawing.Point(176,208)
$lblex2.Font                     = New-Object System.Drawing.Font('Tahoma',9)
        
$lbl3                            = New-Object system.Windows.Forms.Label
$lbl3.text                       = "Example: https://myserver.com:8443"
$lbl3.AutoSize                   = $true
$lbl3.width                      = 25
$lbl3.height                     = 10
$lbl3.location                   = New-Object System.Drawing.Point(176,278)
$lbl3.Font                       = New-Object System.Drawing.Font('Tahoma',9)
        
$btnClose = New-Object system.Windows.Forms.Button
$btnClose.text = "Cancel"
$btnClose.width = 60
$btnClose.height = 30
$btnClose.location = New-Object System.Drawing.Point(422,320)
$btnClose.Font = New-Object System.Drawing.Font('Tahoma',10)
        
$Main.controls.AddRange(@($lblsecurityservers,$btnSave,$cmdGetSS,$pcoipsecuregw,$chdpgw,$cmbSS,$hsc,$httpexturl,$txtexternalurl,$psgw,$peurl,$txtpcoipexternalurl,$lblbsg,$lblbeurl,$txtblastexternalurl,$Lblex1,$lblex2,$lbl3,$btnClose))
     
#Save Button
$btnSave.Add_Click({UpdateSS($cmbss.text)})

#Cancel/Close Button
$btnClose.Add_Click({[void]$main.close()})

#Refresh Security Servers
$cmdGetSS.Add_Click({GetSSServerData($cmbSS.text)})

[void]$main.ShowDialog()
#Sets the starting position of the form at run time.
$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen
$main.StartPosition = $CenterScreen
                   
}

  catch {
          Write-Host "An error occurred when getting Security Servers $_"
          break 
        }
        
     
} 

function GetSSServerData($thess){

 if ($thess -eq "")
 
{

  [System.Windows.MessageBox]::Show('No Security Server Specified','No Server Specified','OK','Information')
  return

}

try {
#Get Security Server Data
$ssid = $script:sslookup[$thess]
$soness = $hvservices.SecurityServer.SecurityServer_Get($ssid)

$blastsecuregwurl = $soness.General.ExternalAppblastURL
$securetunnelurl = $soness.General.ExternalURL
$pcoipsecuregwurl = $soness.General.ExternalPCoIPURL
$pcoipsgwinstalled = $soness.General.PcoipSecureGatewayInstalled

$script:txtexternalurl.text = $securetunnelurl
$script:chdpgw.Checked = $pcoipsgwinstalled
$script:txtblastexternalurl.text = $blastsecuregwurl
$script:txtpcoipexternalurl.text = $pcoipsecuregwurl
}

catch{
  Write-Host "An error occurred when getting Security Server Data $_"
  break 
}


}

Function SetCSPairingPW {
#Set password to pair Security Server with Connection Server

if ([string]::IsNullOrEmpty($hvserver))
{
   write-host "You are not logged into Horizon"
    break   
   
}

  try {

    $msgboxinput = [System.Windows.MessageBox]::Show('The connection server ' + $script:horizonserver + ' must be set to the UTC time zone in order for the password to be set properly. Would you like to proceed? You can manually update the timezone (if not UTC) and change it back after the script is run','Proceed?','YesNo','Question')

    switch  ($msgBoxInput) {
  
    'Yes' {
  
     continue

    }
        
     'No' {
    
       return
    
      }
      
    }

  $sppw = Read-Host -Prompt 'Specify the Security Server Pairing Password' -AsSecureString
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sppw)
  $UnsecurePW = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  $ConnectionServerId = $script:hvServices.connectionserver.ConnectionServer_List()[0].Id
  $pair = new-object -TypeName VMware.Hv.ConnectionServerSecurityServerPairingData
  $securestring = new-object -TypeName VMware.Hv.SecureString
  $enc = [system.Text.Encoding]::UTF8
  $securestring.Utf8String = $enc.GetBytes($UnsecurePW)
  $pair.PairingPassword = $securestring
  $pair.TimeoutMinutes = 30
  $mapEntry = new-object -TypeName VMware.Hv.MapEntry
  $mapEntry.Key = "securityServerPairing"
  $mapEntry.Value = $pair
  $script:hvServices.ConnectionServer.ConnectionServer_Update($ConnectionServerId, $mapEntry)

  }

  catch {
    Write-Host "An error occurred when setting the Security Server Pairing Password: $_"
    break 
  }

 write-host "Successfully set the security server pairing password - it is valid for 30 minutes"

}

Function UpdateSS($sstoupdate){

$msgboxinput = [System.Windows.MessageBox]::Show('Would you like to update this Security Server?','Update Security Server','YesNo','Question')

  switch  ($msgBoxInput) {

  'Yes' {

   continue

  }

  'No' {

   return

  }

}

  try {

if ($script:txtexternalurl.text -eq "")
{

  [System.Windows.MessageBox]::Show('External URL Cannot Be Empty','Field Required','OK','Exclamation')
  return

}

if ($script:txtblastexternalurl.text -eq "")
{

  [System.Windows.MessageBox]::Show('Blast URL Cannot Be Empty','Field Required','OK','Exclamation')
  return

}

if ($script:txtpcoipexternalurl.text -eq "")
{

  [System.Windows.MessageBox]::Show('PCoIP URL Cannot Be Empty','Field Required','OK','Exclamation')
  return

}

  $ssid = $script:sslookup[$sstoupdate]
  $entries = @()

  $exturlentry = New-Object VMware.Hv.MapEntry
  $exturlentry.key = 'general.externalURL'
  $exturlentry.value = $script:txtexternalurl.text
  $entries += $exturlentry

  $bsgurlentry = New-Object VMware.Hv.MapEntry
  $bsgurlentry.key = 'general.externalAppblastURL'
  $bsgurlentry.value = $script:txtblastexternalurl.text
  $entries += $bsgurlentry

  $pcoipurlentry = New-Object VMware.Hv.MapEntry
  $pcoipurlentry.key = 'general.externalPCoIPURL'
  $pcoipurlentry.value = $script:txtpcoipexternalurl.text
  $entries += $pcoipurlentry

  $script:hvServices.securityserver.SecurityServer_Update($ssid,$entries)  
    
  }

  catch {
    Write-Host "An error occurred when updating Security Server: $_"
    break 
  }

[System.Windows.MessageBox]::Show('Updated Successfully','Updated','OK','Information')

}

function Show-Menu
  {
    param (
          [string]$Title = 'VMware Horizon Security Server Management'
          )
       Clear-Host
       Write-Host "================ $Title ================"
             
       Write-Host "Press '1' to Login to Horizon"
       Write-Host "Press '2' to specify Security Server pairing password"
       Write-Host "Press '3' to Manage Existing Horizon Security Servers"
       Write-Host "Press 'Q' to quit."
         }

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         LogintoHorizon
    } 
    
    '2' {
   
         SetCSPairingPW

    }
    
    '3' {
       
         GetSSInfo
      
    }

  

    }
    pause
 }
 
 until ($selection -eq 'q')


