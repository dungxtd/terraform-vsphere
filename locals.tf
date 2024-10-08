locals {
  datastore_map = {
    for ds in data.vsphere_datastore.datastores : ds.name => ds.id
  }

  datastores = [
    for ds in data.vsphere_datastore.datastores :
    merge(ds, { free_gb = ds.stats.free / 1024 / 1024 / 1024 })
  ]

  min_disk_size = min([for vm in values(var.vms) : vm.vm_disk_size]...)

  filtered_datastores = [
    for ds in local.datastores :
    ds if ds.stats.free >= local.min_disk_size * 1024 * 1024 * 1024
  ]

  datastore_with_free_space = { for a in local.filtered_datastores : a.stats.free => a }

  sorted_datastores = element(
    sort(keys(local.datastore_with_free_space)),
    length(local.datastore_with_free_space) - 1
  )

  # # Remaining VMs to be deployed (initialized with all VMs from var.vms)
  # remaining_vms = var.vms

  # # Assign VMs to datastores while updating available free space
  # assign_datastore = flatten([
  #   for datastore in local.datastores : [
  #     for vm_name, vm in local.remaining_vms :
  #     datastore.free_gb >= vm.vm_disk_size ? {
  #       vm_name              = vm_name
  #       datastore_id         = datastore.id
  #       datastore_name       = datastore.name
  #       remaining_free_space = datastore.free_gb - vm.vm_disk_size
  #       free_gb              = datastore.free_gb
  #     } : {}
  #   ]
  # ])
}
