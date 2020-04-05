@echo off
CLS

For /f "tokens=2-4 delims=/ " %%i in ('date /t') do (set mydate=%%k%%j%%i)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

SET backuptime=%date:~6,4%%date:~3,2%%date:~0,2%_%mytime%
echo %backuptime%

SET	7zip_path=

"C:\Program Files\MySQL\MySQL Workbench 6.3 CE\mysqldump.exe" --host="192.168.0.0" --port="3306" --user="mysql_user" --password="password" -Q --result-file="C:\TEMP\db00_%backuptime%.sql" db00
"C:\Program Files\7-Zip\7z.exe" a -t7z "D:\Backup\db00_%backuptime%.sql.7z" "C:\TEMP\db00_%backuptime%.sql"


del "C:\TEMP\db00_%backuptime%.sql"