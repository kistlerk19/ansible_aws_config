#!/bin/bash

echo "Select an option:"
echo "1. Backup"
echo "2. Restore"
read choice

if [ "$choice" -eq 1 ]; then
    echo "Enter the directory to save the backup:"
    read backup_dir
    mysqldump -u root -p classicmodels > $backup_dir/classicmodels_backup.sql
    gpg -c $backup_dir/classicmodels_backup.sql
    scp -i /home/ubuntu/ansible_aws $backup_dir/classicmodels_backup.sql.gpg ubuntu@10.2.0.56:/home/ubuntu/mysql_bk
elif [ "$choice" -eq 2 ]; then
    echo "Enter the directory of the backup file:"
    read backup_dir
    gpg $backup_dir/classicmodels_backup.sql.gpg
    mysql -u root -p < $backup_dir/classicmodels_backup.sql
else
    echo "Invalid option."
fi


#!/bin/bash
sudo apt-get update
sudo apt-get install mysql-server -y
sudo mysql_secure_installation
sudo systemctl status mysql