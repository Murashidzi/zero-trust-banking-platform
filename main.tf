terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 5.0"
		}
	}

backend "s3" {
	bucket	= "terraform-state-devsecops-murashidzi"
	key	= "global/s3/terraform.tfstate"
	region	= "af-south-1"
	dynamodb_table = "terraform-locks"
	encrypt	= true
	}

}

provider "aws" {
	region = "af-south-1"
}
