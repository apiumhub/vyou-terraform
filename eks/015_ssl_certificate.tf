resource "aws_acm_certificate" "vyou_ssl_cert" {
  private_key = "${file("${path.module}/key.pem")}"
  certificate_body = "${file("${path.module}/cert.pem")}"
  certificate_chain = "${file("${path.module}/chain.pem")}"

  tags = {
    project = var.project_id
  }
}