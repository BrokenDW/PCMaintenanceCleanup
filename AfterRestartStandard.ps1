<#DOCBLOC: 
Order of operations:
//add functionality to check if these programs exist or not. 
//If they do, uninstall all of them first and then execute rest of script.
//add functionality to check OS type - if OS type = win 10, run windows specific flash updates
Security first or Updates first

//script library
//one portion for "if elses" for main execution

//At restart, a separate script is set as a scheduled task to continue executing from where the restart would occur #>


$dlFolder = "c:\users\$env:username\desktop\ComputerSecurity"

$rkillIWR = Invoke-WebRequest -Uri "https://www.bleepingcomputer.com/download/rkill/dl/10/"
$rkilldirectLink = ($rkillIWR.content | select-string -Pattern "url=.+rkill\.exe" -AllMatches).matches.value -replace "url=",""
$avastDL = "https://install.avcdn.net/iavs9x/avast_free_antivirus_setup_offline.exe"
$ccleanerDL = "https://download.ccleaner.com/ccsetup543.exe"
$mbamDL = "https://downloads.malwarebytes.com/file/mb3/"
$adwcleanerIWR = Invoke-WebRequest -URI "https://www.bleepingcomputer.com/download/adwcleaner/dl/125/"
$adwcleanerdirectLInk = ($adwcleanerIWR.content | select-string -pattern "url=.+adwcleaner*\.exe" -AllMatches).matches.value -replace "url=",""
$mbarDL = "https://downloads.malwarebytes.com/file/mbar/"
$niniteDL = "https://ninite.com/.net4.7.2-air-chrome-firefox-java8-shockwave-silverlight/ninite.exe"

$rkillOutput = "$dlFolder\rkill.exe"
$avastOutput = "$dlFolder\Avast.exe"
$ccleanerOutput = "$dlFolder\ccsetup543.exe"
$mbamOutput = "$dlFolder\mbam.exe"
$adwcleanerOutput = "$dlFolder\adwcleaner.exe"
$mbarOutput = "$dlFolder\mbar.exe"
$niniteOutput = "$dlFolder\ninite.exe"

#$osVersion = #Determine if the OS is Windows 7, or Windows 10. 
Write-Host "This Script will install pre-requisite updates, and then ask for user input to download and install Security or Maintenance/Update programs."
sleep 10
write-host "------------------------------------"
sleep 2
write-host "####################################"
sleep 2
write-host "------------------------------------"
sleep 2
write-host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
sleep 2
write-host "------------------------------------"
sleep 2
write-host "First, check OS version. If Windows 7, update WMF and Powershell."
sleep 10

Function checkWMFandInstall {
	$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    $osversion = (gwmi win32_operatingsystem).version
    If ($osversion -like "6.*") {
        write-host "OS Is not Windows 10. Checking WMF"
            $version = $psversiontable.psversion
            if ($version -notlike "5*") { 
                write-host "Update powershell"
                set-location "$scriptDir\Win7AndW2K8R2-KB3191566-x64"
                .\Install-WMF5.1
                write-host "WMF and Powershell are complete"
            }
            else {
                write-host "Powershell is up to date"
            }
        
    }
    elseif ($osversion -like "10.*") {
        write-host "You're running Windows 10. WMF is up to date."
    }


}
checkWMFandInstall

write-host "Next up, Flash Module"
sleep 5
write-host "------------------------------------"
sleep 2
write-host "####################################"
sleep 2
write-host "------------------------------------"
sleep 2
write-host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
sleep 2
write-host "------------------------------------"
sleep 10

Function copyFlashPlayerModuleAndImport {
	$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    $flashModFolder = "$scriptDir\FlashPlayerUpdate"
    $flashMod = test-path "C:\windows\system32\windowspowershell\v1.0\modules\FlashPlayerUpdate"
  If ($flashMod -eq $true) {
        write-host "FlashModule Exists"
		Import-Module FlashPlayerUpdate
    }
    else {
        copy-item $flashModFolder -destination "C:\windows\system32\windowspowershell\v1.0\modules\" -recurse
        Import-Module FlashPlayerUpdate
        }
    

}
copyFlashPlayerModuleAndImport

write-host "Next up, create temporary directory"
sleep 5
write-host "------------------------------------"
sleep 2
write-host "####################################"
sleep 2
write-host "------------------------------------"
sleep 2
write-host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
sleep 2
write-host "------------------------------------"
sleep 10

If (!(Test-path $dlFolder)) {
    New-Item -ItemType Directory -path $dlFolder
}
else {
    write-host "Directory already exists"
}





Function secDownloads {
    Invoke-WebRequest -URI $rkilldirectLink -outFile $rkillOutput
    Invoke-WebRequest -URI $mbamDL -outFile $mbamOutput
    Invoke-WebRequest -URI $mbarDL -outFile $mbarOutput
    Invoke-WebRequest -URI $avastDL -outFile $avastOutput
    Invoke-WebRequest -URI $adwcleanerdirectLink -outFile $adwcleanerOutput
}

Function executeSecProgs {
    start-process $rkillOutput -wait
    start-process $adwcleanerOutput -wait
    start-process $avastOutput -wait
    start-process $mbamOutput -wait
    start-process $mbarOutput -wait
}

Function maintDownloads {
    #//Get Flash and others here. Include conditional formatting for OS version. 
    Invoke-WebRequest -URI $niniteDL -outFile $niniteOutput
    Invoke-webRequest -URI $ccleanerDL -outFile $ccleanerOutput
}

Function executeMaintProgs {
    start-process $niniteOutput -wait
    start-process $ccleanerOutput -wait
    Get-FlashPlayerUpdate
}

 
Function secuninstallStrings {
    $mbamUNINST = "C:\Program Files\Malwarebytes\Anti-Malware\unins000.exe"
    If (Test-Path $mbamUNINST) {
        start-process $mbamUNINST -argumentlist "/LOG" -wait
    }
    $mbarUNINST = "c:\users\$env:username\desktop\mbar\"
    If (Test-Path $mbarUNINST) {
        RD $mbarUNINST -recurse
    }
    $avastUNINST = "C:\Program Files\AVAST Software\Avast\Setup\Instup.exe"
    If (Test-Path $mbarUNINST) {
        start-process  -argumentlist "/control_panel" -wait
    }
    $rkillUNINST = "c:\users\$env:username\desktop\rkill.txt"
    If (Test-Path $rkillUNINST) {
        Remove-Item $rkillUNINST -force
    }
    $adwcleanerUNINST = "c:\adwcleaner"
    If (Test-Path $adwcleanerUNINST) {
        RD $adwcleanerUNINST -recurse
    }
} 

Function maintuninstallStrings {
    $chromeUninst = "C:\Program Files (x86)\Google"
    If (Test-Path $chromeUninst) {
        Start-Process MsiExec.exe -argumentlist "/X{E093BF8F-9D6D-342E-ADAC-7BD6F40C3BDE}" -wait
    }
    $firefoxUNINST = "C:\Program Files\Mozilla Firefox"
    If (Test-Path $firefoxUNINST) {
        start-process "C:\Program Files\Mozilla Firefox\uninstall\helper.exe" -wait
    }
    $ccleanerUNINST = "C:\Program Files\CCleaner\uninst.exe"
    If (Test-Path $ccleanerUNINST) {
        start-process $ccleanerUNINST -wait
    }
}

Function secDirectoryCleanup {
    RD "C:\ProgramData\AVAST Software\" -recurse -ea 0
    RD "C:\ProgramData\Malwarebytes\" -recurse -ea 0
    RD "C:\ProgramData\Malwarebytes' Anti-Malware (portable)\" -recurse -ea 0
    RD "C:\Program Files\Common Files\Avast Software\" -recurse -ea 0
    RD "C:\Program Files\Common Files\AV\" -recurse -ea 0
    RD "C:\Program Files (x86)\Common Files\AV" -recurse -ea 0
    RD "C:\Program Files (x86)\Spybot - Search & Destroy 2\" -recurse -ea 0
    RD "C:\Users\$env:username\AppData\Local\Temp\_avast_\" -recurse -ea 0
    RD "C:\Users\$env:username\AppData\Local\Temp\BCLTMP\" -recurse -ea 0
    RD "C:\Users\$env:username\AppData\Local\Temp\mbam\" -recurse -ea 0
}

Function maintDirectoryCleanup {
    RD "C:\Program Files (x86)\Google" -recurse -ea 0
    RD "C:\Users\$env:username\AppData\Local\Google\" -recurse -ea 0
    Remove-Item "c:\users\$env:username\AppData\Local\Temp\chrome_installer.log" -ea 0
    Remove-Item "c:\users\$env:username\AppData\Local\Temp\mb_setup.log" -ea 0
    Remove-Item "c:\users\$env:username\AppData\Local\Temp\Setup*.txt" -ea 0
    Remove-Item "c:\users\$env:username\AppData\Local\Temp\Uninstall*.txt" -ea 0
    RD "C:\Users\$env:username\AppData\LocalLow\Mozilla" -recurse -ea 0
}


executeMaintProgs

#End
RD $dlFolder