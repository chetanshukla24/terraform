variable "server_port" {
    description = "Port that will be opened to outside world"
    default = 8080
}

output "public_dns_ELB"  {
    value = "${aws_elb.example.dns_name}"
}
output "public_ips" {
  value = "${data.aws_instances.test.public_ips}"
}

locals {

    this_autoscaling_group_id                        = "${element(concat(coalescelist(aws_autoscaling_group.example.*.id, aws_autoscaling_group.this_with_initial_lifecycle_hook.*.id), list("")), 0)}"
  this_autoscaling_group_name                      = "${element(concat(coalescelist(aws_autoscaling_group.example.*.name, aws_autoscaling_group.this_with_initial_lifecycle_hook.*.name), list("")), 0)}"

}

output "this_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = "${aws_autoscaling_group.example.id}"
}

output "this_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = "${aws_autoscaling_group.example.name}"
}