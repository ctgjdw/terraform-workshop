# Commands

bash

```
terraform init
terraform plan -auto-approve -var "do_token=${DO_TOKEN}" -var "ssh_private_key=${SSH_P_KEY}" -var "docker_host=${DOCKER_HOST}" -var "docker_cert_path=${DOCKER_CERT_PATH}"
terraform apply -auto-approve -var "do_token=${DO_TOKEN}" -var "ssh_private_key=${SSH_P_KEY}" -var "docker_host=${DOCKER_HOST}" -var "docker_cert_path=${DOCKER_CERT_PATH}"
```
