locals {
  env      = "demo"
  platform = "aws"
  app      = "terraform"

  tags = {
    Environment = "dev"
    Project     = "webserver"
  }
}