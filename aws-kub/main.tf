#--------------------------------------------------------

terraform {
    required_version = "> 0.11.0"
}
#--------------------------------------------------------
#--providers 
#--------------------------------------------------------
//provider "kubernetes" {}
//provider "aws"        {}
//provider "archive"    {}
provider "local"      {}
provider "template"   {}
