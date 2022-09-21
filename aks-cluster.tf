provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "Sales-Engineer-AKS-${var.initials}"
  location = var.location

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "Sales-Engineer-AKS-${var.initials}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "Sales-Engineer-AKS-${var.initials}"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}
