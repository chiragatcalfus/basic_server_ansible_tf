#!/bin/bash

cd ./terraform

# Generate inventory file
terraform init
terraform apply -auto-approve
terraform output -json > tf_output.json

# Extract and format
echo "[web_servers]" > ../ansible/inventory.ini
upper_bound=$(jq -r 'keys_unsorted[]' tf_output.json | grep '^web-app-' | sed 's/web-app-//' | sort -n | tail -1)
i=1
while [ $i -le "$upper_bound" ]; 
do
    ip=$(jq -r ".[\"web-app-${i}\"].value // empty" tf_output.json)
    if [ -n "$ip" ]; then
        echo "$ip" >> ../ansible/inventory.ini
    fi
    i=$((i + 1))
done

echo "
[web_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/ec2-testing-key.pem
ansible_ssh_common_args=-o StrictHostKeyChecking=no -o IdentitiesOnly=yes " >> ../ansible/inventory.ini

echo "Ansible inventory generated at ../ansible/inventory.ini"
echo "Waiting for the system checks to complete for the aws instances"
sleep 20

ansible-playbook -i ../ansible/inventory.ini ../ansible/deploy_nginx.yaml
echo "Check the ip address for the deployment"
