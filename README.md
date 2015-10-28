# shib-oauth2-bridge docker.

This is a [docker](https://www.docker.io) image that eases setup of the [shib-oauth2-bridge](https://github.com/ucla/shib-oauth2-bridge) for development.

## Usage

The docker containers built from this repository can be found at the [docker hub](https://registry.hub.docker.com/u/ucla/shib-oauth2-bridge/).

This container needs a linked mysql container named `mysql`, please start the container with (assuming your container name is also mysql):

```bash
docker run -d --link=mysql:mysql ucla/shib-oauth2-bridge
```

From here, you've got a couple more dependencies before you can start using this.
  * You need to add an accepted client to the bridge db, this requires three inserts. Assumptions: client shib auth endpoint is `http://localhost:3000/session/oauth2/shibboleth`
```sql
INSERT INTO `oauth_clients` (`id`, `secret`, `name`, `created_at`, `updated_at`) VALUES ('appid', 'appsecret', 'appname', now(), now());
INSERT INTO `oauth_client_endpoints` (`id`, `client_id`, `redirect_uri`, `created_at`, `updated_at`) VALUES (1, 'appid', 'http://localhost:3000/auth/oauth2/shibboleth', now(), now());
INSERT INTO `oauth_client_scopes` (`client_id`, `scope_id`) VALUES ('appid', 1)
```
  * Your client needs to have this shib-oauth2-bridge supported/enabled.
    * Take a look at the [casa-on-rails dev example](https://github.com/ucla/casa-on-rails#shibboleth-login-via-oauth2-bridge) for pointers!
    * With this bridge container, you can use either `/oauth2/authorize` or `/oauth2/test-authorize` as the endpoints: `authorize` will mock a default user and `test-authorize` will allow you choose the shib user env to be mocked.

## Environment Variables

  * `DB_HOST`: defaults to `$MYSQL_PORT_3306_TCP_ADDR`
  * `DB_PORT`: defaults to `$MYSQL_PORT_3306_TCP_PORT`
  * `DB_NAME`: defaults to `auth`
  * `DB_USER`: defaults to `auth`
  * `DB_PASS`: defaults to `auth`

## Bugs/Notes

  * This is *without a doubt* not ready for production and will eventually become the `dev` tag where the default tag will allow you to drop in your shib conf files and actually use in a real shib environment.

## Copyright
Copyright (c) 2015 UC Regents

This container is **open-source** and licensed under the BSD 3-clause license. The full text of the license may be found in the `LICENSE` file.