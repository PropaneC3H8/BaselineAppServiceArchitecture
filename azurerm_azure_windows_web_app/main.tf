data "azurerm_client_config" "current" {}

#**************** Resource Group ****************

resource "azurerm_resource_group" "rg" {
  name     = var.resourcegroup_name
  location = var.location
}

#**************** Virtual Network ****************

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = var.resourcegroup_name
  address_space       = var.vnet_address_spaces
  tags                = var.tags
}

#**************** Subnets ****************

resource "azurerm_subnet" "integration_subnet" {
  name                                      = var.integration_subnet_name
  resource_group_name                       = var.resourcegroup_name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = var.integration_subnet_address_prefix
  service_endpoints                         = var.integration_subnet_service_endpoints
  private_endpoint_network_policies_enabled = false

  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "endpoint_subnet" {
  name                 = var.endpoint_subnet_name
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.endpoint_subnet_address_prefix
  service_endpoints    = var.endpoint_subnet_service_endpoints
}

#**************** Storage Account ****************

resource "azurerm_storage_account" "storage" {
  depends_on               = [azurerm_subnet.endpoint_subnet]
  name                     = var.storage_acc_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_acc_tier
  account_replication_type = var.storage_acc_repl_type
  tags                     = var.tags

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.endpoint_subnet.id]
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_private_dns_zone" "storage_blob_dns_private" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_dns_vnet_link" {
  name                  = "storage-account-blob-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob_dns_private.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "storage_table_dns_private" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_table_dns_vnet_link" {
  name                  = "storage-account-table-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table_dns_private.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone" "storage_queue_dns_private" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue_dns_vnet_link" {
  name                  = "storage-account-queue-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_queue_dns_private.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "storage_file_dns_private" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file_dns_vnet_link" {
  name                  = "storage-account-file-vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file_dns_private.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  tags                  = var.tags
}

#**************** Key Vault ****************

resource "azurerm_key_vault" "keyvault" {
  name                          = var.key_vault_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = true
  enable_rbac_authorization     = false
  soft_delete_retention_days    = 7

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.endpoint_subnet.id]
    ip_rules = ["41.193.87.186"]
  }
}

data "azuread_service_principal" "devops_sp" {
  display_name = var.devops_sp
}

resource "azurerm_key_vault_access_policy" "devops_principal" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]

  storage_permissions = [
    "Get",
    "List",
    "Delete",
    "Set",
    "Update",
    "Backup",
    "RegenerateKey",
    "SetSAS",
    "ListSAS",
    "GetSAS",
    "DeleteSAS"
  ]
}

resource "azurerm_private_dns_zone" "keyvault_dns_private" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_endpoint" "keyvault_private_endpoint" {
  depends_on = [
  azurerm_key_vault.keyvault]
  name                = var.key_vault_private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "health-mining-tierprod-kv-pvt-conn"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names = [
    "vault"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.keyvault_dns_private.name
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault_dns_private.id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_dns_vnet_link" {
  name                  = var.key_vault_vnet_link
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dns_private.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

#**************** Key Vault Secrets ****************

resource "random_password" "password" {
  count       = length(var.secrets)
  length      = 15
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "azurerm_key_vault_secret" "secrets" {
  depends_on   = [azurerm_key_vault.keyvault, azurerm_key_vault_access_policy.devops_principal]
  count        = length(var.secrets)
  name         = var.secrets[count.index]
  value        = random_password.password[count.index].result
  key_vault_id = azurerm_key_vault.keyvault.id
}

#**************** MS SQL ****************

resource "azurerm_mssql_server" "mssql_server" {
  depends_on                   = [random_password.password]
  name                         = var.mssql_server_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = var.mssql_server_version
  administrator_login          = var.sql_username
  administrator_login_password = random_password.password[0].result
}

resource "azurerm_mssql_database" "mssql_database" {
  depends_on                  = [azurerm_mssql_server.mssql_server]
  name                        = var.mssql_database_name
  server_id                   = azurerm_mssql_server.mssql_server.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  min_capacity                = 2
  max_size_gb                 = 4
  read_scale                  = false
  sku_name                    = "GP_S_Gen5_2"
  auto_pause_delay_in_minutes = 720
  zone_redundant              = true
  tags                        = var.tags
}

#**************** Web Apps ****************

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.appservname}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.appserv_os_type
  sku_name            = var.appserv_sku
  tags                = var.tags
}

resource "azurerm_windows_web_app" "v60_web_apps" {
  depends_on                    = [azurerm_key_vault_secret.secrets, azurerm_mssql_server.mssql_server, azurerm_service_plan.app_service_plan]
  tags                          = var.tags
  count                         = length(var.dotnet_version_v60_apps)
  resource_group_name           = azurerm_resource_group.rg.name
  name                          = "${var.app_name_prefix}-${var.dotnet_version_v60_apps[count.index]}-${var.app_name_suffix}"
  location                      = azurerm_resource_group.rg.location
  service_plan_id               = azurerm_service_plan.app_service_plan.id
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    scm_use_main_ip_restriction = false

    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.endpoint_subnet.id
    }

    scm_ip_restriction {
      name        = "AzureCloud"
      action      = "Allow"
      service_tag = "AzureCloud"
      priority    = 200
    }

    scm_ip_restriction {
      name        = "AzureDevOps"
      action      = "Allow"
      service_tag = "AzureDevOps"
      priority    = 100
    }

    cors {
      allowed_origins = toset([for app in var.dotnet_version_v60_apps : "https://${var.app_name_prefix}-${app}-${var.app_name_suffix}-${var.environment}.azurewebsites.net" if app != var.dotnet_version_v60_apps[count.index]])
    }

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
    vnet_route_all_enabled = true
  }

  app_settings = var.appSettings

  dynamic "connection_string" {

    for_each = var.connection_strings

    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["name"] == "Password=${random_password.password[0].result};Persist Security Info=True;User ID=${var.sql_username};Initial Catalog=test-db;Data Source=${azurerm_mssql_server.mssql_server.fully_qualified_domain_name};Network Library=DBMSSOCN;"
    }

  }
}

#**************** Web App Swift Connection ****************

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration_connection_v60_apps" {
  count          = length(var.dotnet_version_v60_apps)
  app_service_id = element(azurerm_windows_web_app.v60_web_apps.*.id, count.index)
  subnet_id      = azurerm_subnet.integration_subnet.id
}

# *************** Web App Private DNS Configuration ***************

resource "azurerm_private_dns_zone" "dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name                  = "${var.private_dns_connectiion}-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
}

resource "azurerm_private_endpoint" "private_endpoint_v60_apps" {
  count               = length(var.dotnet_version_v60_apps)
  name                = "${var.app_name_prefix}${var.dotnet_version_v60_apps[count.index]}-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_dns_zone_group {
    name                 = "${var.private_dns_zone_group}-${var.environment}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  }

  private_service_connection {
    name                           = "${var.app_name_prefix}-${var.dotnet_version_v60_apps[count.index]}-endpoint-connection"
    private_connection_resource_id = element(azurerm_windows_web_app.v60_web_apps.*.id, count.index)
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

#**************** Key Vault Role & Polciy Assignment ****************

resource "azurerm_role_assignment" "role_assign" {
  depends_on           = [azurerm_key_vault.keyvault]
  count                = length(var.dotnet_version_v60_apps)
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_windows_web_app.v60_web_apps[count.index].identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "app_policy" {
  depends_on   = [azurerm_key_vault.keyvault]
  count        = length(var.dotnet_version_v60_apps)
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_web_app.v60_web_apps[count.index].identity[0].principal_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]

  storage_permissions = [
    "Get",
    "List",
    "Delete",
    "Set",
    "Update",
    "Backup",
    "RegenerateKey",
    "SetSAS",
    "ListSAS",
    "GetSAS",
    "DeleteSAS"
  ]
}