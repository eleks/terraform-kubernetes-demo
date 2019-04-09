#--------------------------------------------------------
#--variables section
#--------------------------------------------------------
variable "ssh_host"           {}
variable "ssh_user"           { default = "centos" }
variable "key_path_local"     { default = "~/.ssh/" }
variable "key_name"           { default = "deployer-key" }

variable "persistent_local"   {}
variable "persistent_remote"  { default = "/var/nfs/persistent" }

variable "templates"          {
  type = "list"
  default = []
}
#template variables
variable "vars"      {
  type = "map"
  default = {}
}

# variable just to implement depends-on values
variable "depends_on"{ default = [], type = "list"}

