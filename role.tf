provider "aws" {
  region  = "us-west-1"
}

resource "aws_iam_role" "BuildTrustRole" {
    name = "user15-BuildTrustRole"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "codebuild.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
    path = "/"
}

resource "aws_iam_role_policy" "CodeBuildRolePolicy" {
    name = "user15-CodeBuildRolePolicy"
    role = aws_iam_role.BuildTrustRole.id

    policy = <<-EOF
    {
      "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "CloudWatchLogsPolicy",
              "Effect": "Allow",
              "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "CodeCommitPolicy",
              "Effect": "Allow",
              "Action": [
                "codecommit:GitPull"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3GetObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3PutObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:PutObject"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "OtherPolicies",
              "Effect": "Allow",
              "Action": [
                "ssm:GetParameters",
                "ecr:*"
              ],
              "Resource": [
                "*"
              ]
            }
          ]
    }
    EOF
}

resource "aws_iam_role" "DeployTrustRole" {
    name = "user15-DeployTrustRole"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid" : "",
                "Effect" : "Allow",
                "Principal" : {
                    "Service": [
                        "codedeploy.amazonaws.com"
                    ]
                },
                "Action" : "sts:AssumeRole"
            }
        ]
    }
    EOF
    path = "/"
}

resource "aws_iam_role_policy" "CodeDeployRolePolicy" {
    name = "user15-CodeDeployRolePolicy"
    role = aws_iam_role.DeployTrustRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:AttachLoadBalancerTargetGroups",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutLifecycleHook",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        }]
    }
    EOF
}

resource "aws_iam_role" "PipelineTrustRole" {
    name = "user15-PipelineTrustRole"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "codepipeline.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
    path = "/"
}

resource "aws_iam_role_policy" "CodePipelinieRolePolicy" {
    name = "user15-CodePipelineRolePolicy"
    role = aws_iam_role.PipelineTrustRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Resource": ["*"],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:UploadArchive",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:CancelUploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codepipeline:*",
                "iam:ListRoles",
                "iam:PassRole",
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision",
                "lambda:*",
                "sns:*",
                "ecs:*",
                "ecr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:StartBuild",
                "codebuild:StopBuild",
                "codebuild:BatchGet*",
                "codebuild:Get*",
                "codebuild:List*",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:ListBranches",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "logs:GetLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
        }]
    }
    EOF
}

resource "aws_iam_role" "CodePipelineLambdaExecRole" {
    name = "user15-CodePipelineLambdaExecRole"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
    path = "/"
}

resource "aws_iam_role_policy" "CodePipelineLambdaExecPolicy" {
    name = "user15-CodePipelineLambdaExecPolicy"
    role = aws_iam_role.CodePipelineLambdaExecRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Action": [
                "codepipeline:PutJobSuccessResult",
                "codepipeline:PutJobFailureResult"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }]
    }
    EOF
}

resource "aws_s3_bucket" "S3Bucket" {
    bucket = "cicd-workshop-us-west-1-590526570343"
    
    versioning {
        enabled = true
    }
    
	tags = {
		Name = "CICDWorkshop-S3Bucket"
	}
}

output "BuildTrustRoleOutput" {
    value = aws_iam_role.BuildTrustRole.id
}

output "DeployTrustRoleOutput" {
    value = aws_iam_role.DeployTrustRole.id
}

output "PipelineTrustRoleOutput" {
    value = aws_iam_role.PipelineTrustRole.id
}

output "CodePipelineLambdaExecRoleOutput" {
    value = aws_iam_role.CodePipelineLambdaExecRole.id
}

output "S3BucketName" {
    value = aws_s3_bucket.S3Bucket.id
}