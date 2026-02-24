# resource "aws_instance" "web" {
#   for_each = {
#     web_a = aws_subnet.public_a.id
#     web_b = aws_subnet.public_b.id
#   }

#   ami           = var.ami
#   instance_type = "t3.micro"
#   subnet_id     = each.value

#   vpc_security_group_ids = [aws_security_group.web_ec2.id]
#   iam_instance_profile  = aws_iam_instance_profile.ec2_ssm.name
#   user_data = templatefile("userdata_front.sh", {
#     app_alb_dns = aws_alb.private.dns_name
#     repo_link   = var.repo_link
#   })

#   tags = {
#     Name = "${var.prefix}${each.key}"
#   }
# }

# resource "aws_instance" "app" {
#   for_each = {
#     app_a = aws_subnet.private_a.id
#     app_b = aws_subnet.private_b.id
#   }

#   ami           = var.ami
#   instance_type = "t3.micro"
#   subnet_id     = each.value

#   vpc_security_group_ids = [aws_security_group.app_ec2.id]
#   iam_instance_profile  = aws_iam_instance_profile.ec2_ssm.name
#   user_data = templatefile("userdata_back.sh", {
#     repo_link   = var.repo_link
#     db_instance = aws_db_instance.main.address
#     db_name = var.db_name
#     db_password = var.db_password
#     db_username = var.db_username
#   })

#   tags = {
#     Name = "${var.prefix}${each.key}"
#   }
# }


