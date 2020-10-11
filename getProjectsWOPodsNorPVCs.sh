#!/bin/bash

NoResourcesString='No resources found.'

# Getting projects
echo "Getting all projects"
project_list=`oc get projects --no-headers | grep -v ^openshift | grep -v ^kube | awk '{ print $1 }' | xargs`

# Checking pods
echo "Checking projects without pods"
for project in ${project_list}
do
    errormessage=$(oc get pods -n $project 2>&1)
    if [[ ${errormessage} == ${NoResourcesString} ]]
    then
        nopvc=$(oc get pvc -n $project 2>&1)
        if [[ ${nopvc} == ${NoResourcesString} ]]
        then
            echo $project >> NoPodsNorPVCs.out
        fi
    fi
done
