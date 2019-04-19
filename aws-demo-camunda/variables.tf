#--------------------------------------------------------
#--General variables section
#--------------------------------------------------------

variable "aws_region"     { default = "us-west-2" }

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "kubeapi_token"  {}

variable "tf_mail_user"   {} // "...@gmail.com"
variable "tf_mail_pass"   {} // "hkgfkhgvkvfigfkhvvlv"
variable "tf_jira_auth"   {} // "Basic d23264326432634263423424637453574545486548658684"

variable "tf_db_user"     {}
variable "tf_db_pass"     {}

variable "tf_grafana_pass"{}