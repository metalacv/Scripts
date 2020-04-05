#!/bin/sh
#
# @auteur : Romain Drouche
# @web : https://rdr-it.com
#
# prerequis : lftp
#
# Ce script archive et envoie un dossier sur un FTP distant.
# Utile pour sauvegarder vos vos serveurs dedie (debibox/ovh...)
#
cd / 
bkname=$(date +%Y%m%d%H%M)
dirlocal="/var/www/"
echo $bkname
echo "Dossier a sauvegarde:$dirlocal"
echo "Creation de l archive" 
tar zcf $bkname.tar.gz $dirlocal
echo "Archive OK"
echo "Connexion au FTP et transfert" 
lftp ftp://IDENTIFIANT:MOTDEPASSE@SERVEUR-FTP << EOF 
cd /
put $bkname.tar.gz
#dir
bye
EOF
echo "Sauvegarde termine"
rm $bkname.tar.gz
echo "Archive supprimee"
