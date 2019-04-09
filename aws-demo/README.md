## A sample root terraform module to create your cluster

NOTE: to load modules in your project use the following `source` parameter:

```
module "kub" {
  source    = "github.com/eleks/terraform-kubernetes-demo/aws-kub"
  ...
}
```

instead of `../` specified in this example
