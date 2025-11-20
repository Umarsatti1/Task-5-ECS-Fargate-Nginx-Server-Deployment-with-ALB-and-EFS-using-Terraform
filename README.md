# AWS ECS Fargate Nginx Server Deployment with ALB and EFS using Terraform

This repository contains a fully modular Terraform configuration for deploying a production‑ready AWS containerized application using:

- **Amazon ECS Fargate**
- **Application Load Balancer (ALB)**
- **Elastic File System (EFS)**
- **Elastic Container Registry (ECR)**
- **VPC with public/private subnets**
- **IAM roles & security groups**

---

## Project Structure

    terraform-project/
    ├── terraform.tf          # Provider, version, S3 backend
    ├── main.tf               # Connects all modules together
    ├── variables.tf          # Root variables
    ├── outputs.tf            # Exposed outputs (ECR URI and ALB DNS Name)
    ├── terraform.tfvars      # User-supplied values
    └── modules/
        ├── vpc/
        ├── sg/
        ├── ecr/
        ├── alb/
        ├── task_definition/
        └── ecs/

---

## Architecture Diagram

<p align="center">
  <img src="./images/Architecture Diagram.png" alt="Architecture Diagram" width="850">
</p>

---

## Architecture Overview

This deployment builds a scalable ECS Fargate service integrated with an ALB for traffic distribution and EFS for persistent storage. All AWS resources are organized into isolated Terraform modules for maintainability and reusability.

---

## Features

### **Networking**
- VPC with DNS Hostnames enabled  
- Public + private subnets across two AZs  
- NAT Gateways for private subnets  
- Route tables, IGW, and subnet associations  
- Security groups for ALB, ECS, and EFS  

### **ECR**
- Private Docker repository  
- Easy push instructions directly from console  

### **EFS**
- Encrypted file system  
- Multi-AZ mount targets  
- Access Point for ECS task mounting  

### **ECS + Task Definition**
- ECS Fargate cluster  
- Rolling deployments  
- EFS volume mounting  
- CloudWatch logs enabled  
- IAM task execution role + EFS access policy  

### **ALB**
- Internet-facing Application Load Balancer  
- Listener on port 80  
- Target group for ECS tasks  

---

## Running the Application Locally (Optional)

Before deploying to AWS, you can test the application locally using Docker:

### **1. Build Docker Image**
```bash
docker build -t my-nginx-app .
```

### **2. Run Locally**
```bash
docker run -p 8080:80 my-nginx-app
```

Now open:

```
http://localhost:8080
```

### **3. Test EFS-like directory locally**
Create a directory to simulate EFS storage:

```bash
mkdir -p local-efs
docker run -p 8080:80 -v $(pwd)/local-efs:/mnt/data my-nginx-app
```

---

## Deploying the Infrastructure

Run the following commands in the root Terraform directory:

```bash
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```

After deployment, Terraform outputs:

- **ALB DNS Name** → used to access the application  
- **ECR Repo URL** → used for pushing Docker images  

---

## Push Docker Image to ECR

```bash
aws ecr get-login-password --region <region>   | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com

docker build -t nginx-repo .
docker tag nginx-repo:latest <account>.dkr.ecr.<region>.amazonaws.com/nginx-repo:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/nginx-repo:latest
```

Once pushed, ECS will automatically pull the new image and start tasks.

---

## Validating Deployment

After pushing the image and ECS tasks are running:

1. Go to **EC2 → Load Balancers**
2. Copy the **ALB DNS Name**
3. Paste it into your browser  
4. The static webpage should load successfully

---

## Cleanup

Destroy all deployed infrastructure:

```bash
terraform destroy --auto-approve
```

If state lock appears:

```bash
terraform force-unlock <LOCK_ID>
```

---

## Troubleshooting Tips

### **EFS not mounting?**
Ensure:
```
enable_dns_hostnames = true
```
is set in the VPC module.

### **Invalid container path?**
Use:
```
/mnt/data
```
instead of `/`.

### **State lock error?**
Use:
```
terraform force-unlock <LOCK_ID>
```

---
