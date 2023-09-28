terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "elasticsearch_disk_out_of_space_incident" {
  source    = "./modules/elasticsearch_disk_out_of_space_incident"

  providers = {
    shoreline = shoreline
  }
}