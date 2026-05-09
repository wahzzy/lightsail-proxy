# lightsail-proxy

Provision an AWS Lightsail instance and configure it as a `gost` proxy server with TLS, optional Cloudflare WARP egress, and BBR enabled.

This project refers to the proxy setup documented at <https://github.com/haoel/haoel.github.io>.

The project uses:

- Terraform to create the Lightsail VM and open the required TCP ports.
- Ansible to install Docker, Certbot, Cloudflare WARP, BBR tuning, and `gost`.
- A small Python helper to update an existing Cloudflare DNS A record to the new Lightsail IP.

The setup is aimed at a domain you control in Cloudflare. Certbot uses the standalone HTTP challenge, so the domain must resolve to the Lightsail instance before the Ansible certificate step runs.

## What Gets Created

Terraform creates one Lightsail instance:

- Region: `ap-northeast-1`
- Availability zone: `ap-northeast-1a`
- Blueprint: `ubuntu_22_04`
- Bundle: `nano_3_0`
- Instance name: `vpn`
- Open TCP ports: `22`, `80`, `2053`, `2083`

Ansible starts two Docker containers from `ginuerzh/gost`:

- `vpn` listens on `2053` and forwards traffic directly from the server.
- `warp-vpn` listens on `2083` and forwards traffic through local Cloudflare WARP SOCKS proxy on `localhost:40000`.

## Prerequisites

Install these locally:

- Terraform
- Ansible
- Python 3
- `pip`
- AWS credentials with Lightsail permissions
- A Cloudflare API token that can edit the target zone DNS record
- A domain or subdomain already represented by a Cloudflare DNS A record
- `gost` on your local machine if you want to use the local proxy command

AWS credentials must be available to Terraform through the normal AWS provider chain, for example environment variables, shared credentials, or an AWS profile.

## Configuration Files

Runtime configuration files are intentionally ignored by Git. Create them from the templates:

```sh
cp template/inventory.template ansible/inventory
cp template/configs.yml.template python/configs.yml
```

Create `terraform/vpn.tfvars` if you want to override Terraform defaults:

```hcl
tcp_ports = [22, 80, 2053, 2083]
```

After Terraform creates the instance, update `ansible/inventory` with the public IP and SSH settings:

```ini
[host]
<lightsail-public-ip>

[host:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=<path-to-private-key>
```

Update `python/configs.yml` for the Cloudflare DNS helper:

```yaml
domain: proxy.example.com
cloudflare_token: <cloudflare-api-token>
instance_ip: <lightsail-public-ip>
zone_id: <cloudflare-zone-id>
dns_record_id: <cloudflare-dns-record-id>
```

## Deploy

Initialize Terraform:

```sh
terraform -chdir=terraform init
```

Create the Lightsail instance:

```sh
terraform -chdir=terraform apply -var-file="vpn.tfvars"
```

Read the public IP from Terraform output:

```sh
terraform -chdir=terraform output instance_ip
```

Update `ansible/inventory` and `python/configs.yml` with that IP.

Install the Python dependencies:

```sh
python3 -m pip install -r python/requirements.txt
```

Update the Cloudflare DNS A record:

```sh
cd python
python3 update_dns_record.py
cd ..
```

Wait for the domain to resolve to the Lightsail public IP, then run the Ansible setup:

```sh
ansible-playbook ansible/setup.yml -i ansible/inventory --extra-vars "DOMAIN=<domain> USER=<proxy-user> PASS=<proxy-password> EMAIL=<certbot-email>"
```

The playbook performs these steps:

- Installs Docker.
- Enables BBR in `/etc/sysctl.conf`.
- Installs Certbot and requests a TLS certificate for `DOMAIN`.
- Installs and connects Cloudflare WARP in proxy mode.
- Starts the two `gost` Docker containers.

## Local Proxy

Run a local `gost` client that exposes HTTP and SOCKS5 ports on your machine and forwards to the TLS websocket proxy:

```sh
gost -L http://:1442 -L socks5://:1443 -F 'mwss://<proxy-user>:<proxy-password>@<domain>:2083'
```

Use port `2083` for the WARP-backed server path, or port `2053` for the direct server path:

```sh
gost -L http://:1442 -L socks5://:1443 -F 'mwss://<proxy-user>:<proxy-password>@<domain>:2053'
```

## Test Connectivity

You can verify Ansible connectivity with:

```sh
ansible-playbook ansible/test.yml -i ansible/inventory
```

After starting the local `gost` client, test HTTP proxying with:

```sh
curl -x http://127.0.0.1:1442 https://ifconfig.me
```

## Teardown

Destroy the Lightsail resources:

```sh
terraform -chdir=terraform destroy -var-file="vpn.tfvars"
```

If you used Cloudflare DNS for this server, update or remove the DNS record after destroying the instance.

## Notes And Limitations

- The Cloudflare DNS record must already exist. The Python helper updates an existing record by `dns_record_id`; it does not create one.
- `python/update_dns_record.py` currently expects to be run from the `python/` directory.
- Certbot uses the standalone challenge and requires inbound port `80`.
- The Ansible role starts containers with fixed names: `vpn` and `warp-vpn`. Re-running the playbook may fail if containers with those names already exist.
- Terraform state and local config files are ignored by Git. Keep them backed up if you need to preserve the deployed instance metadata.
