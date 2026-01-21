# THis creates a private garage for the Docker images
resource "aws_ecr_repository" "bank_app" {
	name = "zero-trust-bank"
	image_tag_mutability = "MUTABLE"

	# Security: Scan images for viruses on upload
	image_scanning_configuration {
		scan_on_push = true
	}

	# Force delete even if it has images (for this lab)
	force_delete = true
}

output "ecr_repo_url" {
	value = aws_ecr_repository.bank_app.repository_url
}
