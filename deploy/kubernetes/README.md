
# Kubernetes deployment
## Create the secret
This is a example how to create a kubernetes secret to be used from application to connect to the database.
```
  pg_password=$(pwgen -1 16) && \
  user_password=$(pwgen -1 16) && \
  echo "CREATE USER app_user WITH PASSWORD '${user_password}';
CREATE DATABASE application OWNER app_user;" | kubectl create secret generic database --from-file=0-bootstrap=/dev/stdin \
                                                                                      --from-literal=database_password=${pg_password} \
                                                                                      --from-literal=database_user=postgres \
                                                                                      --from-literal=database_url=postgresql://app_user:$user_password@database:5432/application
```

## Deploy the database service
This could be option if we use a managed database service like [AWS RDS](https://aws.amazon.com/rds/)
```
kubectl apply -f database.yaml
```
## Deploy the application
```
kubectl apply -f test-hello.yaml
```

