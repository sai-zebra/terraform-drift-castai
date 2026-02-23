# Terraform-Drift Process

**generates the ssh keys in the current directory**
```
ssh-keygen -t rsa -C "dsk@example.com" -f ./key
```
after creating the sg and ec2 with available terraform code, check for the resources managed by the terraform using
```
terraform state list
```


## follow the below commands to make drift

**1. Create the SG and capture ONLY the ID**
```
export SG_ID=$(aws ec2 create-security-group --group-name "sg_web" --description "allow 8080" --output text --query 'GroupId')
```
to know "sg_web" id
```
echo $SG_ID
```

**2. Add the ingress rule (using the captured ID)**
```
aws ec2 authorize-security-group-ingress --group-name "sg_web" --protocol tcp --port 8080 --cidr 0.0.0.0/0 --output text
```

**3. Attach it to your instance**
```
aws ec2 modify-instance-attribute --instance-id $(terraform output -raw instance_id) --groups $SG_ID --output text
```
**to check for drift**
```
terraform plan -refresh-only
```
**to apply the changes of drift (after verifying the changes through above command)**
```
terraform apply -refresh-only
```

## add resource to the main.tf (newly created and added "sg_web")
```
terraform import aws_security_group.sg_web $SG_ID
```
```
terraform import aws_security_group_rule.sg_web "$SG_ID"_ingress_tcp_8080_8080_0.0.0.0/0
```
after importing the "sg_web" now check for resources managed by the terraform
```
terraform state list
```

## access the instance
```
ssh ec2-user@$(terraform output -raw public_ip) -i key
```
```
curl $(terraform output -raw public_ip):8080
```