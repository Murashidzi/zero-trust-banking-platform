# Creating the Trust Provider (Who is calling ?)
# Instruct AWS to trust "token.actions.githubusercontent.com"

resource "aws_iam_openid_connect_provider" "github" {
	url = "https://token.actions.githubusercontent.com"
	client_id_list = ["sts.amazonaws.com"]
	thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

# Create the Role (The Robot's Identity)
resource "aws_iam_role" "github_actions" {
	name = "github-actions-deployer"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRoleWithWebIdentity"
				Effect = "Allow"
				Principal = {
					Federated = aws_iam_openid_connect_provider.github.arn
				}
				Condition = {
					StringLike = {
						# Only allow my repository to use this role
						"token.actions.githubusercontent.com:sub": "repo:Murashidzi/zero-trust-banking-platform:*"
					}
				}
			}
		]
	})
}

# Give the Robot Permissions (Administrator) so it can build VPCs, EKS, IAM, etc.
resource "aws_iam_role_policy_attachment" "github_admin" {
	role = aws_iam_role.github_actions.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Output the Role ARN (need for github)
output "github_role_arn" {
	value = aws_iam_role.github_actions.arn
}
