#!/bin/bash

# Getting projects
echo "Getting all projects with test in its names" 
oc get projects --no-headers | grep -v ^openshift | grep -v ^kube | grep "test" | awk '{ print $1 }' >> TestProjects.out