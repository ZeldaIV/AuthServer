# AuthServer
An implementation of authorization and authentication based on IdentityServer and custom UI.

AuthServer is meant to provide a web user interface for adding users, clients and resources
to provide authorization and authentication for any app, api or other client.

There are a few things you need to configure before running:

Inside the docker folder copy the *db.env* file to *secret.db.env* and set your credentials inside

In docker/secret.db.env
* `MYSQL_ROOT_PASSWORD=[YOUR_DB_ROOT_PASSWORD]`
* `MYSQL_USER=[YOUR_DB_USER]`
* `MYSQL_PASSWORD=[YOUR_DB_USER_PASSWORD]`

Inside the docker folder copy the *web.env* file to *secret.web.env* and set your credentials inside

In docker/secret.web.env:
* `ASPNETCORE_Kestrel__Certificates__Default__Password=[your pfx password]`
* `AuthServerAdministrator=[YOUR_ADMIN_USER]`
* `AuthServerAdministratorPassword=[YOUR_ADMIN_PASSWORD]`
* `AuthServerSigningCertificatePath=/https/SigningCertificate.pfx`
* `AuthServerSigningCertificatePassword=[YOUR SIGNING CERTIFICATE PASSWORD]`

Inside the docker folder copy the *duck.env* file to *secret.duck.env* and set your credentials inside

In docker/secret.duck.env:
* `# DuckDNS`
* `SUBDOMAINS=SUBDOMAINS=<subdomains>`
* `TOKEN=<token>` 
* `TZ=<timezone>`

Inside the docker/nginx folder copy the *nginx.conf* file to *secret.nginx.conf*. Then you can store your secret domains and certificates if needed without commiting it to the repository.
The basic file will work whn following the example setup.

This will add the administrator to the database, and you can use that as login to add other users, clients and resources.

### Creating Self-Signed certificates for testing

You will also have to create a certificate or get a certificate from a third party for https, 
and create a signing certificate for the tokens and update the location of your
certificates.

To generate such certificates have a look in the <code> docker/OpenSsl </code> folder. These commands
will generate the necessary certificates and put them in the Certificates folder in the root dir.

This will work out of the box for testing locally
```
volumes: 
   - "../Certificates:/certificates"
   - "../Certificates:/https"
```

If you allready have other certificates or you are in you production environment you might want 
to use a differnt certificate location like:
```
volumes:
   - "${HOME}/.aspnet/https:/certificates"
   - "${HOME}/.aspnet/https:/https"
```

To start the app run <code> docker-compose up </code> 

