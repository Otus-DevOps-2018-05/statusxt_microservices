terraform {
  backend "gcs" {
    bucket = "statusxt-1"
    prefix = "terraform/state"
  }
}
