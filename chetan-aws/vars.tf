variable "server_port" {
    description = "Port that will be opened to outside world"
    default = 8080
}

output "public dns"  {
    value = "${aws_elb.example.dns_name}"
}
#output "public_ip" {
 # value = "${aws_instance.server.public_ip}"
#}