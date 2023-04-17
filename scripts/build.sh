#!env sh
#

echo $CR_PAT | docker login ghcr.io --username cmar-apps-81 --password-stdin

docker build --network host --force-rm -t test-hello:latest .

docker tag test-hello:latest ghcr.io/cmar-apps-81/test-hello:v0.1.0
docker push ghcr.io/cmar-apps-81/test-hello:v0.1.0

docker tag test-hello:latest ghcr.io/cmar-apps-81/test-hello:v0.2.0
docker push ghcr.io/cmar-apps-81/test-hello:v0.2.0

