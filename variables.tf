#Provider -  VMware vSphere Provider

variable "vsphere_user" {
  description = "vSphere username to use to connect to the environment"
}

variable "vsphere_password" {
  description = "vSphere password to use to connect to the environment"
}

variable "vsphere_server" {
  description = "vCenter server FQDN or IP"
  default     = "fv-vcenter7.vprod.datad.local"
}

# Infrastructure - vCenter / vSPhere environment

variable "vsphere_datacenter" {
  description = "vSphere datacenter in which the virtual machine will be deployed"
  default     = "Fibertown_DataCenter"
}

variable "vsphere_host" {
  description = "vSphere ESXi host FQDN or IP"
  default     = "dd-ng9x-06.esxi.datad.local"
}

variable "vsphere_compute_cluster" {
  description = "vSPhere cluster in which the virtual machine will be deployed"
  default     = "User_DEV_Cluster"
}

variable "vm_folder" {
  default = "/Users/Dev/RK Tech"
}

variable "datastores" {
  type = list(string)
  default = [
    "Dev_UserCluster_LargevMs_DataStore_Lun1",
    "Dev_UserCluster_LargevMs_DataStore_Lun2",
    "Dev_UserCluster_LargevMs_DataStore_Lun3",
    "Dev_UserCluster_LargevMs_DataStore_Lun4",
    "Dev_UserCluster_LargevMs_DataStore_Lune5",
    "Dev_UserCluster_LargevMs_DataStore_Lune6",
    "Dev_UserCluster_LargevMs_DataStore_Lune7"
  ]
  description = "vSPhere datastore list"
}

variable "vsphere_datastore" {
  description = "Datastore in which the virtual machine will be deployed"
  default     = "Dev_UserCluster_LargevMs_DataStore_Lune7"
}

variable "vsphere_network" {
  description = "Portgroup to which the virtual machine will be connected"
  default     = "Dev_Network_Blade_NG9X_06"
}

variable "vm_firmware" {
  description = "Firmware of virtual machine, if templates is different from default"
}

#VM

variable "vm_template_name" {
  description = "VM template with vmware-tools and perl installed"
}

variable "vm_guest_id" {
  description = "VM guest ID"
}

variable "vm_vcpu" {
  description = "The number of virtual processors to assign to this virtual machine."
  default     = "1"
}

variable "vm_memory" {
  description = "The size of the virtual machine's memory in MB"
  default     = "1024"
}

variable "vm_ipv4_netmask" {
  description = "The IPv4 subnet mask"
}

variable "vm_ipv4_gateway" {
  description = "The IPv4 default gateway"
}

variable "vm_dns_servers" {
  description = "The list of DNS servers to configure on the virtual machine"
}

variable "interface" {
}

variable "dhcp" {
}

variable "vm_domain" {
  description = "Domain name of virtual machine"
}

variable "vms" {
  type        = map(any)
  description = "List of virtual machines to be deployed"
}

variable "vm_disk_label" {
  description = "Disk label of the created virtual machine"
}

variable "vm_disk_size" {
  description = "Disk size of the created virtual machine in GB"
}

variable "vm_disk_thin" {
  description = "Disk type of the created virtual machine , thin or thick"
}
