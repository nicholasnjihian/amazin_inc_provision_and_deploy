
PROVISION AND DEPLOY.
--------------------
--------------------

*This README describes how I have provisioned and deployed a golang backend and a React frontend through Infrastructure as Code, Cloud Infrastructure & Configuration Management.*

1. I have used Terraform to come up with a configuration state for the cloud resources required and to provision the infrastructure. Terraform enables DevOps teams to define and provision cloud infrastructure using a very high-level and human-readable language known as Hashicorp Configuration Language, or optionally JSON.

2. Terraform will need an Amazon machine Image that I provide through Packer which is another open-source tool by HashiCorp that automates the creation of machine images. Packer can create Images for multiple platforms like Docker, AWS, Oracle VirtualBox, Linode, Azure,OpenStack,etc. Packer uses JSON to define its Packer templates, i.e configuration files.

3. I also use Ansible to do the actual configuration management, that is to configure the software in the OS and to install required software and to bring our cloud resources to the state that we desire. I have done this through Ansible playbook. However, here I use Ansible within Packer because Packer supports provisioners such as Ansible, Shell, Chef, among others.

4. The DB(Postgres is located in RDS) and physical backup snapshots are sent to S3.


#REQUIREMENTS

##STEP 1: AWS CREDENTIALS(AWS ACCESS KEY AND AWS SECRET KEY):

- Terraform uses the AWS credentials already in our system. That is, we should already have installed the AWS CLI and configured it using the aws configure command. 
- To get these AWS credentials a non-root IAM user (and group) has to be set up on the AWS Management Web Console. The IAM user will have the following policies:
i. 
ii.
iii.
iv.

Alternatively and even better(and for better security), we can use environmental variables to provide our AWS credentials, i.e. `AWS_SECRET_ACCESS_KEY` and `AWS_ACCESS_KEY_ID` representing the AWS secret key and access key respectively.
Once AWS CLI is configured, the credentials are stored in the '~/.aws/credentials' file (on OS X). 
So these commands would be:
`$export AWS_ACCESS_KEY_ID="abcd123"`
`$export AWS_SECRET_ACCESS_KEY="abcdef12323"`

If you need to install AWS CLI on Windows, instructions are at http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-msi-on-windows.

_Note: You may need to change the default location used but you have to take into consideration that the Machine Image(AMI) is specific to geographic location/availability zone. This region has to be changed in the packer json template file as Packer is the image builder._

###SET DATABASE PASSWORD AS ENVIRONMENT VARIABLE
Terraform requires this in its set up of Postgres on AWS RDS. This can be done by running:

`$ export TF_VAR_db_password = "YOUR DATABASE PASSWORD HERE"`
NOTE: There is a space before export so as not to store such sensitive info as a database password on disk in bash history.
