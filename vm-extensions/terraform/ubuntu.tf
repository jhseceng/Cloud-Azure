# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name = "${var.instance_name}-ubuntu"
  location = var.location
  resource_group_name = azurerm_resource_group.instancetestrg.name
  network_interface_ids = [
    azurerm_network_interface.myterraformnic.id]
  size = "Standard_DS1_v2"

  os_disk {
    name = "myOsDisk"
    caching = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

source_image_reference {
  publisher = "Canonical"
  offer = "UbuntuServer"
  sku = "18.04-LTS"
  version = "latest"
}

  computer_name = "${var.instance_name}-ubuntu"
  admin_username = "azureuser"
  disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_virtual_machine_extension" "myterraformvm" {
  name = "falcon-sensor-install-linux"
  virtual_machine_id = azurerm_linux_virtual_machine.myterraformvm.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
  { "fileUris": [ 
          "https://raw.githubusercontent.com/CrowdStrike/Cloud-Azure/master/vm-extensions/scripts/install.sh"
        ]  
  }
  SETTINGS
  ## TODO: work the variables into KeyVault
  protected_settings = <<PROTECTED
  {
    "commandToExecute": "export FALCON_CID=${var.cid} && export FALCON_CLIENT_ID=${var.client_id} && export FALCON_CLIENT_SECRET=${var.client_secret} && export FALCON_CLOUD=${var.falcon_cloud} && /bin/bash install.sh"
  }
  PROTECTED

  tags = {
    environment = "Development"
  }
}
