terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.9.2"
    }
  }
}

#Provider settings
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

#Data sources

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

# resource "vsphere_folder" "folder" {
#   path          = var.vsphere_vm_folder
#   type          = "vm"
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastores" {
  count         = length(var.datastores)
  name          = var.datastores[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# data "template_cloudinit_config" "cloud-config" {
#   gzip          = true
#   base64_encode = true

#   # This is your actual cloud-config document.  You can actually have more than
#   # one, but I haven't much bothered with it.
#   part {
#     content_type = "text/cloud-config"
#     content      = <<-EOT
#                      #cloud-config
#                      packages:
#                        - my-interesting-application
#                        - rpmdevtools
#                      EOT
#   }
# }

# Resource
resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  guest_id             = var.vm_guest_id
  folder               = var.vm_folder
  tools_upgrade_policy = "upgradeAtPowerCycle"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  name = each.value.name

  num_cpus = var.vm_vcpu
  memory   = var.vm_memory
  firmware = var.vm_firmware
  disk {
    label            = var.vm_disk_label
    size             = var.vm_disk_size
    thin_provisioned = var.vm_disk_thin
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }

  extra_config = {
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/cloudinit/metadata.yaml", {
      interface   = var.interface
      dhcp        = var.dhcp
      hostname    = each.value.name
      ip_address  = each.value.vm_ip
      netmask     = var.vm_ipv4_netmask
      nameservers = jsonencode(var.vm_dns_servers)
      gateway     = var.vm_ipv4_gateway
    }))
    "guestinfo.metadata.encoding" = "base64",
    "guestinfo.userdata"          = base64encode(file("${path.module}/cloudinit/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
}