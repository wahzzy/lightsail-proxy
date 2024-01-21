# lightsail-proxy

### Init 
`cd terraform`
`terraform init`

### Create Instance
`terraform apply -var-file="vpn.tfvars"`

### Config IP after Creating
1. terraform/inventory
2. config ip on cloudfare

### Run Ansible Playbook 
`ansible-playbook setup.yml -i inventory --extra-vars "DOMAIN=<domain> USER=<user> PASS=<pass> EMAIL=<email>"`

### Delete Instance
`terraform apply -var-file="vpn.tfvars" --destroy`

## TODO
1. Link inventory ip 
2. auto config cloudfare
3. auto run ansible command 
4. test

 


