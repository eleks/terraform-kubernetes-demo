#--------------------------------------------------------
#--variables section
#--------------------------------------------------------
variable "ssh_host"           {}
variable "ssh_user"           { default = "centos" }
variable "key_path_local"     { default = "~/.ssh/" }
variable "key_name"           { default = "deployer-key" }

# commands to execute
variable "inline"             {
  type="list"
}

# variable just to implement depends-on values
variable "depends_on"{ default = [], type = "list"}

