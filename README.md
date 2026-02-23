ssh-keygen -t rsa -C "dsk@example.com" -f ./key

# 1. Create the SG and CORRECTLY capture ONLY the ID
export SG_ID=$(aws ec2 create-security-group --group-name "sg_web" --description "allow 8080" --output text --query 'GroupId')

echo $SG_ID

# 2. Add the ingress rule (using the captured ID)
aws ec2 authorize-security-group-ingress --group-name "sg_web" --protocol tcp --port 8080 --cidr 0.0.0.0/0 --output text

# 3. Attach it to your instance
aws ec2 modify-instance-attribute --instance-id $(terraform output -raw instance_id) --groups $SG_ID --output text

terraform plan -refresh-only
terraform apply -refresh-only

# add resource to the main.tf (newly created and added sg)

terraform import aws_security_group.sg_web $SG_ID

terraform import aws_security_group_rule.sg_web "$SG_ID"_ingress_tcp_8080_8080_0.0.0.0/0


terraform state list

# access the instance
ssh ec2-user@$(terraform output -raw public_ip) -i key

curl $(terraform output -raw public_ip):8080