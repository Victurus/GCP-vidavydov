terraform {
 backend "gcs" {
   bucket  = "vidavydov-capstone"
   prefix  = "terraform/state"
 }
}
