provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.project_name
      Course  = "DLBSEPCP01_E"
      Owner   = "Tayanana Zifamba"
    }
  }
}

# CloudFront custom certificates must be created in us-east-1.
# This alias is declared so a later ACM certificate can be added
# without restructuring the provider block. The current stack uses
# the default CloudFront certificate, so no resource selects this alias yet.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project = var.project_name
      Course  = "DLBSEPCP01_E"
      Owner   = "Tayanana Zifamba"
    }
  }
}
