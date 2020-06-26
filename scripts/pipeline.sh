#!/bin/bash
./get_requisite_software.sh
./get_infra_interview_repo.sh

echo ""
echo "Building machine image using Packer"
#Run Packer
./packer_generate_ami.sh

echo ""
echo "Running terraform to provision infrastructure"
#Then after running Packer
#Now run Terraform


#First In S3
cd ../terraform/global/s3/ && terraform init && terraform plan
terraform apply -auto-approve

#Database terraform
cd ../../stage/data-stores/postgresql/
terraform init && terraform plan && terraform apply -auto-approve

#And now for the EC2 Instances, load balancers and auto-scaling groups
cd ../../services/webserver-cluster/
terraform init && terraform plan && terraform apply -auto-approve


echo "Provisioning Done"

echo "Post-provisioning tasks"

