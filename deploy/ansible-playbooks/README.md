# Ansible playbooks

## Basic ansible playbook run
Example how to run the ansible playbook using the variables defined on playbook [bluegree-deploy.yml](./bluegreen-deploy.yml)
```
ansible-playbook -i inventory bluegreen-deploy.yml
```

## Ansible playbook with some vars
Example how to run the ansible playbook passing all the variables
```
ansible-playbook -i inventory -e 'k8s_context=k8s.dummy.com' \
                              -e 'micro_services=test-hello:v0.2.0' \
                              -e 'namespace=app-env' \
                              -e 'skip_image_check=true' \
                              bluegreen-deploy.yml
```
