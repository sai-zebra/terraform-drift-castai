# Terraform Drift & Cluster(EKS, GKE, AKS) Autoscaler & CAST AI

## 1️.What is Terraform Drift?
**Definition**
Terraform Drift occurs when the actual infrastructure in cloud(AWS,AKS,GCP,Oracle) differs from what is defined in the Terraform configuration and state file.
Terraform compares:
.tf configuration
terraform.tfstate
Actual Cloud infrastructure
If differences are found in Terraform-managed resources, drift is detected.
**Important Rule**
Drift happens only for resources that Terraform manages.
If Terraform is not managing a resource, it will ignore it completely.

## 2️.Scenario 1 – EC2 Created via Terraform + Manual EC2
**Situation**
ec2-1 → Created using Terraform

ec2-2 → Created manually from AWS Console

Will Drift Occur?
❌ No drift

Why?

Terraform:

Manages only ec2-1

Does not know ec2-2 exists

ec2-2 is not in .tf or terraform.tfstate

Therefore, terraform plan will not show any change.

When Drift WOULD Occur
If we:

Change ec2-1 instance type manually

Modify its security group manually

Add EBS manually

Stop/start instance manually

Then:
```
terraform plan
```
Terraform will detect mismatch and try to revert changes.

## 3️.Scenario 2 – EC2 Created via Manual Auto Scaling Group (ASG)
**Situation**
ASG created manually in using ec2-1 template

ec2-3 and ec2-4 created by that ASG

Will Drift Occur?
❌ No drift

Why?

Terraform is not managing:

The ASG

The EC2 instances created by ASG

So Terraform ignores them completely.

## 4️.Scenario 3 – ASG Created via Terraform
**Now things become important.**
Example Terraform:
```
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  min_size         = 1
  max_size         = 4
}
```
Now Terraform manages:

 * ASG configuration

 * desired_capacity

 * min_size

 * max_size
 
**Situation– ASG Scales Automatically (CloudWatch Policy)**
Example:
Terraform desired_capacity = 2
High CPU → ASG scales to 3
Is this drift?
✔ Technically yes
✔ But operationally expected behavior
Terraform will show:
``` 
~ desired_capacity: 3 -> 2
```
Terraform will try to revert scaling.
**Production Solution**
Use lifecycle block:
```
lifecycle {
  ignore_changes = [desired_capacity]
}
```
Now:
 * Terraform manages min/max
 * ASG manages dynamic scaling
 * No conflict
**Situation– Manual Change in ASG Configuration**
If someone changes:
 * min_size
 * max_size
* desired_capacity
From cloud Console:
✔ Drift occurs
✔ Terraform will revert changes
**Terraform does NOT manage individual EC2 instances inside ASG.**

## 5️.Kubernetes Cluster Autoscaler
What It Does
Cluster Autoscaler:
Watches pending pods
Increases node group size
Removes underutilized nodes
Works with:
EKS Managed Node Groups
ASG-backed node groups
Can Cluster Autoscaler Be Managed by Terraform?
✅ Yes — Terraform can:
Install Cluster Autoscaler (via Helm)
Configure node group min/max size
Manage EKS node groups
Example:
```
resource "aws_eks_node_group" "example" {
  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}
```
**What Terraform Cannot Control**
Terraform cannot control:
 * Runtime scaling decisions
 * Pod scheduling
 * Real-time scaling events
Cluster Autoscaler changes desired_size dynamically.
**Drift Problem in EKS**
If:
Terraform:
```
desired_size = 2
```
Cluster Autoscaler scales to 4.
Then:
```
terraform plan
```
Shows:
```
~ desired_size: 4 -> 2
```
Terraform tries to revert autoscaler scaling.
**Production Best Practice for EKS**
```
lifecycle {
  ignore_changes = [scaling_config[0].desired_size]
}
```
Now:
 * Terraform manages infrastructure boundaries
 * Autoscaler manages dynamic scaling
 * No conflict
 
## 6️.CAST AI use cases
Since we are using CASTAI in our organisation:
CAST AI:
 * Replaces Cluster Autoscaler 
 * Dynamically scales nodes (by the feature of AutoScaling and DownScaling)
 * Can change instance types
 * Performs rebalancing
**If Terraform controls desired_size:**
❌ Terraform and CAST AI will conflict
❌ Continuous drift
Solution:
```
lifecycle {
  ignore_changes = [scaling_config[0].desired_size]
}
```

## 7.Summary
Terraform manages infrastructure declaratively.
Drift occurs only when Terraform-managed resources are changed outside Terraform.
Dynamic systems like ASG, Cluster Autoscaler, or CAST AI modify runtime values.
To prevent conflict, we use lifecycle ignore_changes for dynamic attributes like desired_capacity and ``` terraform plan -refresh-only ``` command to know whether drifted arised or not.
