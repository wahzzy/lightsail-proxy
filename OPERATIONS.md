# Operations

This document covers the lifecycle of the Lightsail node.

## What Gets Created

Terraform creates one Lightsail instance:

- Region: `ap-northeast-1`
- Availability zone: `ap-northeast-1a`
- Blueprint: `ubuntu_22_04`
- Bundle: `nano_3_0`
- Instance name: `vpn`
- Open TCP ports: `22`, `80`, `2053`, `2083`

Ansible prepares SSH access as `ubuntu`, installs Node.js 22 and the global
`@openai/codex` package, and can optionally start two Gost services:

- `gost-vpn`: direct server forwarding on port `2053`.
- `gost-warp-vpn`: Cloudflare WARP-backed forwarding on port `2083`.

## Prerequisites

Install locally:

- Terraform, Ansible, Python 3, and `pip`.
- AWS credentials with Lightsail permissions.
- A Cloudflare API token that can edit the target zone DNS record.
- A domain or subdomain represented by an existing Cloudflare DNS A record.
- Local `gost` if you want to use the proxy client.

AWS credentials can use the normal provider chain: environment variables,
shared credentials, or an AWS profile.

## Configuration

Create local configuration files from the templates:

```sh
cp template/inventory.template ansible/inventory
cp template/configs.yml.template python/configs.yml
```

Optionally create `terraform/vpn.tfvars`:

```hcl
tcp_ports = [22, 80, 2053, 2083]
```

After creating the instance, set its IP and SSH key in `ansible/inventory`:

```ini
[host]
<lightsail-public-ip>

[host:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=<path-to-private-key>
```

Set the Cloudflare values in `python/configs.yml`:

```yaml
domain: proxy.example.com
cloudflare_token: <cloudflare-api-token>
instance_ip: <lightsail-public-ip>
zone_id: <cloudflare-zone-id>
dns_record_id: <cloudflare-dns-record-id>
```

The DNS helper updates an existing record; it does not create one.

## Deploy

```sh
terraform -chdir=terraform init
terraform -chdir=terraform apply -var-file="vpn.tfvars"
terraform -chdir=terraform output instance_ip
```

Update both configuration files with the public IP, then install Python
dependencies and update DNS:

```sh
python3 -m pip install -r python/requirements.txt
cd python && python3 update_dns_record.py && cd ..
```

Wait for the domain to resolve to the Lightsail IP, then run:

```sh
ansible-playbook ansible/setup.yml -i ansible/inventory \
  --extra-vars "DOMAIN=<domain> USER=<proxy-user> PASS=<proxy-password> EMAIL=<certbot-email>"
```

The proxy setup requires the domain to resolve first. Certbot uses the
standalone HTTP challenge and therefore requires inbound port `80`.

If you only need an SSH/Codex node, skip the Cloudflare DNS and proxy setup.

## Test Connectivity

```sh
ansible-playbook ansible/test.yml -i ansible/inventory
```

After starting a local Gost client, test HTTP proxying:

```sh
gost -L http://:1442 -L socks5://:1443 \
  -F 'mwss://<proxy-user>:<proxy-password>@<domain>:2083'
curl -x http://127.0.0.1:1442 https://ifconfig.me
```

Use port `2053` instead of `2083` for the direct server path.

## Teardown

```sh
terraform -chdir=terraform destroy -var-file="vpn.tfvars"
```

Update or remove the Cloudflare DNS record after destroying the instance.

## Notes

- `python/update_dns_record.py` currently expects to run from the `python/`
  directory.
- Gost is pinned to v2.12.0 for CLI compatibility; upgrade deliberately.
- Terraform state and local configuration files are ignored by Git. Back them
  up if you need to preserve deployment metadata.
