############################
# Outputs for ESO Trusted Profile (AWS IRSA)
############################

# Output the IAM Role ARN (equivalent to IBM Trusted Profile ID)
output "trusted_profile_id" {
  description = "ARN of the IAM Role created for ESO, equivalent to the Trusted Profile ID in IBM."
  value       = aws_iam_role.trusted_profile.arn
}

# Output the IAM Role name (equivalent to IBM Trusted Profile name)
output "trusted_profile_name" {
  description = "Name of the IAM Role created for ESO, equivalent to the Trusted Profile name in IBM."
  value       = aws_iam_role.trusted_profile.name
}

