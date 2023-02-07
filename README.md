# Contrast Agent Operator Demo

This repo is based on [AKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-aks-cluster) and [Provision and EKS Cluster (AWS)](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks), containing Terraform configuration files to provision an AKS or EKS cluster.

It provides a way of deploying a K8S service using Terraform, adding the Contrast Agent Operator then finally deploying your vulnerable applications.

# Pre-requisites

1. Install Terraform from here: https://www.terraform.io/downloads.html.
1. Install the Azure cli tools using `brew update && brew install azure-cli`.
1. Install kubectl

# Steps
1. Change directory to the [AKS](/terraform-aks/) or [EKS](/terraform-aks/) folder (AKS takes ~5 mins/AWS takes ~15 mins).
1. If your AWS/Azure CLI is not authenticated then log into the Azure (`az login`) or AWS CLI (`aws configure`) to cache your credentials.
1. Edit the [variables.tf](variables.tf) file (or add a terraform.tfvars) to add your initials and preferred Azure location. Example is here for EKS:

        region="us-east-1"
        initials="da"

1. Run `terraform init` to download the required plugins.
1. Run `terraform apply` to deploy a new cluster.
1. Grab your AKS or EKA credentials for kubectl:

        az aks get-credentials --resource-group $(terraform output resource_group_name | tr -d '"') --name $(terraform output kubernetes_cluster_name | tr -d '"')

        aws eks --region $(terraform output -raw region) update-kubeconfig \
        --name $(terraform output -raw cluster_name)

1. Install the Contrast Kubernetes operator:

        kubectl apply -f https://github.com/Contrast-Security-OSS/agent-operator/releases/latest/download/install-prod.yaml

1. Check the operator is running:

        kubectl -n contrast-agent-operator get pods

1. Configure the operator:

        kubectl -n contrast-agent-operator create secret generic default-agent-connection-secret --from-literal=apiKey=TODO --from-literal=serviceKey=TODO --from-literal=userName=TODO

1. Create a ClusterAgentConnection:

    ```
    kubectl apply -f - <<EOF
    apiVersion: agents.contrastsecurity.com/v1beta1
    kind: ClusterAgentConnection
    metadata:
      name: default-agent-connection
      namespace: contrast-agent-operator
    spec:
      template:
        spec:
          url: https://eval.contrastsecurity.com/Contrast
          apiKey:
            secretName: default-agent-connection-secret
            secretKey: apiKey
          serviceKey:
            secretName: default-agent-connection-secret
            secretKey: serviceKey
          userName:
            secretName: default-agent-connection-secret
            secretKey: userName
    EOF
    ```

1. Create an AgentInjector:

    ```
    kubectl apply -f - <<EOF
    apiVersion: agents.contrastsecurity.com/v1beta1
    kind: AgentInjector
    metadata:
      name: contrast-agent-injector
      namespace: default
    spec:
      type: java
      selector:
        labels:
          - name: contrast
            value: java
    EOF
    ```

1. Run an application that has the `contrast: java` label, e.g. webgoat:

        kubectl apply -f ../webgoat.yaml

1. You application should not be up. View the Kubernetes dashboard:

        az aks browse --resource-group $(terraform output resource_group_name | tr -d '"') --name $(terraform output  kubernetes_cluster_name | tr -d '"')

        aws ???

1. After your demo, run `terraform destroy --auto-approve` to remove all resources.

# Troubleshooting

1. If everything deployed but the app did not appear, check the application logs based on :

        kubectl -n default logs Deployment/webgoat

1. Show logging from the init container on the pod:

        kubectl logs Deployment/webgoat -c contrast-init

1. If Contrast isn't featured then check the operator logs:

        kubectl logs -f deployment/contrast-agent-operator  --namespace contrast-agent-operator

1. If you don't have operator logs, check everything is configured:

        kubectl get all,secrets,clusteragentconfiguration,clusteragentconnection --namespace contrast-agent-operator