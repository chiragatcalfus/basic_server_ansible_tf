# Basic Server Ansible Terraform

This project automates the deployment of 4 EC2 instances and configures them with Nginx servers using Terraform and Ansible.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Ansible installed

## Quick Start

1. **Configure AWS**
   ```bash
   aws configure
   ```

2. **Clone and navigate to the repository**
   ```bash
   git clone <repository-url>
   cd basic_server_ansible_tf
   ```

3. **Set executable permissions**
   ```bash
   chmod +x apply.sh
   chmod +x destroy.sh
   ```

4. **Deploy infrastructure and configure servers**
   ```bash
   ./apply.sh
   ```

5. **Clean up resources**
   ```bash
   ./destroy.sh
   ```

## What it does

- Creates 4 EC2 instances using Terraform
- Automatically runs Ansible playbooks to install and configure Nginx on all instances
- Sets up a basic web server environment ready for use

## Files

- `apply.sh` - Deploys infrastructure and runs configuration
- `destroy.sh` - Tears down all created resources
- Terraform configuration files for EC2 provisioning
- Ansible playbooks for Nginx installation and configuration