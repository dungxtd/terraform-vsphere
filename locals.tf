locals {
  datastore_map = {
    for ds in data.vsphere_datastore.datastores : ds.name => ds.id
  }

  datastores = [
    for ds in data.vsphere_datastore.datastores :
    merge(ds, { free_gb = ds.stats.free / 1024 / 1024 / 1024 })
  ]

  filtered_datastores = [
    for ds in data.vsphere_datastore.datastores :
    ds if ds.stats.free >= min([for vm in var.vms : vm.vm_disk_size])
    * 1024 * 1024 * 1024
  ]

  # sorted_datastores = element(
  #     sort(keys(local.datastores)),
  #     length(local.datastore_with_free_space) - 1
  #   )

  # Remaining VMs to be deployed (initialized with all VMs from var.vms)
  remaining_vms = var.vms

  # Assign VMs to datastores while updating available free space
  assign_datastore = flatten([
    for datastore in local.datastores : [
      for vm_name, vm in local.remaining_vms :
      datastore.free_gb >= vm.vm_disk_size ? {
        vm_name              = vm_name
        datastore_id         = datastore.id
        datastore_name       = datastore.name
        remaining_free_space = datastore.free_gb - vm.vm_disk_size
        free_gb              = datastore.free_gb
      } : {}
    ]
  ])
}
