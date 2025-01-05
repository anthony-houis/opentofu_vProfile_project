resource "aws_security_group" "vprofile-ELB-sg" {
  name        = "vprofile-ELB-sg"
  description = "Security group for vProfile load balancer"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "vprofile-ELB-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.vprofile-ELB-sg.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_ELB_ipv4" {
  security_group_id = aws_security_group.vprofile-ELB-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "vprofile-app-sg" {
  name        = "vprofile-app-sg"
  description = "Security group for vProfile tomcat application"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "vprofile-app-sg"
  }

  depends_on = [aws_security_group.vprofile-ELB-sg]
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_app" {
  security_group_id = aws_security_group.vprofile-app-sg.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ELB_to_app" {
  security_group_id            = aws_security_group.vprofile-app-sg.id
  referenced_security_group_id = aws_security_group.vprofile-ELB-sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_app_ipv4" {
  security_group_id = aws_security_group.vprofile-app-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "vprofile-backend-sg" {
  name        = "vprofile-backend-sg"
  description = "Security group for vProfile database"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "vprofile-backend-sg"
  }

  depends_on = [aws_security_group.vprofile-app-sg]
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_app_to_mysql" {
  description                  = "Allow traffic from vProfile app to MySQL"
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-app-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_app_to_rabbitmq" {
  description                  = "Allow traffic from vProfile app to RabbitMQ"
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-app-sg.id
  from_port                    = 5672
  ip_protocol                  = "tcp"
  to_port                      = 5672
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_app_to_memcached" {
  description                  = "Allow traffic from vProfile app to Memcached"
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-app-sg.id
  from_port                    = 11211
  ip_protocol                  = "tcp"
  to_port                      = 11211

}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_backend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_internally_sg" {
  description                  = "Allow all traffic internally"
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-backend-sg.id
  from_port                    = 0
  ip_protocol                  = "-1"
  to_port                      = 65535

  depends_on = [aws_security_group.vprofile-backend-sg]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_from_backend_ipv4" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}