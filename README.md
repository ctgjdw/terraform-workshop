# Terraform on Digital Ocean

Provision a control server and provision an app stack in digital ocean.

**Please ensure all linux scripts and files (`do_token`) are in `LF` line endings.**

For raising the control server in `./control`:

- Use a terraform instance in your local PC (i.e. WSL/Windows):
- Get a PAT (access token) from Digital Ocean and populate `./control/do_token`
- Generate a SSH key and save to Digital Ocean (SSH key should be in the local PC's User's `.ssh` folder)
  - The key name saved in Digital Ocean should match the name defined in `digitalocean_ssh_key` in `./control/provider.tf` and `./workshop/resources.tf`

```bash
cd ./control

terraform init

export DO_TOKEN=$(cat ./do_token)

terraform plan -var "do_token=$DO_TOKEN" -auto-approve

terraform apply -var "do_token=$DO_TOKEN" -auto-approve
```

For raising the app stack in `./workshop`:

```bash
cd ./workshop

terraform init

export DO_TOKEN="token"

terraform plan -var "do_token=${DO_TOKEN}" \
-var "ssh_private_key=${SSH_P_KEY}" \
-var "docker_host=${DOCKER_HOST}" \
-var "docker_cert_path=${DOCKER_CERT_PATH}" \
-auto-approve

terraform apply -var "do_token=${DO_TOKEN}" \
-var "ssh_private_key=${SSH_P_KEY}" \
-var "docker_host=${DOCKER_HOST}" \
-var "docker_cert_path=${DOCKER_CERT_PATH}" \
-auto-approve
```
