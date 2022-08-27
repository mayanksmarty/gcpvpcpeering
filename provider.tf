provider "google" {
  project     = var.project_id
  region      = var.resource_region[0]
  credentials = file("./credentials/crediantials.json")
}