# Contrast Agent Operator Demo

This repo includes examples of how to create a Kubernetes cluster, deploy the Contrast Agent Operator and some known vulnerable applications. Typical deployment times:

* AKS - 5 mins
* EKS - 20 mins

---

## Deploying on Azure/AKS

This deployment will typically take ±5 minutes.

### Pre-requisites for Azure/AKS

1. Install Terraform from here: <https://www.terraform.io/downloads.html>.
1. Install the Azure cli tools using `brew update && brew install azure-cli`.
1. Install kubectl using `brew update && brew install kubectl`.

### Steps for Azure/AKS

1. Change directory to the [AKS](/terraform-aks/) folder
1. If your Azure CLI is not authenticated then log into the Azure (`az login`)  to cache your credentials.
1. Create a terraform.tfvars file to add your initials and preferred Azure location, for example:

        location="UK South"
        initials="da"

1. Run `terraform init` to download the required plugins.
1. Run `terraform apply` to deploy a new cluster.
1. Grab your AKS credentials for kubectl:

        az aks get-credentials --resource-group $(terraform output resource_group_name | tr -d '"') --name $(terraform output kubernetes_cluster_name | tr -d '"')

1. Deploy the operator and demo apps.
1. View the Kubernetes dashboard (optional):

        az aks browse --resource-group $(terraform output resource_group_name | tr -d '"') --name $(terraform output  kubernetes_cluster_name | tr -d '"')

1. After your demo, run `terraform destroy --auto-approve` to remove all resources.

---

## Deploying on AWS/EKS

### Pre-requisites for AWS/EKS

1. Install kubectl using `brew update && brew install kubectl`.
1. Install the AWS CLI using `brew update && brew install awscli`.
1. If your AWS CLI is not authenticated then run (`aws configure`)  to cache your credentials.
1. Install eksctl using `brew update && brew install eksctl`.

### Steps for AWS/EKS

1. Create a K8S cluster using `eksctl create cluster --name sales-engineering-da --region us-east-2`
1. Grab your EKS credentials for kubectl: `aws eks update-kubeconfig --region us-east-2 --name sales-engineering-da`
1. After your demo, run `eksctl delete cluster --name sales-engineering-da --region us-east-2` to remove all resources.

---

## Installing the Contrast Agent Operator

1. Install the operator:

        kubectl apply -f https://github.com/Contrast-Security-OSS/agent-operator/releases/latest/download/install-prod.yaml

1. Configure the operator using one of the two options below:

### Express Configuration

1. Rename the [config-template.yaml](config-template.yaml) to config.yaml and add your agent credentials on lines 9-11. This file includes agent injectors for all languages.
1. Run `kubectl apply -f config.yaml`

### Step by Step Configuration

1. Configure the operator credentials:

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

1. Create an AgentInjector (this should be done per target language - example is for Java):

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

---

## Deploying Applications

1. Make sure you have the relevant agent injector created and deploy vulnerable applications from the apps folder, e.g.: `kubectl apply -f /apps/webgoat.yaml`

1. Visit your application in the browser via the external IP. Remember to add `/WebGoat` (or equivalent): `kubectl get services`

---

## Troubleshooting

### Troubleshoot the Application  

1. Check the app has the correct Contrast annotations: `kubectl describe Deployment/webgoat`

1. Check if Contrast is mentioned in the application logs: `kubectl -n default logs Deployment/webgoat`

1. Show logging from the init container on the pod: `kubectl logs Deployment/webgoat -c contrast-init`

### Troubleshoot the Agent Operator  

1. Check the operator is running: `kubectl -n contrast-agent-operator get pods`

1. Check the operator logs: `kubectl logs -f deployment/contrast-agent-operator  --namespace contrast-agent-operator`

1. If you don't have operator logs, check everything is configured:

        kubectl get all,secrets,clusteragentconfiguration,clusteragentconnection --namespace contrast-agent-operator

1. Elevate the operator logging:

        kubectl -n contrast-agent-operator set env deployment/contrast-agent-operator CONTRAST_LOG_LEVEL=Trace