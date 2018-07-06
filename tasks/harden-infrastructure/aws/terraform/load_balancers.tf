### Load balancers

data "aws_elb" "pcf_http" {
  name = "${var.prefix}-Pcf-Http-Elb"
}

data "aws_iam_server_certificate" "pcf" {
  name_prefix = ""
  latest      = true
}

locals {
  listener = "${data.aws_elb.pcf_http.listener[0]}"
}

locals {
  elb_ssl_listener_definition = <<JSON
    [
      {
        "Protocol": "HTTPS",
        "LoadBalancerPort": 443,
        "InstanceProtocol": "HTTPS",
        "InstancePort": 443,
        "SSLCertificateId": "${local.listener["ssl_certificate_id"]}"
      },
      {
        "Protocol": "SSL",
        "LoadBalancerPort": 4443,
        "InstanceProtocol": "SSL",
        "InstancePort": 443,
        "SSLCertificateId": "${local.listener["ssl_certificate_id"]}"
      }
    ]
  JSON
}

resource "null_resource" "elb_forward_ssl" {
  /*
  triggers = {
    load_balancer_id = "${data.aws_elb.pcf_http.id}"
  }
 */
  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws elb delete-load-balancer-listeners --load-balancer-name ${data.aws_elb.pcf_http.name} --load-balancer-ports 443 4443 --region ${var.region}
      aws elb create-load-balancer-listeners --load-balancer-name ${data.aws_elb.pcf_http.name} --listeners '${local.elb_ssl_listener_definition}' --region ${var.region}
    CMD
  }
}

data "aws_elb" "pcf_ssh" {
  name = "${var.prefix}-Pcf-Ssh-Elb"
}

data "aws_elb" "pcf_tcp" {
  name = "${var.prefix}-Pcf-Tcp-Elb"
}
