<#
IpamImport-AddrIP-IPAM-Manage
@autor : Romain Drouche
@Description_fr : Ce script permet d'inventorier les adresses IP attribuées sur les plages gérer par le service IPAM.
@Description_en :  This script makes it possible to inventory the IP addresses allocated on the ranges managed by the IPAM service.
#>
# Remove display error
$ErrorActionPreference = "SilentlyContinue"

# Number of Echo for Test-Connection 
$EchoNumber = 1

# Get Range Manage by IPAM
$Ranges = Get-IpamRange -AddressFamily ipv4 -ManagedByService "IPAM"

# Browse Ranges
Foreach( $Range in $Ranges ){
    $ScanIPRange = @()
    [System.Net.IPAddress]$StartScanIP
    [System.Net.IPAddress]$EndScanIP

    $StartIP = $Range.StartAddress -split '\.'    
    [Array]::Reverse($StartIP)   
    $StartIP = ([System.Net.IPAddress]($StartIP -join '.')).Address
    
    $EndIP = $Range.EndIPAddress -split '\.' 
    [Array]::Reverse($EndIP)   
    $EndIP = ([System.Net.IPAddress]($EndIP -join '.')).Address 

    #Format IP
    For ($x=$StartIP; $x -le $EndIP; $x++) {     
        $temp = [System.Net.IPAddress]$x
        $IP = $temp.ToString() -split '\.' 
        [Array]::Reverse($IP) 
        $ScanIPRange += $IP -join '.'  
    } # /for

    # Scan IP Range
    Foreach($AddrIP in $ScanIPRange){ 
        [System.Net.IPAddress]$AddrIP = $AddrIP
        $DeviceName = ""

        if(Test-Connection -ComputerName $AddrIP -Count $EchoNumber -Quiet){
            Write-Host "Reponse au ping de " $AddrIP -ForegroundColor Green
            $r = [System.Net.Dns]::gethostentry($AddrIP)
            if($r){
                $DeviceName = [string]$r.HostName
            }
            Add-IpamAddress -IpAddress $AddrIP -DeviceName $DeviceName
        }else{ 
            Write-Host "Pas de reponse de "  $AddrIP -ForegroundColor Red
            Remove-IpamAddress -IpAddress $AddrIP -ManagedByService "IPAM" -Force
        }
    } # /foreach

}# /foreach