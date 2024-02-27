#!/bin/bash
read -p "Enter IP: " IP
read -p "Enter username: " USERNAME
container_ids=$(docker ps -q)
for container_id in $container_ids; do
    timestamp=$(date +%Y%m%d-%H%M%S)
    docker commit "$container_id" "$container_id:$timestamp"
    docker save "$container_id:$timestamp" > "/var/containerbk/$container_id-$timestamp.bk"
    if ping -c 1 "$IP" >/dev/null 2>&1; then
        sftp "$USERNAME@$IP" <<EOF
        lcd /var/containerbk
        cd /var/containerbk
        put "$container_id-$timestamp.bk"
        ls
        bye
EOF
    else
        echo "The server is not accessible..."
        exit 1
    fi
done


