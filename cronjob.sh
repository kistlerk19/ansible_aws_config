#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# MySQL credentials
DB_USER="root"
DB_PASSWORD="Amalitech123"
DB_NAME="world"

# Backup directory
BACKUP_DIR="/home/ubuntu/backup"
mkdir -p "${BACKUP_DIR}"  # Ensure the backup directory exists

# Current date and time
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Backup filenames
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql"
ENCRYPTED_BACKUP_FILE="${BACKUP_FILE}.gpg"

# GPG passphrase
GPG_PASSPHRASE="Amalitech AWS ReStart"

MYSQLDUMP_PATH=$(which mysqldump)
AWS_PATH=$(which aws)
GPG_PATH=$(which gpg)

# Dump MySQL database to the backup file
echo "Starting MySQL dump..." >> "${BACKUP_DIR}/backup_mysql.log"
if ! ${MYSQLDUMP_PATH} -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > ${BACKUP_FILE} 2>> "${BACKUP_DIR}/backup_mysql.log"; then
    echo "MySQL dump failed" >> "${BACKUP_DIR}/backup_mysql.log"
    exit 1
fi

echo "MySQL dump completed successfully" >> "${BACKUP_DIR}/backup_mysql.log"

# Encrypt the backup file
echo "Encrypting backup file..." >> "${BACKUP_DIR}/backup_mysql.log"
if ! echo "${GPG_PASSPHRASE}" | ${GPG_PATH} --batch --yes --passphrase-fd 0 -c -o ${ENCRYPTED_BACKUP_FILE} ${BACKUP_FILE} 2>> "${BACKUP_DIR}/backup_mysql.log"; then
    echo "Encryption failed" >> "${BACKUP_DIR}/backup_mysql.log"
    exit 1
fi

echo "Encryption completed successfully" >> "${BACKUP_DIR}/backup_mysql.log"

# Upload encrypted file to S3
echo "Starting S3 upload..." >> "${BACKUP_DIR}/backup_mysql.log"
if ! ${AWS_PATH} s3 cp ${ENCRYPTED_BACKUP_FILE} s3://mysql-buck-42/ 2>> "${BACKUP_DIR}/backup_mysql.log"; then
    echo "S3 upload failed" >> "${BACKUP_DIR}/backup_mysql.log"
    exit 1
fi

echo "S3 upload completed successfully" >> "${BACKUP_DIR}/backup_mysql.log"

# Clean up local files
# rm ${BACKUP_FILE}
# rm ${ENCRYPTED_BACKUP_FILE}

# echo "Local cleanup completed" >> "${BACKUP_DIR}/backup_mysql.log"