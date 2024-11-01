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

data "vsphere_datastore" "datastores" {
  count         = length(var.datastores)
  name          = var.datastores[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# data "vsphere_virtual_machine" "template" {
#   name          = var.vm_template_name
#   datacenter_id = data.vsphere_datacenter.dc.id
# }

data "vsphere_virtual_machine" "template" {
  for_each      = var.vms
  name          = coalesce(each.value.vm_template_name, var.vm_template_name)
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Resource
resource "vsphere_virtual_machine" "vm" {
  for_each = var.vms

  datastore_id         = lookup(local.datastore_map, each.value.vm_datastore, null)
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  guest_id             = var.vm_guest_id
  folder               = var.vm_folder
  tools_upgrade_policy = "upgradeAtPowerCycle"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template[each.key].network_interface_types[0]
  }

  name = each.value.name

  num_cpus             = each.value.vm_vcpu
  num_cores_per_socket = coalesce(each.value.vm_num_cores_per_socket, 1)
  memory               = each.value.vm_memory * 1024
  firmware             = var.vm_firmware
  disk {
    label            = var.vm_disk_label
    size             = each.value.vm_disk_size
    thin_provisioned = var.vm_disk_thin
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template[each.key].id
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
