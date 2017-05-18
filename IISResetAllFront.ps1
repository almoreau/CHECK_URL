# IISReset FRONT WEBSITES / Disable/Enable on F5 - V1.2
Foreach ($server in (Get-Content D:\Scripts\IISResetAllFront\Servers.txt))
{
    write-host("IISReset on " + $server + " :")
    # Disable Node
	write-host("F5 : Set the node " +$server + " : DISABLE")
	D:\Scripts\IISResetAllFront\F5Pilot_PRD.ps1 $server disable | Select-String "STATUS"
	Write-host("Starting IISReset on " + $server + "...")
	# IISReset Server
    IISReset $server
	# GetHTTP sites
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.com
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.fr
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.com
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.com
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.com
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.com
	D:\Scripts\IISResetAllFront\GetHTTP.exe $server www.URL.fr
	# Enable Node
	write-host("F5 : Set the node " +$server + " : ENABLE") -ForegroundColor Green
    D:\Scripts\IISResetAllFront\F5Pilot_PRD.ps1 $server enable | Select-String "STATUS"
    write-host("-----------------------------------")
}