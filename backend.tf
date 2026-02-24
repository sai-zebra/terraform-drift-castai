terraform {
  backend "s3" {
    bucket = "zebra-dsk-statefile"
    key    = "terraform.tfstate"
    region = "eu-north-1"
    encrypt = true
  }
}