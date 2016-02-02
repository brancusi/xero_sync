### Setup

#### Staging

1. Create a demo account via the xero interface (Create demo account)[https://my.xero.com/!xkcD/Dashboard]
1. Goto the xero dev console (Xero Dev - Applications)[https://app.xero.com/Application/List]
1. Generate keys:
```bash
openssl genrsa -out privatekey.pem 1024
openssl req -new -x509 -key privatekey.pem -out publickey.cer -days 1825
openssl pkcs12 -export -out public_privatekey.pfx -inkey privatekey.pem -in publickey.cer
pbcopy < publickey.cer
```
1. Create a new private application.
1. Select the demo account
1. Paste in the public key
1. Add in the following env vars to the stack
  1. *XERO_API_KEY* : __Required__
  1. *XERO_SECRET* : __Required__
  1. *XERO_PRIVATE_KEY* : __Required__ `pbcopy < privatekey.pem`
  1. *REDIS_URL* : __Required__
  1. *SECRET_KEY_BASE*: __Required__
  1. *POSTGRESQL_DATABASE*: __Required__
  1. *POSTGRESQL_ADDRESS*: __Required__
  1. *POSTGRESQL_USERNAME*: __Required__
  1. *POSTGRESQL_PASSWORD*: __Required__
