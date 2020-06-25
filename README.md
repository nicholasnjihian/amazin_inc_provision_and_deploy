
PROVISION AND DEPLOY.
--------------------
--------------------

*This README describes how I have provisioned and deployed a golang backend and a React frontend through Infrastructure as Code and CI-CD concepts.*

1. I have used Terraform to come up with a configuration state for the cloud resources required and to provision the infrastructure. Terraform enables DevOps teams to define and provision cloud infrastructure using a very high-level and human-readable language known as Hashicorp Configuration Language, or optionally JSON.

2. Terraform will need an Amazon machine Image that I provide through Packer which is another open-source tool by HashiCorp that automates the creation of machine images. Packer can create Images for multiple platforms like Docker, AWS, Oracle VirtualBox, Linode, Azure,OpenStack,etc. Packer uses JSON to define its Packer templates, i.e configuration files.

3. I also use Ansible to do the actual configuration management, that is to configure the software in the OS and to install required software and to bring our cloud resources to the state that we desire. I have done this through Ansible playbook. However, here I use Ansible within Packer because Packer supports provisioners such as Ansible, Shell, Chef, among others.

4. For CI-CD, I have used Jenkins to confirm our builds for the Golang backend and React frontend. I have installed Jenkins in the cloud so that devops teams can upload their code and it will be vetted and built/tested as required. This cannot be done on each individual team member's computer desktop/laptop. The Jenkins install is also handled by Ansible.

5. The DB(Postgres is located in RDS) and physical backup snapshots are sent to S3. 
