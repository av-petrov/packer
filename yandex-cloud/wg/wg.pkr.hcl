variable "BUILD_VERSION" {
  type    = string
}

variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
}

variable "YC_SUBNET_ID" {
  type = string
}

variable "SOURCE_IMAGE_ID" {
  type    = string
}

variable "IMAGE_NAME" {
  type    = string
}

source "yandex" "wg" {
  folder_id       = "${var.YC_FOLDER_ID}"
  image_name      = "${var.image_name}-${var.build_version}"
  source_image_id = "${var.source_image_id}"
  ssh_timeout     = "60m"
  ssh_username    = "ubuntu"
  subnet_id       = ${var.YC_SUBNET_ID}"
  use_ipv4_nat    = "true"
  zone            = "${var.YC_ZONE}"
  instance_cores  = 2
  instance_mem_gb = 2
  disk_size_gb    = 5
}

build {
  sources = ["source.yandex.wg"]

  provisioner "file" {
    destination = "/tmp/wg.tgz"
    source      = "files/sensitive/wg.tgz"
  }

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "10s"
    script            = "files/install.sh"
    execute_command   = "chmod +x {{ .Path }}; {{ .Vars }} sudo {{ .Path }}"
  }
}
