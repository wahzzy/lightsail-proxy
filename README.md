# lightsail-node

Provision an AWS Lightsail instance as a small remote development node.

The node is prepared for:

- SSH access and interactive Codex CLI work.
- Optional Gost proxy services, including a Cloudflare WARP-backed path.

The project uses Terraform for infrastructure, Ansible for host setup, and a
small Python helper for updating an existing Cloudflare DNS A record.

## Components

- Terraform creates an Ubuntu 22.04 Lightsail instance and opens the required
  TCP ports.
- Ansible installs Node.js/Codex CLI, Gost, Certbot, Cloudflare WARP, and BBR
  tuning.
- The Python helper updates the instance IP in Cloudflare DNS.

The proxy setup is optional and is based on the setup documented at
<https://github.com/haoel/haoel.github.io>.

## Operations

See [OPERATIONS.md](OPERATIONS.md) for prerequisites, configuration, deployment,
connectivity testing, local proxy usage, and teardown.
