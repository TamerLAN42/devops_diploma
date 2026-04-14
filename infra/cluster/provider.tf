provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.instance_zone
}

variable "cloud_id" {
	type		= string
	description	= "Organization cloud id"
	nullable = false
	sensitive = true
}

variable "folder_id" {
	type		= string
	description	= "Cloud folder id"
	nullable = false
	sensitive = true
}