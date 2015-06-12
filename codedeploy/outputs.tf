output "codedeploy_ec2_profile" {
  value = "${aws_iam_instance_profile.codedeploy_ec2_profile.name}"
}

output "codedeploy_ec2_role_arn" {
  value = "${aws_iam_role.codedeploy_ec2_role.arn}"
}

output "codedeploy_iam_access_key_id" {
  value = "${aws_iam_access_key.aws_iam_user_codedeploy.id}"
}

output "codedeploy_iam_access_key_secret" {
  value = "${aws_iam_access_key.aws_iam_user_codedeploy.secret}"
}

output "codedeploy_iam_arn" {
  value = "${aws_iam_access_key.aws_iam_user_codedeploy.arn}"
}

output "codedeploy_s3_bucketname" {
  value = "${var.aws_codedeploy_basename}-codedeploy"
}