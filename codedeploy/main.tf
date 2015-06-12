resource "aws_iam_instance_profile" "codedeploy_ec2_profile" {
  name = "${var.aws_codedeploy_basename}-codedeploy-ec2-profile"
  roles = ["${aws_iam_role.codedeploy_ec2_role.name}"]
}

//Role for codedeploy EC2
resource "aws_iam_role" "codedeploy_ec2_role" {
  name = "${var.aws_codedeploy_basename}-codedeploy-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "codedeploy.us-east-1.amazonaws.com", 
          "codedeploy.us-west-2.amazonaws.com",
          "codedeploy.eu-west-1.amazonaws.com",
          "codedeploy.ap-southeast-2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_ec2_role_policy" {
  name = "policy_${var.aws_codedeploy_basename}-codedeploy-ec2-role"
  role = "${aws_iam_role.codedeploy_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {     
        "Action": [       
            "s3:Get*",       
            "s3:List*"     
        ],     
        "Effect": "Allow",     
        "Resource": [
          "arn:aws:s3:::${var.aws_codedeploy_basename}-codedeploy/*",
          "arn:aws:s3:::aws-codedeploy-us-east-1/*",
          "arn:aws:s3:::aws-codedeploy-us-west-2/*",        
          "arn:aws:s3:::aws-codedeploy-eu-west-1/*",
          "arn:aws:s3:::aws-codedeploy-ap-southeast-2/*"
        ]
    },
    {
      "Action": [
        "autoscaling:PutLifecycleHook",
        "autoscaling:DeleteLifecycleHook",
        "autoscaling:RecordLifecycleActionHeartbeat",
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:Describe*",
        "autoscaling:PutInstanceInStandby",
        "autoscaling:PutInstanceInService",
        "autoscaling:EnterStandby",
        "autoscaling:ExitStandby",
        "autoscaling:UpdateAutoScalingGroup",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

//Bucket for revision
resource "aws_s3_bucket" "aws_s3_codedeploy" {
  bucket = "${var.aws_codedeploy_basename}-codedeploy"
  acl = "private"

  tags {
    Name = "${var.aws_codedeploy_basename}-codedeploy"
    Environment = "${var.environment}"
  }
}

//IAM user for put revision on S3 and create revision
resource "aws_iam_user" "aws_iam_user_codedeploy" {
  name = "${var.aws_codedeploy_basename}-S3UserForCodeDeploy"
}

resource "aws_iam_access_key" "aws_iam_user_codedeploy" {
  user = "${aws_iam_user.aws_iam_user_codedeploy.name}"
}

resource "aws_iam_user_policy" "aws_iam_user_codedeploy_policy" {
  name = "policy_s3_${var.aws_codedeploy_basename}-codedeploy"
  user = "${aws_iam_user.aws_iam_user_codedeploy.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.aws_codedeploy_basename}-codedeploy/*"
      ]
    },
    {
            "Effect": "Allow",
            "Action": [
                "codedeploy:RegisterApplicationRevision",
                "codedeploy:GetApplicationRevision"
            ],
            "Resource": "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:application:${var.aws_codedeploy_appname}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetDeployment"
            ],
            "Resource": "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentgroup:${var.aws_codedeploy_appname}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:GetDeploymentConfig"
            ],
            "Resource": [
                "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
                "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
                "arn:aws:codedeploy:${var.aws_region}:${var.aws_account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
            ]
        }
  ]
}
EOF
}

//Role for codedeploy app
//TODO :  Policy Trust for Code Deploy
resource "aws_iam_role" "codedeploy_app_role" {
    name = "${var.aws_codedeploy_basename}-codedeploy-app-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.us-east-1.amazonaws.com", 
          "codedeploy.us-west-2.amazonaws.com",
          "codedeploy.eu-west-1.amazonaws.com",
          "codedeploy.ap-southeast-2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_app_role_policy" {
    name = "policy_${var.aws_codedeploy_basename}-codedeploy-app-role"
    role = "${aws_iam_role.codedeploy_app_role.id}"
    policy = <<EOF
{ 
  "Version": "2012-10-17", 
  "Statement": [   
    {     
        "Action": [       
            "s3:Get*",       
            "s3:List*"     
        ],     
        "Effect": "Allow",     
        "Resource": "arn:aws:s3:::${var.aws_codedeploy_basename}-codedeploy/*"  
    }    
  ]
}
EOF
}