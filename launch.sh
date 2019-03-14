eval "$(ssh-agent -s)"
ssh-add ~/.ssh/cloudbase
terraform plan -out="terraform.plan" && terraform apply "terraform.plan"
emacs "/ssh:alexs@`terraform output instance_ip_addr`:/home/alexs" &
mosh "alexs@`terraform output instance_ip_addr`"
eval "$(ssh-agent -k)"
