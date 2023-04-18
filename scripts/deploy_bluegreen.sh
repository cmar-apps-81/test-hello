#!env sh
#
# bluegreen: this script prentends to simulate the bluegreen deployment on kubernetes
#

# kubernetes context (e.g. CONTEXT="--context k8s.dummy.com")
CONTEXT=${CONTEXT:-}
# kubernetes namespace (e.g. NAMESPACE="--namespace app-env")
NAMESPACE=${NAMESPACE:-}
# kubernetes deployment service
DEPLOYMENT=${DEPLOYMENT:-test-hello}
# the service version
NEW_VERSION=${NEW_VERSION:-v0.2.0}

semver_regex='v(0|[1-9][0-9]*)([.-])(0|[1-9][0-9]*)([.-])(0|[1-9][0-9]*)(-[a-zA-Z0-9]+)?'
deploy_timeout="3m"

# get current deployment output
current_deployment_output=$(kubectl get deployments ${NAMESPACE} ${CONTEXT} | grep -w "^${DEPLOYMENT}" | awk '{print $1}')
echo "Get current deployment: ${current_deployment_output}"

# get current deployment name
old_deployment_name=$(echo ${current_deployment_output} | sed 's/^\(.*\)-v\(.*\)$/\1/')

old_version=$(echo v$(echo ${current_deployment_output} | sed 's/^\(.*\)-v\(.*\)$/\2/'))

if [ "${old_version}" != "${NEW_VERSION}" ]; then

    sed_replace_version=$(echo ${NEW_VERSION} | sed -r "s/${semver_regex}/v\1\\\2\3\\\4\5\6/")

    echo "Deploy the new version: ${NEW_VERSION}"

    # deploy the new version
    new_deployment_output=$(kubectl get deployment ${current_deployment_output} ${NAMESPACE} ${CONTEXT} -o yaml | sed -r "s,${semver_regex},${sed_replace_version}," | kubectl apply ${CONTEXT} -f -)

    echo "Wait to the new deployment activate: ${DEPLOYMENT}-${NEW_VERSION}"

    rollout_output=$(timeout ${deploy_timeout} kubectl rollout status deployment.v1.apps/${DEPLOYMENT}-${NEW_VERSION} ${NAMESPACE} ${CONTEXT} -w)
    rollout_rc=$?

    if [ ${rollout_rc} -eq 0 ]; then

        # get current service name
        service_output=$(kubectl get svc ${NAMESPACE} ${CONTEXT} | grep -w "^${DEPLOYMENT}" | awk '{print $1}')

        echo "Change the service to the new deployment"

        # update service to new deployment version
        update_service_output=$(kubectl patch svc ${service_output} ${NAMESPACE} ${CONTEXT} -p "{\"spec\":{\"selector\": { \"version\": \"${NEW_VERSION}\"}}}")

        # check if have horizontal pod autoscalers for this deployment
        check_hpa_output=$(kubectl get hpa ${DEPLOYMENT} ${NAMESPACE} ${CONTEXT})
        check_hpa_rc=$?

        if [ ${check_hpa_rc} -eq 0 ]; then

            echo "Change the hpa to the new deployment"

            update_hpa_output=$(kubectl get hpa ${DEPLOYMENT} ${NAMESPACE} ${CONTEXT} -o yaml | sed -r "s,${semver_regex},${sed_replace_version}," | kubectl apply ${CONTEXT} -f -)
        fi

        echo "Clean old deployment"

        # clean old deployment
        revert_deployment_output=$(kubectl delete deployment ${DEPLOYMENT}-${old_version} ${NAMESPACE} ${CONTEXT})

    else
        echo "Unable to activate the new deployment"

        # revert the deploy
        revert_deployment_output=$(kubectl delete deployment ${DEPLOYMENT}-${NEW_VERSION} ${NAMESPACE} ${CONTEXT})
    fi
else
    echo "New version of service already deployed."
fi
