This section describes how to create trusted certificates for wso2 components.

To minimize initial efforts we assume that our cloud provides as minimum one public dynamic DNS like: AAAA-XXXXXXXXXXXXXXXX.elb.us-west-1.amazonaws.com

We have created a wildcard certificate for `*.us-west-1.elb.amazonaws.com` that signed with custom CA certificate 
that also has the following domains as alternatives: 

```shell
localhost                      # some wso2 services need this
192.168.99.100                 # default ip address for docker in virtualbox
*.docker.local                 # docker-compose env  
*.default.svc.cluster.local    # kubernetes default domain
# default auto-generated public host name for some aws zones
*.eu-west-1.elb.amazonaws.com  
*.eu-west-2.elb.amazonaws.com
*.eu-west-3.elb.amazonaws.com
*.us-east-1.elb.amazonaws.com
*.us-east-2.elb.amazonaws.com
*.us-west-1.elb.amazonaws.com
*.us-west-2.elb.amazonaws.com
```


## goal

- create CA keypair for custom Certificate authority
- generate wso2carbon.jks JKS keystore for desired host names that will be accepted from web, mobile, or internal 
- sign the wso2carbon.jks primary certificate with CA certificate

## tool

all above teoretically possible to do with keytool + openssl tools
but for simplicity I used http://keystore-explorer.org/

## files in this directory

> all the keystores secured with default wso2 password: `wso2carbon`

- `ca.jks` (removed for security reason) the custom keystore with keypair to be a CA (Certificate authority) certificate.
- `ca.docker.local.cer` public CA certificate to be imported into client's truststore (browsers, etc.)
- `extension.tpl` template with extensions for certificates. you can import and modify them in `keystore-explorer`
- `web-key.pem` and `web-crt.pem` exported final key and certificate to be used as a load balancer certificate

> Note: `wso2carbon.jks` and `client-truststore.jks` are located in `<ROOT>/persistent/.common/artifacts/repository/resources/security` to be available in wso2 docker images 

## steps

#### generate CA keystore with key-pair
normally you don't need to regenerate this CA certificate if you trust it

don't forget to set CA=TRUE in Basic Constraints

![generate CA keystore with key-pair](./readme-img/01-gen-ca.png)

![generate CA keystore with key-pair](./readme-img/01-gen-ca-02.png)

#### export & import public CA certificate into truststore
> NOTE: this is not necessary if you did not change the CA certificate in previous step

![export public CA certificate](./readme-img/07-ca-exp-01.png)

![export public CA certificate - 2](./readme-img/07-ca-exp-02.png)

![import public CA certificate into truststore](./readme-img/08-ca-imp-trust.png)


#### generate wso2carbon.jks
> this step not required. you could re-generate key pair. however you can keep existing primary certificate. 
> the key alias must correspond to one you specified in `carbon.xml` in `Security.KeyStore.KeyAlias`. 
> by default it's `wso2carbon` or to the tenant domain name if you are in multitenant mode. domain: `test.com` -> alias: `test-com`

Click `Tools -> Generate Key Pair` menu item and provide the following parameters.

- CN: `*.docker.local`
- alias: `wso2carbon`

> Note: alternative host names will appear within signature

![generate wso2carbon.jks](./readme-img/02-gen-wso2carbon.jks.png)

#### generate request for signature 
This is required to create signed certificate

![generate request for signature](./readme-img/03-sign-req.png)

#### sign the request with CA certificate

> don't forget to specify extension in reply 
> you can import extension from the `extension.tpl` template

![sign the request with CA certificate](./readme-img/04-sign.png)

#### import the signature reply into wso2carbon.jks
![import the signature reply into wso2carbon.jks](./readme-img/05-imp-sign-repl.png)

#### wso2carbon.jks result
![wso2carbon.jks result](./readme-img/06-result.png)

#### export private key and public certificate for balancer

> **NOTE:** following exported files used for certificate at the level of load balancer.


![export private key](./readme-img/11-wso2carbon-exp-key-4-balancer.png)

![export public cert  chain](./readme-img/12-wso2carbon-exp-crt-4-balancer.png)


#### import wso2carbon certificate into truststore (optional)

This part is required if you want to use sso saml for auth and goind to validate signature of the response

> **NOTE:** if you are going to use sso saml with wso2is to sign in to other wso2carbon servers 
> you have to import this CA certificate with alias `wso2carbon` or change the parameters of connection.
> For example in the wso2is-analytics/portal there is a `repository/deployment/server/jaggeryapps/portal/configs/designer.json` 
> config file where the alias defined as wso2carbon and it requires to validate signature against it.

![extort wso2carbon certificate](./readme-img/09-wso2carbon-exp.png)


