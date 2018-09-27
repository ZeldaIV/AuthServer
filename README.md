# AuthServer
A server to offer OAuth2.0 using openid connect with administration pages

AuthServer is meant to provide a web user interface for adding users, clients and resources
to provide authorization and authentication for any app, api or other client.

Hopefully it should be fairly quickly to get it running using docker-compose in the end.

**I do hope to improve on this in the future**

There are a few things you need to configure for development:
In db.env
* `MYSQL_ROOT_PASSWORD=[YOUR_DB_ROOT_PASSWORD]`
* `MYSQL_USER=[YOUR_DB_USER]`
* `MYSQL_PASSWORD=[YOUR_DB_USER_PASSWORD]`

In web.env:
* `ASPNETCORE_Kestrel__Certificates__Default__Password=[your pfx password]`

You will also have to create a certificate or get a certificate from a third party for https, 
and create a signing certificate for the tokens and update the location of your
certificate in
```
volumes: 
   - "./Certificates:/certificates"
   - "${HOME}/.aspnet/https:/https/"docker-compose:
```

To start the app run <code> docker-compose up </code> 

