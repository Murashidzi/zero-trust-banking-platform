terraform {

	backend "s3" {
		bucket	= "terraform-state-devsecops-murashidzi"
		key	= "global/s3/terraform.tfstate"
		region	= "af-south-1"
		dynamodb_table = "terraform-locks"
		encrypt	= true
	}
}
