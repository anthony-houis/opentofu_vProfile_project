resource "aws_route53_zone" "vprofile_route53_zone" {
  name = "vprofile.in"
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
  tags = {
    "Name" = "vprofile.in"
  }
}

resource "aws_route53_record" "vprofile_route53_record_mariadb" {
  zone_id = aws_route53_zone.vprofile_route53_zone.zone_id
  name    = "db01.vprofile.in"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.mariadb_instance.private_ip}"]
}

resource "aws_route53_record" "vprofile_route53_record_rabbitmq" {
  zone_id = aws_route53_zone.vprofile_route53_zone.zone_id
  name    = "rmq01.vprofile.in"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.rabbitmq_instance.private_ip}"]
}

resource "aws_route53_record" "vprofile_route53_record_memcached" {
  zone_id = aws_route53_zone.vprofile_route53_zone.zone_id
  name    = "mc01.vprofile.in"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.memcached_instance.private_ip}"]
}
