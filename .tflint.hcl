plugin "terraform" {
  enabled = true

  version = "0.5.0"
  
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  preset  = "recommended"
}

plugin "aws" {
    enabled = true
    deep_check = true
    
    version = "0.30.0"
    
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}