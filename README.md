### Setup

1. Generate keys:

    ```bash
    openssl genrsa -out privatekey.pem 1024
    openssl req -new -x509 -key privatekey.pem -out publickey.cer -days 1825
    openssl pkcs12 -export -out public_privatekey.pfx -inkey privatekey.pem -in publickey.cer
    pbcopy < publickey.cer
    ```
1. Create a demo account via the xero interface (Create demo account)[https://my.xero.com/!xkcD/Dashboard]
1. Goto the xero dev console (Xero Dev - Applications)[https://app.xero.com/Application/List]
1. Create a new private application.
1. Select the demo account
1. Paste in the public key
1. Add in the following env vars to the stack
  1. __XERO_API_KEY__ : *required*
  1. __XERO_SECRET__ : *required*
  1. __XERO_PRIVATE_KEY__ : *required* `pbcopy < privatekey.pem`
  1. __REDIS_URL__ : *required*
  1. __SECRET_KEY_BASE__ : *required*
  1. __POSTGRESQL_DATABASE__ : *required*
  1. __POSTGRESQL_ADDRESS__ : *required*
  1. __POSTGRESQL_USERNAME__ : *required*
  1. __POSTGRESQL_PASSWORD__ : *required*


### Dev

Start Redis: redis-server /usr/local/etc/redis.conf
Start Clockwork: bundle exec clockwork clock.rb
