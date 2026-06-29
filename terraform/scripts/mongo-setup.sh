#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Install AWS CLI and dependencies
apt-get update -y
apt-get install -y awscli curl gnupg cron

# Install outdated MongoDB 4.4 (intentional weakness)
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update -y
apt-get install -y mongodb-org=4.4.29 mongodb-org-server=4.4.29

# Bind MongoDB to all interfaces but require auth
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
sed -i '/^#security:/a security:\n  authorization: enabled' /etc/mongod.conf

systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to be ready
sleep 15

# Create admin user - MongoDB 4.4 uses 'mongo' not 'mongosh'
mongo --eval "
  db = db.getSiblingDB('admin');
  db.createUser({
    user: 'wizadmin',
    pwd: 'wizpassword123',
    roles: [{ role: 'root', db: 'admin' }]
  });
"

# Store bucket name for backup script
echo "${bucket_name}" > /etc/mongo-backup-bucket

# Create backup script
cat > /usr/local/bin/mongo-backup.sh << 'BACKUPSCRIPT'
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/tmp/mongo-backup-$DATE"
BUCKET=$(cat /etc/mongo-backup-bucket)
mongodump --host=localhost --port=27017 \
  --username=wizadmin --password=wizpassword123 \
  --authenticationDatabase=admin \
  --out="$BACKUP_DIR"
tar -czf "/tmp/mongo-backup-$DATE.tar.gz" -C /tmp "mongo-backup-$DATE"
aws s3 cp "/tmp/mongo-backup-$DATE.tar.gz" "s3://$BUCKET/backups/mongo-backup-$DATE.tar.gz"
rm -rf "$BACKUP_DIR" "/tmp/mongo-backup-$DATE.tar.gz"
BACKUPSCRIPT

chmod +x /usr/local/bin/mongo-backup.sh

# Run daily at 2am
echo "0 2 * * * root /usr/local/bin/mongo-backup.sh >> /var/log/mongo-backup.log 2>&1" \
  > /etc/cron.d/mongo-backup

systemctl enable cron
systemctl start cron