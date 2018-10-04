# AuthServer
A server to offer OAuth2.0 using openid connect with administration pages

AuthServer is meant to provide a web user interface for adding users, clients and resources
to provide authorization and authentication for any app, api or other client.

Hopefully it should be fairly quickly to get it running using docker-compose in the end.

**I do hope to improve on this in the future**

There are a few things you need to configure for development:

inside the docker folder copy the *db.env* file to *secret.db.env* and set your credentials inside

In docker/secret.db.env
* `MYSQL_ROOT_PASSWORD=[YOUR_DB_ROOT_PASSWORD]`
* `MYSQL_USER=[YOUR_DB_USER]`
* `MYSQL_PASSWORD=[YOUR_DB_USER_PASSWORD]`

inside the docker folder copy the *web.env* file to *secret.web.env* and set your credentials inside

In docker/secret.web.env:
* `ASPNETCORE_Kestrel__Certificates__Default__Password=[your pfx password]`

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

