variable "resourcegroup_name" {
  type        = string
  description = "The resource group for the web infrastructure"
  default     = "inn-skillsshare-demo-rg"
}

variable "vnet_address_spaces" {
  type        = list(string)
  description = "A list of the VNET address spaces"
  default     = ["10.253.32.0/24", "10.253.67.0/24", "10.253.31.0/24"]
}

variable "vnet_resourcegroup_name" {
  type    = string
  default = "inn-skillshare-demo-vnet"
}

variable "vnet_name" {
  type    = string
  default = "inn-skillsshare-demo-pvtvnet"
}

variable "endpoint_subnet_name" {
  type    = string
  default = "inn-skillshare-demo-endpoint-subnet"
}

variable "integration_subnet_name" {
  type    = string
  default = "inn-skillshare-demo-integration-subnet"
}

variable "endpoint_subnet_address_prefix" {
  type        = list(string)
  description = "Subnet address prefix "
  default     = ["10.253.67.64/27"]
}

variable "integration_subnet_address_prefix" {
  type        = list(string)
  description = "Subnet address prefix"
  default     = ["10.253.67.128/26"]
}

variable "endpoint_subnet_service_endpoints" {
  type        = list(string)
  description = "Service endpoints enabled for subnet"
  default     = ["Microsoft.Web", "Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

variable "integration_subnet_service_endpoints" {
  type        = list(string)
  description = "Service endpoints enabled for subnet"
  default     = ["Microsoft.Web"]
}

variable "private_dns_connectiion" {
  type    = string
  default = "inn-skillshare-demo-pvtDNSconnection-appsrv"
}

variable "private_dns_zone_group" {
  type    = string
  default = "inn-skillshare-demo-pvtDNSgroup-appsrv"
}

variable "appservname" {
  type    = string
  default = "inn-skillshare-demo-web-appsrv"
}

variable "appserv_os_type" {
  type    = string
  default = "Windows"
}

variable "appserv_sku" {
  type    = string
  default = "S1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type        = string
  description = "The region for the deployment"
  default     = "South Africa North"
}

variable "tags" {
  type        = map(string)
  description = "Tags used for the deployment"
  default = {
    "Environment" : "dev"
    "Owner" : "innovations"
    "capability" : "not specified",
    "env_type" : "development",
    "fin_acc_bu_name" : "innovations",
    "fin_acc_dep_name" : "first digital",
    "fin_costcentre" : "first technology",
    "project" : "skills share",
    "suballocation" : "innovations"
  }
}

variable "appSettings" {
  type        = map(string)
  description = "Tags used for the deployment"
  default = {
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true",
  }
}

variable "key_vault_name" {
  type    = string
  default = "inn-skillshare-demo-kv"
}

variable "key_vault_vnet_link" {
  type    = string
  default = "inn-skillsshare-demo-kv-vnet-link"
}

variable "key_vault_private_endpoint_name" {
  type    = string
  default = "inn-skillsshare-demo-kv-endpoint"
}

variable "secrets" {
  type    = list(string)
  default = ["mssql-server-secret"]
}

variable "sql_username" {
  type    = string
  default = "SqlDba"
}

variable "connection_strings" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = [
    {
      name  = "inn-skillshare-demo-mssqldatabase-dev"
      type  = "SQLServer"
      value = "Password=;Persist Security Info=True;User ID=SqlDba;Initial Catalog=OCM;Data Source=healthmininglab-mi.b630b629480c.database.windows.net; Network Library=DBMSSOCN;"
    }
  ]
}

variable "dotnet_version_v60_apps" {
  type    = list(string)
  default = ["webapp1", "webapp2", "webapp3"]
}

variable "app_name_prefix" {
  type        = string
  default     = "inn-skillsshare-demo"
  description = <<EOT
  This is the prefix for all application names in this environment, e.g., inn-skillsshare-demo-app-appsrv-{app-name}-dev
  [inn] - Business Unit
  [skillsshare] - Project name
  [demo] - Project type
  [app] - Resource type
  [dev] - Environment
  EOT
  validation {
    condition     = startswith(var.app_name_prefix, "inn-skillsshare")
    error_message = "The application prefix must start with \"inn-skillsshare\""
  }
}

variable "app_name_suffix" {
  type        = string
  default     = "appsrv"
  description = <<EOT
  This is the suffix for all application names in this environment, e.g., inn-skillsshare-demo-app-appsrv-{app-name}-dev
  [inn] - Business Unit
  [skillsshare] - Project name
  [demo] - Project type
  [app] - Resource type
  [dev] - Environment
  EOT
}

variable "devops_sp" {
  type    = string
  default = "Terraform"
}

variable "storage_acc_name" {
  type    = string
  default = "innskillsharedemofsdev"
}

variable "storage_acc_tier" {
  type    = string
  default = "Standard"
}

variable "storage_acc_repl_type" {
  type    = string
  default = "LRS"
}

variable "storage_acc_containers" {
  type = list(object({
    name        = string
    access_type = string
  }))

  default = [
    {
      name        = "logs",
      access_type = "private"
    },
    {
      name        = "applicationfiles",
      access_type = "private"
    },
    {
      name        = "backups",
      access_type = "container"
    },
    {
      name        = "tfstate",
      access_type = "private"
    }
  ]
}

variable "mssql_server_name" {
  type    = string
  default = "inn-skillshare-demo-mssqlserver-dev"
}

variable "mssql_server_version" {
  type    = string
  default = "12.0"
}

variable "mssql_database_name" {
  type    = string
  default = "inn-skillshare-demo-mssqldatabase-dev"
}