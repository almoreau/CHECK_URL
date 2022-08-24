terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
      version = "1.5.0"
    }
  }
}

provider "nutanix" {
   username             = var.username
   password             = var.password
   endpoint           = "SRX-SMI-CVM-IP" # IP of Prism Element or Prism Central
}

variable "username" {
  description = "Value of Username"
  type        = string
  default     = "adm_moreau_a@.intranet"
}

variable "password" {
  description = "Value of Password"
  type        = string
  default     = "aaaaat"
}


resource "nutanix_virtual_machine" "vm-windows" {

 
  name                 = "swip-smi-frt12"
  description          = "Front Web IIS MUT"
  cluster_uuid         =  "000587e9-9979-6b25-1c9c-7cd30a6a4170"
  num_vcpus_per_socket = 2
  num_sockets          = 2
  memory_size_mib      = 4096
  # var_files = ["terraform.tfvars"]

  # This parent_reference is what actually tells the provider to clone the specified VM
  parent_reference = {
    kind = "vm"
    name = "TEMPLATE_IIS_CORE"
    uuid = "3ccf5c1d-58ac-468b-a17d-7b079d492c5a"
  }

  disk_list {

    data_source_reference = {
      kind = "vm"
      name = "TEMPLATE_IIS_CORE"
      uuid = "3ccf5c1d-58ac-468b-a17d-7b079d492c5a"
    }

    # Do not touch this, cloning randomly adds a CDROM device and will break if you don't define it here
    device_properties {
      device_type = "CDROM"
      disk_address = {
        device_index = 3
        adapter_type = "IDE"
      }
    }

  }

  serial_port_list {
    index = 0
    is_connected = "true"
  }

  nic_list {
    subnet_uuid = "1b1f9d83-ca66-4f1b-995e-91c25790fa94"
  }

}
