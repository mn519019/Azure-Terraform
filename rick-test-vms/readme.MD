### Terraform VM 
- This project is to automate VMs pronvisioning process using Terraform
- As long as you have all necessary config details, "terraform plan" and "terraform apply" commands can create VMs on Azure (Public Cloud)
- As we store the state information in the terraform state file, we can easily maintain vms using an Infrastructure As Code concept. 
- The final goal of this project is creating lab VMs that can be SSHed into the hosts. (Lab tag is required for VMs) 

### Prerequsities 
- terraform installation
- Azure Cli configuration
- Azure Access at least basic tier 
- SSH key (public and private )

### Terraform Required Elements 
- azurem_resource_group
- azurerm_virtual_network
- azurerm_subnet
- azurerm_public_ip
- azurerm_network_security_group
- azurerm_network_interface
- azurerm_network_interface_security_group_association
- azurerm_linux_virtual_machine
