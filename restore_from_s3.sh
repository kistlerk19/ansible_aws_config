#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# MySQL credentials
DB_USER="root"
DB_PASSWORD="Amalitech123"
DB_NAME="restoredb"

# S3 bucket details
S3_BUCKET="mysql-buck-42"

# Use a wildcard to match your backup files
# S3_FILE_PATTERN="world_backup_*.sql.gpg"

# Get the latest file matching the pattern
# LATEST_FILE=$(aws s3 ls "s3://${S3_BUCKET}/" | grep "${S3_FILE_PATTERN}" | sort | tail -n 1 | awk '{print $4}')

# if [ -z "${LATEST_FILE}" ]; then
#     echo "No backup file found matching the pattern ${S3_FILE_PATTERN}"
#     exit 1
# fi

# echo "Latest backup file: ${LATEST_FILE}"

LATEST_FILE="world_backup_20240708_155701.gpg.sql"

# Use LATEST_FILE instead of S3_FILE in the rest of your script
ENCRYPTED_FILE="${LOCAL_DIR}/${LATEST_FILE}"

# Download the encrypted file from S3
echo "Downloading encrypted backup from S3..."
aws s3 cp "s3://${S3_BUCKET}/${LATEST_FILE}" "${ENCRYPTED_FILE}"

# ... rest of your script ...

# Local file paths
LOCAL_DIR="/home/ubuntu/restore"
ENCRYPTED_FILE="${LOCAL_DIR}/${S3_FILE}"
DECRYPTED_FILE="${LOCAL_DIR}/decrypted_backup.sql"

# GPG passphrase
GPG_PASSPHRASE="Amalitech AWS ReStart"

# Ensure local directory exists
mkdir -p "${LOCAL_DIR}"

# Download the encrypted file from S3
echo "Downloading encrypted backup from S3..."
aws s3 cp "s3://${S3_BUCKET}/${S3_FILE}" "${ENCRYPTED_FILE}"

# Decrypt the file
echo "Decrypting backup file..."
gpg --batch --yes --passphrase "${GPG_PASSPHRASE}" --decrypt "${ENCRYPTED_FILE}" > "${DECRYPTED_FILE}"

# Load the decrypted file into MySQL
echo "Restoring MySQL database..."
mysql -u "${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < "${DECRYPTED_FILE}"

# Clean up
echo "Cleaning up..."
rm "${ENCRYPTED_FILE}" "${DECRYPTED_FILE}"

echo "Restore process completed successfully."