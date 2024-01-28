# lightsail-proxy
> https://github.com/haoel/haoel.github.io

## Preparation
1. godaddy
2. cloudflare
3. lightsail

## Setup/delete proxy server
### Init 
`terraform -chdir=terraform init`

### Create Instance
`terraform -chdir=terraform apply -var-file="vpn.tfvars"`

### Config IP after Creating
1. ./ansible/inventory
2. ./python/configs.yml -> `python3 python/update_dns_record.py`

### Run Ansible Playbook 
`ansible-playbook ansible/setup.yml -i ansible/inventory --extra-vars "DOMAIN=<domain> USER=<user> PASS=<pass> EMAIL=<email>"`

### Delete Instance
`terraform -chdir=terraform apply -var-file="vpn.tfvars" --destroy`

## Setup local proxy
`gost -L http://:1442 -L socks5://:1443 -F 'mwss://<user>:<password>@<domain>:2083'`

## TODO
1. Link inventory ip 
2. auto config cloudfare
3. auto run ansible command 
4. test

 


