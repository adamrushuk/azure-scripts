#!/usr/bin/env bash

# Waits for an AKS disk to report "Unattached"

# vars
SUBSCRIPTION_NAME=""
AKS_CLUSTER_RESOURCEGROUP_NAME=""
AKS_CLUSTER_NAME=""
PVC_NAME=""

# login
az login
az account set --subscription "$SUBSCRIPTION_NAME"

# get cluster and associated "node resource group" (where resources live)
DISK_RESOURCEGROUP_NAME=$(az aks show --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_CLUSTER_RESOURCEGROUP_NAME" --query "nodeResourceGroup" --output tsv)

# define reusable function
get_disk_info() {
    az disk list --resource-group "$DISK_RESOURCEGROUP_NAME" --query "[?tags.\"kubernetes.io-created-for-pvc-name\" == '$PVC_NAME' ].{state:diskState, diskSizeGb:diskSizeGb, name:name, pvcname:tags.\"kubernetes.io-created-for-pvc-name\"}" --output table
}

# get disk associated with AKS PVC name
echo 'Waiting for disk to become "Unattached"...'
get_disk_info

# wait for disk state to detach
start_time=$SECONDS

while true; do
    # get disk info
    disk_output=$(get_disk_info)

    # check disk state
    if echo "$disk_output" | grep Attached; then
        sleep 10
    elif echo "$disk_output" | grep Unattached; then
        echo "Disk is now Unattached."
        break
    fi
done

elapsed_time=$(($SECONDS - $start_time))
echo "Disk took [$(($elapsed_time / 60))m$(($elapsed_time % 60))s] to change states"

# final disk info
get_disk_info
