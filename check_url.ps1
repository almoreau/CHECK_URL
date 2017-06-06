##############################################################################
#### Website Availability Monitoring
### 
## 
## 
## Pre requis
#      - Powershell V3.0 : http://www.microsoft.com/en-us/download/details.aspx?id=34595
#     - Creation d'un repertoire password afin de stocker les password crypté


##vérification de la bonne version de powershell (prérequis 3.0)
##création d’un fichier de password en mode secure string avec récupération du login AD pour le nom du fichier
##test sur contrôleur AD du mot de passe (si KO, delete du fichier password) pour ne pas locker le user
##prompt de l’environnement qui s’appuie sur le XML
##création d’un report HTML s’appuyant sur du CSS embarqué dans le code
##envoi du mail avec le reporting en attachement
##############################################################################



####################################################################################
#Create Log File
$ScriptName = ([io.fileinfo]$MyInvocation.MyCommand.Definition).BaseName
$CurrentFolder =  (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
$ReportingDateDay = get-date -f yyyy-MM-dd
$ReportingDateHours = get-date -f HH-mm-ss
$time = ($ReportingDateDay) + "_" + ($ReportingDateHours)
$Log_File = ("Log_" + $ScriptName + "_" + $time + ".txt")
$Log_File_Path = ($CurrentFolder + "\" + $Log_File)
New-Item -Path $CurrentFolder -ItemType File -Name $Log_File
$PasswordFolder_Path = $CurrentFolder + "\" + "Password"
####################################################################################







# Start write on log File
#Start-Transcript -Path $Log_File_Path -Force | Out-Null
cls


##############################################################################
##############################################################################
###########            Stockage des fonctions                #################
##############################################################################
##############################################################################
# Function to return a password from an encrypted file 
Function get-password
{ 
    # Use the Marshal classes to create a pointer to the secure string in memory 
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Password) 
    # Change the value at the pointer back to unicode (i.e. plaintext) 
    $pass = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr) 
     
    # Return the decrypted password 
    return $pass 
    
}  


#Function pour sortir du script
function end_script() 
{
Exit
}



##############################################################################
# Creation d'un repertoire password afin de stocker les password crypté
if ( -Not (Test-Path $PasswordFolder_Path))
{
 New-Item -Path "$PasswordFolder_Path" -ItemType Directory
}




# Envoi du mail
function send_email {
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = $EmailFrom
$emailMessage.To.Add($EmailTo)
$emailMessage.Subject = $EmailSubject
$attachment = New-Object System.Net.Mail.Attachment $emailattachment
$emailmessage.Attachments.Add($attachment)
$emailmessage.Body.Contains(($attachment))
$emailMessage.IsBodyHtml = $true
#$emailMessage.Body = (Get-Content $OutputFile_Horodater)
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $SMTPServer , $SMTPPort )
$SMTPClient.Send( $emailMessage )
}



#Disable-SSLValidation disables SSL certificate validation
Function Disable-SSLValidation
{
    Set-StrictMode -Version 2
 
    # You have already run this function
    if ([System.Net.ServicePointManager]::CertificatePolicy.ToString() -ne 'IgnoreCerts') { Return }
 
    # Don't bother defining a new assembly if one is already defined
    try { [IgnoreCerts] | Out-Null } catch { Return }
 
    $Domain = [AppDomain]::CurrentDomain
    $DynAssembly = New-Object System.Reflection.AssemblyName('IgnoreCerts')
    $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('IgnoreCerts', $false)
    $TypeBuilder = $ModuleBuilder.DefineType('IgnoreCerts', 'AutoLayout, AnsiClass, Class, Public, BeforeFieldInit', [System.Object], [System.Net.ICertificatePolicy])
    $TypeBuilder.DefineDefaultConstructor('PrivateScope, Public, HideBySig, SpecialName, RTSpecialName') | Out-Null
    $MethodInfo = [System.Net.ICertificatePolicy].GetMethod('CheckValidationResult')
    $MethodBuilder = $TypeBuilder.DefineMethod($MethodInfo.Name, 'PrivateScope, Public, Virtual, HideBySig, VtableLayoutMask', $MethodInfo.CallingConvention, $MethodInfo.ReturnType, ([Type[]] ($MethodInfo.GetParameters() | % {$_.ParameterType})))
    $ILGen = $MethodBuilder.GetILGenerator()
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ldc_I4_1)
    $ILGen.Emit([Reflection.Emit.Opcodes]::Ret)
    $TypeBuilder.CreateType() | Out-Null
 
    # Disable SSL certificate validation
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object IgnoreCerts
}

##############################################################################
##############################################################################
##############################################################################
##############################################################################



cls
Set-ExecutionPolicy Unrestricted


#execution de la fonction de formatage date des fichiers en sortie
$ReportingDateDay = get-date -f yyyy-MM-dd
$ReportingDateHours = get-date -f HH:mm:ss
$ReportingDate = ($ReportingDateDay) + " " + ($ReportingDateHours)


##########################################################################################################
# #Environment's Variables
$username = $env:USERNAME
$Domain_AD = $env:USERDOMAIN
$CurrentFolder = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$PasswordFolder = $CurrentFolder + "\Password"



$URLListFile = $CurrentFolder + "\" + "URL_List.xml"
$OutputFile = $CurrentFolder + "\" + "Report_BT_E-Business_Check-URL"
$PasswordFile = $PasswordFolder + "\" + "Password_" + $username + ".txt"
$Title0 = "URL Report V2.0"
$Title = $Title0 + " " + $ReportingDate
$OutputFile_Horodater = "$OutputFile $(get-date -f yyyy-MM-dd).htm"



#variables du mail
$EmailFrom = "BT_E-Business_Monitoring@cma-cgm.com"
$EmailTo = "ext.amoreau@cma-cgm.com"
$EmailSubject = "Report_Check-URL" + " " +  $ReportingDate
$emailbody = "$OutputFile_Horodater"
$SMTPServer = "cmaedi.cma-cgm.com"
$SMTPPort = "25"
$emailattachment = $OutputFile_Horodater
###########################################################################################################




#Vérification version du powershell requis
Write-host "######################################################################"
Write-host "Votre version de Powershell est"$PSVersionTable.PSVersion""
Write-host "######################################################################"
 if($PSVersionTable.PSVersion -eq "3.0") 
{
Write-host "Votre version Powershell est la bonne pour ce script"
}
Elseif($PSVersionTable.PSVersion -eq "4.0")
{
Write-Host("you are a real Windows admin")
}
Else
{ 
Write-host "Powershell V3.0 is required for this script" -ForegroundColor red
Write-host "You can download it at the URL below "
Write-host "http://www.microsoft.com/en-us/download/details.aspx?id=34595"
$ie = New-Object -COMObject InternetExplorer.Application
$ie.visible = $true
$ie.Navigate('http://www.microsoft.com/en-us/download/details.aspx?id=34595')
While ($ie.Busy) { Start-Sleep -Milliseconds 400 }
Write-host "The script will now ended"
end_script
}





#Recuperation du login AD
Write-host "######################################################################"
Write-host "Vous etes connecté avec le login $env:USERNAME" -ForegroundColor DarkGreen
Write-host "######################################################################"



#Vérifier la présence du fichier de password
while (-not (Test-Path $PasswordFile))
{
Write-host "######################################################################"
Write-host "Le fichier de password n'existe pas, creation en cours..." -ForegroundColor DarkMagenta
Write-host "merci de taper votre password et de valider avec Enter"
Write-host "######################################################################"
# Ligne d'encryptage du password dans le fichier securestring.txt
$fenetre=read-host -assecurestring
convertfrom-securestring -SecureString $fenetre | out-file $PasswordFile
}

#Cryptage du fichier de password
$password = cat $PasswordFile | convertto-securestring
$password = get-content $PasswordFile | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password


#Decryptage du password
$pass_decrypt = get-password $PasswordFile


# Validate that you can connect to AD Domain with your credential
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$username,$pass_decrypt)
if ($domain.name -eq $null)
{
Write-host "######################################################################"
write-host "Authentication failed due to bad password on password file" -ForegroundColor red
remove-item $PasswordFile
write-host "The file is now deleted." -ForegroundColor red
write-host "Please re execute script to re create it" -ForegroundColor red
pause 5000
Write-host "######################################################################"
exit
}
else
{
Write-host "######################################################################"
write-host "You are successfully authenticated with $username on Domain Controleur $Domain_AD" -ForegroundColor green
Write-host "######################################################################"
}


# Lecture du XML
[string]$URLListFile = $URLListFile
[xml]$config = Get-Content $URLListFile -ErrorAction SilentlyContinue
$ResultSI = @()



# Prompt permettant de choisir l'env sur lequel le report va faire son check URL
Write-host "Select your Environnement : PRD / PRE / UAT"
Write-host "Click ENTER to execute script on ALL Environnements"
Write-host "Click EXIT for exit the script execution"
$env = Read-Host

if($env -eq "PRD") 
{
Write-host "Report on PRD Environnement is in Progress..."
}

Elseif($env -eq "PRE")
{
Write-host "Report on PRE Environnement is in Progress..."
}

Elseif($env -eq "UAT")
{
Write-host "Report on Others Environnement is (DEV / UAT / REC / INT) is in Progress..."
}

Elseif($env -eq "EXIT")
{
Write-host "Reporting Cancelled." -ForegroundColor red
}




##########################################################################################################
# Lecture du XML

if (($env -eq "PRD") -or ($env -eq "PRE") -or ($env -eq "UAT"))
{

foreach( $Application in $config.SI.Environnement.Application | Where-Object {$_.ParentNode.Name -eq $env})
  {
  
#Faire une pause entre chaque groupe d'SI (secondes)
#Sleep 1
$ApplicationResult = [PSCustomObject] @{
Name=$Application.Name;
UrlResults = @();
}
$ResultSI += $ApplicationResult

    foreach($url in $Application.URL)
    {
    $time = try
    {
 

$request = $null
## Request the URI, and measure how long the response took.
$result = Measure-Command { $request = Invoke-WebRequest -Uri $url -Credential $cred }
# temps du test d'une URL en seconde (option : TotalMilliseconds)
$result.TotalSeconds


    #Script Body
    write-progress -activity "In Progress..." -status $Application.Name
	write-host $url `t "=>" $result.TotalSeconds
    
       ##write-host $result.TotalSeconds 
    }

    

	catch
    {
    $request = $_.Exception.Response
    $time = -1
    }  



        $ApplicationResult.UrlResults += [PSCustomObject] @{
        Time = Get-Date;
        #Creation du tableau
		ApplicationName = $Application.Name;
        Uri = $url;
        StatusCode = [int] $request.StatusCode;
        StatusDescription = $request.StatusDescription;
        TimeTaken =  $time; 
        ReportingDates = $ReportingDate;
        }
    }
}


}


ElseIf ($env -eq "EXIT")
{
end_script
}



Else
{


foreach( $Application in $config.SI.Environnement.Application )
  {
  
#Faire une pause entre chaque groupe d'SI (secondes)
#Sleep 1
$ApplicationResult = [PSCustomObject] @{
Name=$Application.Name;
UrlResults = @();
}
$ResultSI += $ApplicationResult

    foreach($url in $Application.URL)
    {
    $time = try
    {
 

$request = $null
## Request the URI, and measure how long the response took.
$result = Measure-Command { $request = Invoke-WebRequest -Uri $url -Credential $cred }
# temps du test d'une URL en seconde (option : TotalMilliseconds)
$result.TotalSeconds


    #Script Body
    write-progress -activity "In Progress..." -status $Application.Name
	write-host $url `t "=>" $result.TotalSeconds
    
       ##write-host $result.TotalSeconds 
    }

    

	catch
    {
    $request = $_.Exception.Response
    $time = -1
    }  



        $ApplicationResult.UrlResults += [PSCustomObject] @{
        Time = Get-Date;
        #Creation du tableau
		ApplicationName = $Application.Name;
        Uri = $url;
        StatusCode = [int] $request.StatusCode;
        StatusDescription = $request.StatusDescription;
        TimeTaken =  $time; 
        ReportingDates = $ReportingDate;
        }
    }
}

}


###########################################################################################################
#Creation du tableau vide
if($ResultSI -ne $null)
{
    $Outputreport = 
	"
	
<!DOCTYPE HTML>
<html>

<TITLE>$Title</TITLE>

<head>


<meta charset='utf-8'/>
<style>
/* CSS Document */

/*règles des liens textes*/
/*a:link { text-decoration:none; color:#FFF; }*/
a:visited { text-decoration:none; color:#FFF; }
a:hover { text-decoration:underline; color:#CCC; }
a:active { text-decoration:none; color:#CCC }



#dbm-table { /*conteneur du tableau*/
margin:0;
width: 100%;
font: 11px Arial, Helvetica, sans-serif;
color:black;
}

#dbm-header { /*header du tableau*/
text-align:center;
margin:0;
width: 100%
height: 65px;
color:#FFF;
font-size:13px;
background: #0c2c65; 
}




/*titre du tableau BT Businness*/
.header-text { 
font: bold 22px Arial, Helvetica, sans-serif;
text-align:center;
height: 65px;
}



/*ligne de titre - legende*/
#tb-top { 
text-align:center;
margin:0;
width: 100%;
height: 46px;
background:#EEE; 
}





/*cellules de titre de la ligne de legende Colonne 1 (application Name)*/
.tb-top-cell1 { 
float:left;
text-align:center;
width:15%;
height: 100%;
border-right: 1px solid #ced9ec;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
line-height:46px; 
}




/*cellules de titre de la ligne de legende Colonne 2 (URL)*/
.tb-top-cell2 { 
float:left;
text-align:center;
width:49%;
height: 100%;
border-right: 1px solid #ced9ec;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif; 
line-height:46px;
}


/*cellules de titre de la ligne de legende Colonne 3 (Statut Code)*/
.tb-top-cell3 { 
float:left;
text-align:center;
width:10%;
height: 100%;
border-right: 1px solid #ced9ec;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif; 
line-height:46px;
}



/*cellules de titre de la ligne de legende Colonne 4 (Statut Description)*/
.tb-top-cell4 { 
float:left;
text-align:center;
width: 10%;
height: 100%;
border-right: 1px solid #ced9ec;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif; 
line-height:46px;
}

/*cellules de titre de la ligne de legende Colonne 5 (Time Taken)*/
.tb-top-cell5 { 
float:left;
text-align:center;
width:15%;
height: 100%;
border-right: 1px solid #ced9ec;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif; 
line-height:46px;
}




/*ligne de titre - legende*/
#tb-top { 
text-align:center;
margin:0;
width: 100%;
height: 46px;
background:#EEE; 
}






*/....................................................................................*/

#tb-corps { /*corps du tableau*/
text-align:center;
margin:0;
width: 100%;
}



/*cellules de titre de la ligne des données Colonne 1 (application Name)*/
.tb-left-cell1 {
float:left;
text-align:center;
width: 15%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#ccc;
line-height:25px;
}




/*cellules de titre de la ligne des données Colonne 2 (URL)*/
.tb-left-cell2 {
float:left;
text-align: left;
width: 49%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#999;
line-height:25px;
}

/*cellules de titre de la ligne des données Colonne 3 (Statut Code)*/
.tb-left-cell3 {
float:left;
text-align: center;
width: 10%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#999;
line-height:25px;
}


/*cellules de titre de la ligne des données Colonne 4 (Statut Description)*/
.tb-left-cell4 {
float:left;
text-align: center;
width: 10%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#999;
line-height:25px;
}


/*cellules de titre de la ligne des données Colonne 5 (Time Taken)*/
.tb-left-cell5 {
float:left;
text-align: left;
width: 15%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#999;
line-height:25px;
}





















/*rollover des cellules de données en orange*/
.tb-left-cell1:hover {
background:#CA6500;
}
.tb-left-cell2:hover { 
background:#CA6500;
}
.tb-left-cell3:hover {
background:#CA6500;
}
.tb-left-cell4:hover {
background:#CA6500;
}
.tb-left-cell5:hover {
background:#CA6500;
}




/*passage de couleurs des cellules de données en vert de la case 4*/
.tb-left-green-cell4 {
float:left;
text-align: center;
width: 10%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#11B25C;
line-height:25px;
}




/*passage de couleurs des cellules de données en rouge de la case 4*/
.tb-left-red-cell4 {
float:left;
text-align: center;
width: 10%;
height: 25px;
border-right: 1px solid #ced9ec;
border-bottom: 1px solid #b3c1db;
color:#1f3d71;
font: 13px Arial, Helvetica, sans-serif;
background:#B9121B;
line-height:25px;
}




#tb-footer { /* footer du tableau*/
float:left;
text-align: left;
width: 100%;
font-size: 10px;
color:#8a8a8a;
background:#EEE;
}

</style>



</head>

<body>




<div id='dbm-table'>

<div id='dbm-header'>
<span class='header-text'>$Title0</span><br>
<a>$ReportingDate</a>
</div>

<div id='tb-top'>
<div class='tb-top-cell1'>Application Name</div>
<div class='tb-top-cell2'>URL</div>
<div class='tb-top-cell3'>Code Retour</div>
<div class='tb-top-cell4'>Status</div>
<div class='tb-top-cell5' style='border:none;'>Time Taken(Seconds)</div>
</div>




"
###########################################################################################################




	
###########################################################################################################
#Remplissage du tableau avec les valeurs
Foreach($application in $ResultSI)
{

	



    foreach($Entry in $application.UrlResults)
    {

	

#positionnement des valeurs
$Outputreport += "
		
		
	<div id='tb-corps'>
	<div class='tb-left-cell1'>$($Entry.ApplicationName)</div>
	<div class='tb-left-cell2'><a href=""$($Entry.uri)"">$($Entry.uri)</a></div>
	<div class='tb-left-cell3'>$($Entry.StatusCode)</div>"
	




	if($Entry.StatusCode -eq "200")
        {
        $Outputreport += "<div class='tb-left-green-cell4'>$($Entry.StatusDescription)</div>"
        }
		
	elseif($Entry.StatusCode -eq "400")
        {
		$Entry.timetaken = "Calcul non possible"
	    $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	elseif($Entry.StatusCode -eq "401")
        {
		$Entry.timetaken = "Calcul non possible"
        $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	elseif($Entry.StatusCode -eq "403")
        {
		$Entry.timetaken = "Calcul non possible"
        $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	elseif($Entry.StatusCode -eq "404")
        {
		$Entry.timetaken = "Calcul non possible"
        $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	elseif($Entry.StatusCode -eq "500")
        {
		$Entry.timetaken = "Calcul non possible"
        $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	elseif($Entry.StatusCode -eq "0")
        {
		$Entry.StatusDescription = "KO"
		$Entry.timetaken = "Calcul non possible"
        $Outputreport += "<div class='tb-left-red-cell4'>$($Entry.StatusDescription)</div>"
        }
	
	
	else
		{
		$Outputreport += "<div class='tb-left-cell4'>$($Entry.StatusDescription)</div>"
		}
	
	
	
	
	$Outputreport += "
	<div class='tb-left-cell5'>$($Entry.timetaken)</div>
	</div>"
	}
	

	
	
}
    $Outputreport += "

	<div id='tb-footer'>
	COPYRIGHT © L KUNTZMANN
	</div>

</div>
	
	</BODY>
	</HTML>
"
}
###########################################################################################################

# Generation d'un report HTML du resultat
$Outputreport | out-file $OutputFile_Horodater

# Envoi du mail
send_email


#Stop-Transcript
