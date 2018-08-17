variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable private_key_path {
  description = "Path to the private key used for privisioners connection"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west1-b"
}

variable count_vm {
  description = "Count"
  default     = 1
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "ubuntu-1604-lts"
}
