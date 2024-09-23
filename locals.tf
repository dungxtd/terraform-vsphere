locals {
  filtered_datastores = [
    for ds in data.vsphere_datastore.datastores :
    ds if ds.stats.free >= var.vm_disk_size * 1024 * 1024 * 1024
  ]

  datastore_with_free_space = { for a in local.filtered_datastores : a.stats.free => a }

  datastore_selected = lookup(
    local.datastore_with_free_space,
    element(
      sort(keys(local.datastore_with_free_space)),
      length(local.datastore_with_free_space) - 1
    )
  )
}
