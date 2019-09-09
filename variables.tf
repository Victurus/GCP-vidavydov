variable "project_name" {}
variable "billing_account" {}
variable "org_id" {}
variable "region" {}
variable "ansible_user" {
  default = "ansible"
}
variable "ansible_user_pub_key_path" {
  default = "./ssh_keys/id_rsa.pub"
}
variable "boot_disk" {
  default = "ubuntu-1604-xenial-v20170328"
}
