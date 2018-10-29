# Cretaing the necessary certificates

## Create SigningCertificate

	$ docker-compose -f docker-openssl.yml run --rm openssl req -x509 -newkey rsa:4096 -keyout /export/SigningCertificate-key.pem -out /export/SigningCertificate.cert -days 3000

Password: *ValidatedKey*

Country Name: *no*

	$ docker-compose -f docker-openssl.yml run --rm openssl pkcs12 -export -out /export/SigningCertificate.pfx -inkey /export/SigningCertificate-key.pem -in /export/SigningCertificate.cert

Password: *ValidatedKey*

## Creat NginX SelfSigned Cert

	$ docker-compose -f docker-openssl.yml run --rm openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /export/nginx-selfsigned.key -out /export/nginx-selfsigned.crt

Country Name: *NO*
(You can put in anything else you might want)

	$ docker-compose -f docker-openssl.yml run --rm openssl dhparam -out /export/dhparam.pem 512
