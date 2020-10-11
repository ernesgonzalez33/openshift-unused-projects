#!/bin/bash

NoResourcesString='No resources found.'
# Change the following variable to check for older or newer IS
DaysInSeconds=7776000 

# Getting projects
echo "Getting all projects"
project_list=`oc get projects --no-headers | grep -v ^openshift | grep -v ^kube | awk '{ print $1 }' | xargs`

# Getting image streams
echo "Getting image streams older than a year"
for project in ${project_list}
do
    errormessage=$(oc get is -n $project 2>&1)
    selected=0
    if [[ ${errormessage} != ${NoResourcesString} ]]
    then
        imageStreams=$(oc get is --no-headers -n $project | awk '{ print $1 }' | xargs)
        for is in $imageStreams
        do
            if [[ $selected == 0 ]]
            then 
                dates=$(oc get is $is -o jsonpath="{.status.tags[*].items[*].created}" -n $project)
                latestDate=0
                for date in $dates
                do
                    isDate=$(date -d ${date} +%s)
                    if [[ $latestDate -le $isDate ]]
                    then
                        latestDate=$isDate
                    fi
                done
                currentDate=$(date -u +%s)
                resul=$(( currentDate - latestDate )) 
                if [[ $resul -le $DaysInSeconds ]]
                then
                    selected=1
                fi
            fi
        done
        if [[ $selected == 0 ]]
        then
            echo $project >> OldIS.out
        fi
    fi
done