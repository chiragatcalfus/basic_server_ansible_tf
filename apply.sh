#!/bin/bash

cd ./frontend

docker buildx build --platform linux/amd64 -t chiragatcalfus/basic-html-image .
docker login
docker push chiragatcalfus/basic-html-image:latest

cd ../terraform

echo "Running Terraform Plan..."
terraform plan -detailed-exitcode -out=tfplan

PLAN_EXIT_CODE=$?

if [[ $PLAN_EXIT_CODE -eq 0 ]]; then
    echo "No changes. Skipping apply and delay."
elif [[ $PLAN_EXIT_CODE -eq 2 ]]; then
    echo "Changes detected. Applying Terraform..."
    terraform init
    terraform apply -auto-approve
    # generated new inventory file
    terraform output -json > tf_output.json
    echo "Waiting for instances to become healthy..."

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
    #delay for the instances to start
    sleep 5

else 
    echo "tf plan failed"
    exit 1
fi

ansible-playbook -i ../ansible/inventory.ini ../ansible/deploy_nginx.yaml
echo "Check the ip address for the deployment"
