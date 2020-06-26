#!/bin/bash

#Packer will give us a custom AMI that will be referenced for Terraform's provision.
AMI_ID=`packer build -machine-readable ./packer/packer_template.json | awk -F, '$0 ~/artifact,0,id/ {print $6}'`
echo 'variable "AMI_ID" { default = "'${AMI_ID}'" }' > amivar.tf 
