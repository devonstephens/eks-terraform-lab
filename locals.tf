locals {
  cluster_name = "lab-eks-${random_string.suffix.result}"
  
  tags = {
   Environment = var.env
   Terraform = "true"
  }
}

#Not a local, but used to generate cluster name, so I included here
resource "random_string" "suffix" {
  length  = 8
  special = false
}