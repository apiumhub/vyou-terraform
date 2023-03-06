resource "aws_acm_certificate" "vyou_ssl_cert" {
  private_key = "${file("${path.root}/key.pem")}"
  certificate_body = "${file("${path.root}/cert.pem")}"
  certificate_chain = "${file("${path.root}/chain.pem")}"

  tags = {
    project = var.project_id
  }
}