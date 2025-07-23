#!/bin/bash

set -euxo pipefail

# Maximum number of retries
MAX_RETRIES=5
# Delay between retries in seconds
RETRY_DELAY=10

# Check if ClusterDeployment is provisioned
check_clusterdeployment_provisioned() {
    # Read namespace from service account when running in cluster
    local namespace
    if [ -f "/var/run/secrets/kubernetes.io/serviceaccount/namespace" ]; then
        namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
    else
        namespace=$(oc project -q)
    fi

    set +e
    # Check if ClusterDeployment exists with same name as namespace
        if ! oc get clusterdeployment.hive.openshift.io "$namespace" -n "$namespace" &>/dev/null; then
            echo "ClusterDeployment $namespace not found in namespace $namespace" >&2
            set -e
            return 1
        fi

    # Check if Provisioned condition is True
    local provisioned_status=$(oc get clusterdeployment.hive.openshift.io "$namespace" -n "$namespace" -o jsonpath='{.status.conditions[?(@.type=="Provisioned")].status}')
    if [ "$provisioned_status" != "True" ]; then
        echo "ClusterDeployment $namespace is not fully provisioned yet. Current status: $provisioned_status" >&2
        set -e
        return 1
    fi

    echo "ClusterDeployment $namespace is provisioned, proceeding..."
    set -e
    return 0
}

check_accessgrant() {
    # Remove set -e temporarily for this function
    set +e
    oc --kubeconfig=kubeconfig get accessgrant -n hub-link hub-grant &> /dev/null
    local result=$?
    set -e
    return $result
}

# Function to generate AccessToken
generate_accesstoken() {
    # Remove set -e temporarily to allow our own error handling
    set +e

    cd $(mktemp -d)

    KUBECONFIG_SECRET=$(oc get secret -l hive.openshift.io/secret-type=kubeconfig -o name)
    oc extract $KUBECONFIG_SECRET

    # Check if 'remote-cluster-test' Link exists and has status 'Ready'
    if oc get link remote-$CLUSTER -o jsonpath='{.status.status}' 2>/dev/null | grep -q "Ready"; then
        echo "Skupper link remote-$CLUSTER already exists and is Ready. Skipping token creation."
        set -e
        return 0
    fi

    if oc get accesstoken remote-$CLUSTER 2>/dev/null; then
        echo "AccessToken exists but link is not set up, deleting AccessToken"
        oc delete accesstoken remote-$CLUSTER
    fi

    # Retry loop for AccessGrant
    local retry_count=0
    local url=""
    local code=""
    local ca=""

    while [ $retry_count -lt $MAX_RETRIES ]; do
        if check_accessgrant; then
            # Attempt to retrieve AccessGrant details
            url=$(oc --kubeconfig=kubeconfig get accessgrant -n hub-link hub-grant -o jsonpath={.status.url} 2>/dev/null)
            code=$(oc --kubeconfig=kubeconfig get accessgrant -n hub-link hub-grant -o jsonpath={.status.code} 2>/dev/null)
            ca=$(oc --kubeconfig=kubeconfig get accessgrant -n hub-link hub-grant -o jsonpath={.status.ca} 2>/dev/null)

            # Check if any of the values are empty
            if [ -z "$url" ] || [ -z "$code" ] || [ -z "$ca" ]; then
                echo "Warning: One or more AccessGrant status fields are empty. Retrying..." >&2
                retry_count=$((retry_count + 1))
                sleep $RETRY_DELAY
                continue
            fi

            # Generate AccessToken
            cat <<EOF | oc create -f -
apiVersion: skupper.io/v2alpha1
kind: AccessToken
metadata:
  name: remote-$CLUSTER
spec:
  url: ${url}
  code: ${code}
  ca: |
$(printf '%s\n' "$ca" | sed 's/^/    /')
EOF
            # Restore set -e and exit successfully
            set -e
            return 0
        else
            echo "AccessGrant not found. Retry $((retry_count + 1)) of $MAX_RETRIES" >&2
            retry_count=$((retry_count + 1))
            sleep $RETRY_DELAY
        fi
    done

    # If we've exhausted retries
    echo "Error: Could not find AccessGrant after $MAX_RETRIES attempts" >&2
    # Restore set -e and exit with error
    set -e
    return 1
}

# First check if ClusterDeployment is provisioned
# Infinite retry loop for ClusterDeployment provisioning check
echo "Waiting for ClusterDeployment to be provisioned..."
while true; do
    if check_clusterdeployment_provisioned; then
        # ClusterDeployment is provisioned, proceed with AccessToken generation
        generate_accesstoken
        exit $?
    else
        echo "ClusterDeployment not yet provisioned, checking again in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    fi
done
