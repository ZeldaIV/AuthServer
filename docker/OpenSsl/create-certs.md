
# Cretate pem and cert file. (2 Times. 1 for auth and 1 for signing)
docker-compose -f docker-openssl.yml run --rm openssl req -x509 -newkey rsa:4096 -keyout /export/__YOUR_PEM_NAME__.pem -out /export/__YOUR_CERT_NAME__.cert -days 3000

# Create pfx file from pem and cert file (remember 2 times)
docker-compose -f docker-openssl.yml run --rm openssl pkcs12 -export -out /export/__YOUR_PFX_NAME__.pfx -inkey /export/__YOUR_PEM_NAME__.pem -in /export/__YOUR_CERT_NAME__.cert
