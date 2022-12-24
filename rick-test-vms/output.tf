output "vmazurerm_linux_virtual_machine" {
    description = "Basic VM Information"
    value = azurerm_linux_virtual_machine.rick_vm[*].name[*]
}

output "tags" {
    description = "Tag Details"
    value = local.tags.env
}

output "security_group_details" {
    description = "Security Details"
    value = azurerm_network_security_group.rick_security_group.security_rule[*]
}

# Expected Output 
# Devops tools can be developed based on the terraform ouptuts
/* Outputs:

security_group_details = tolist([
  {
    "access" = "Allow"
    "description" = ""
    "destination_address_prefix" = "*"
    "destination_address_prefixes" = toset([])
    "destination_application_security_group_ids" = toset([])
    "destination_port_range" = "22"
    "destination_port_ranges" = toset([])
    "direction" = "Inbound"
    "name" = "SSH"
    "priority" = 1001
    "protocol" = "Tcp"
    "source_address_prefix" = "*"
    "source_address_prefixes" = toset([])
    "source_application_security_group_ids" = toset([])
    "source_port_range" = "*"
    "source_port_ranges" = toset([])
  },
])
tags = "lab"
vmazurerm_linux_virtual_machine = [
  [
    "rick-test-machine-0",
  ],
  [
    "rick-test-machine-1",
  ],
] */