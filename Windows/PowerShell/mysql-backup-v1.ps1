#
# Backup Mysql Database
#
# to inspire :  https://gallery.technet.microsoft.com/scriptcenter/PowerShell-to-perform-a687f0df
#
# Author : Romain D.
# Website : https://rdr-it.com
#

#Location of the mysqldump.exe file
$mysqldumppath = "C:\Program Files\MySQL\MySQL Workbench 8.0 CE"
#7z.exe file location
$7zip = "C:\Program Files\7-Zip"
#Temporary location for dump dump mysql
$folderbackup = "W:\temp\"
#Location of backups
$folderstorebackup = "W:\Sauv_MySQL\"
#Duration in days to validate backups
$expirebackupdays = 14
$date = Get-Date 
$timestamp = "" + $date.day + $date.month + $date.year + "_" + $date.hour + $date.minute 
#Deleting powershell alerts, comment to view them
$ErrorActionPreference = "SilentlyContinue"

#Server and database parameter table
$backuplist = @{
    "Server_mysql_1" = @{
        "adr" = "IP adress";
        "user" = "root";
        "password" = "some_password";
        "port" = 3306;
        "databases" = @("database1";"database2";"database2";)
    };
    "Server_mysql_2" = @{
        "adr" = "IP adress";
        "user" = "root";
        "password" = "some_password";
        "port" = 3306;
        "databases" = @("database1";)
    }
}
cls
Write-Host "--== Backup start ==--" -ForegroundColor red
Write-Host " ==Start MySQL backup== " -ForegroundColor Blue

foreach( $servers in $backuplist ){
    # loop in backup list
    foreach($server in $servers.values){
        # Verification adr server
        if($server['adr'] -eq ""){
            Write-Host "Serveur sans adresse"
        }else{
            # Yes go to backup :)
            # Loop database
            foreach($db in $server['databases']){
                Write-Host "Traitement de la base " $db " sur " $server["adr"]
                # Affect var for passing at mysqldump
                $srv=$server["adr"] 
                $u=$server["user"] 
                $p=$server["password"]
                $pt=$server["port"]
                # Exec backup
                CD $mysqldumppath
                .\mysqldump.exe --host=$srv --port=$pt --user=$u --password=$p --column-statistics=0 --result-file=$folderbackup$db.sql $db
                # Compress backup
                CD $7zip
                .\7z.exe a -tzip $folderstorebackup$srv"_"$db"_"$timestamp".zip" $folderbackup$db.sql
                # Delete sql file
                DEL $folderbackup$db.sql
            }
        }      
   }
}
Write-Host " ==End MySQL backup== " -ForegroundColor Blue

Write-Host " ==Delete old backup more "$expirebackupdays" days == " -ForegroundColor Yellow
#Clean old backup file
CD $folderstorebackup
$oldbackups = gci *.zip*
for($i=0; $i -lt $oldbackups.count; $i++){ 
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-$expirebackupdays)){ 
        $oldbackups[$i] | Remove-Item -Confirm:$false 
    } 
} 

Write-Host "--== Backup completed ==--" -ForegroundColor red