Proxying Guacamole
==================

Like most web applications, Guacamole can be placed behind a reverse proxy. For
production deployments of Guacamole, this is *highly recommended*. It provides
flexibility and, if your proxy is properly configured for SSL, encryption.

Proxying isolates privileged operations within native applications that can
safely drop those privileges when no longer needed, using Java only for
unprivileged tasks. On Linux and UNIX systems, a process must be running with
root privileges to listen on any port under 1024, including the standard HTTP
and HTTPS ports (80 and 443 respectively). If the servlet container instead
listens on a higher port, such as the default port 8080, it can run as a
reduced-privilege user, allowing the reverse proxy to bear the burden of root
privileges. As a native application, the reverse proxy can make system calls to
safely drop root privileges once the port is open; a Java application like
Tomcat cannot do this.

(preparing-servlet-container)=

Preparing your servlet container
--------------------------------

Your servlet container is most likely already configured to listen for HTTP
connections on port 8080 as this is the default. If this is the case, and you
can already access Guacamole over port 8080 from a web browser, you need not
make any further changes to its configuration.

If you *have* changed this, perhaps with the intent of proxying Guacamole over
AJP, *change it back*. Using Guacamole over AJP is unsupported as it is known
to cause problems, namely:

1. WebSocket will not work over AJP, forcing Guacamole to fallback to HTTP,
   possibly resulting in reduced performance.

2. Apache 2.4.3 and older does not support the HTTP PATCH method over AJP,
   preventing the Guacamole management interface from functioning properly.

The connector entry within `conf/server.xml` should look like this:

```xml
<Connector port="8080" protocol="HTTP/1.1" 
           connectionTimeout="20000"
           URIEncoding="UTF-8"
           redirectPort="8443" />
```

Be sure to specify the `URIEncoding="UTF-8"` attribute as above to ensure that
connection names, user names, etc. are properly received by the web
application. If you will be creating connections that have Cyrillic, Chinese,
Japanese, or other non-Latin characters in their names or parameter values,
this attribute is required.

(tomcat-remote-ip)=

### Setting up the Remote IP Valve

By default, when Tomcat is behind a reverse proxy, the remote IP address of the
client that it sees is that of the proxy rather than the original client. In
order to allow applications hosted within Tomcat, like Guacamole, to see the
actual IP address of the client, you have to configure both the reverse proxy
and Tomcat.

Because the remote IP address in Guacamole is used for auditing of user logins
and connections and could potentially be used for authentication, it is
important that you are either in direct control of the proxy server or you
explicitly trust it. Passing the remote IP address is done using the
`X-Forwarded-For` header, and, as with most HTTP headers, attackers can attempt
to spoof this header in order to manipulate the behavior of the web server,
gain unauthorized access to the system, or attempt to disguise the host or IP
address they are coming from.

One final caveat: This may not work as expected if there are other upstream
proxy servers between your reverse proxy and the clients access Guacamole.
Other proxies or firewalls can mask the IP address of the client, and if the
configuration of those is not within your control you may end up with multiple
clients appearing to come from the same IP address or host. Make sure you take
this into account when configuring the system and looking at the data provided.

Configuring Tomcat to pass through the remote IP address provided by the
reverse proxy in the `X-Forwarded-For` header requires the configuration of
what Tomcat calls a Valve. In this case, it is the
[`RemoteIpValve`](https://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Remote_IP_Valve)
and is configured in the `conf/server.xml` file, in the `<Host>` section:

```xml
<Valve className="org.apache.catalina.valves.RemoteIpValve"
               internalProxies="127.0.0.1"
               remoteIpHeader="x-forwarded-for"
               remoteIpProxiesHeader="x-forwarded-by"
               protocolHeader="x-forwarded-proto" />
```

The `internalProxies` value should be set to the IP address or addresses of any
and all reverse proxy servers that will be accessing this Tomcat instance
directly. Often it is run on the same system that runs Tomcat, but in other
cases (for example, when running Docker), it may be on a different
system/container and may need to be set to the actual IP address of the reverse
proxy system. Only proxy servers listed in the `internalProxies` or
`trustedProxies` parameters will be allowed to manipulate the remote IP address
information. The other parameters in this configuration line allow you to
control which headers coming from the proxy server(s) are used for various
remote host information. They are as follows:

`remoteIpHeader`
: The header that is queried to learn the client IP address of the client
  that originated the request. The standard value is `X-Forwarded-For`, but
  can be configured to any header you like. The IP address in this header
  will be available to Java applications in the `request.getRemoteAddr()`
  method.

`remoteIpProxiesHeader`
: The header that is queried to learn the IP address of the proxy server
  that forwarded the request. The default value is `X-Forwarded-By`, but can
  be configured to any header that fits your environment. This value will
  only be allowed by the valve if the proxy used is listed in the
  `trustedProxies` parameter. Otherwise this header will not be available.

`protocolHeader`
: The header that is queried to determine the protocol that the client used
  to connect to the service. The default value is `X-Forwarded-Proto`, but
  can be configured to fit your environment.

In addition to configuring Tomcat to properly handle these headers, you also
may need to configure your reverse proxy appropriately to send the headers. You
can find instructions for this in [](nginx) - the Apache web server passes it
through by default.

(nginx)=

Nginx
-----

Nginx can be used as a reverse proxy, and supports WebSocket out-of-the-box
[since version 1.3](http://nginx.com/blog/websocket-nginx/). Both Apache and
Nginx require some additional configuration for proxying of WebSocket to work
properly.

(proxying-with-nginx)=

### Proxying Guacamole

Nginx does support WebSocket for proxying, but requires that the "Connection"
and "Upgrade" HTTP headers are set explicitly due to the nature of the
WebSocket protocol. From the Nginx documentation:

> NGINX supports WebSocket by allowing a tunnel to be set up between a client
> and a back-end server. For NGINX to send the Upgrade request from the client
> to the back-end server, Upgrade and Connection headers must be set
> explicitly. ...

The proxy configuration belongs within a dedicated
[`location`](http://nginx.org/en/docs/http/ngx_http_core_module.html#location>)
block, declaring the backend hosting Guacamole and explicitly specifying the
"`Connection`" and "`Upgrade`" headers mentioned earlier:

```nginx
location /guacamole/ {
    proxy_pass http://HOSTNAME:8080;
    proxy_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    access_log off;
}
```

Here, `HOSTNAME` is the hostname or IP address of the machine hosting your
servlet container, and 8080 is the port that servlet container is configured to
use. You will need to replace these values with the correct values for your
server.

Related to the `RemoteIpValve` configuration for tomcat, documented in
[Setting up the Remote IP Valve](tomcat-remote-ip), the `proxy_set_header
X-Forwarded-For $proxy_add_x_forwarded_for;` line is important if you want the
`X-Forwarded-For` header to be passed through to the web application server and
available to applications running inside it.

:::{important}
*Do not forget to specify "`proxy_buffering off`".*

Most proxies, including Nginx, will buffer all data sent over the connection,
waiting until the connection is closed before sending that data to the client.
As Guacamole's HTTP tunnel relies on streaming data to the client over an open
connection, excessive buffering will effectively block Guacamole connections,
rendering Guacamole useless.

*If the option "`proxy_buffering off`" is not specified, Guacamole may not
work*.
:::

(changing-path-with-nginx)=

### Changing the path

If you wish to serve Guacamole through Nginx under a path other than
`/guacamole/`, the easiest method is to simply rename the `.war` file. For
example, if intending to server Guacamole at `/new-path/`, you would:

1. Rename `guacamole.war` to `new-path.war`.

2. Update the path within the Nginx configuration to reflect the new
   path:

   :::{code-block} nginx
   :emphasize-lines: 1
   location /new-path/ {
       proxy_pass http://HOSTNAME:8080;
       proxy_buffering off;
       proxy_http_version 1.1;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection $http_connection;
       access_log off;
   }
   :::


Alternatively, the configuration can be altered slightly to handle requests at
a different location externally while still serving internal requests at
`/guacamole/`:

:::{code-block} nginx
:emphasize-lines: 1-2
location /new-path/ {
    proxy_pass http://HOSTNAME:8080/guacamole/;
    proxy_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    access_log off;
}
:::

(nginx-file-upload-size)=

### Adjusting file upload limits

When proxying Guacamole through Nginx, you may run into issues with the default
limitations that Nginx places on file uploads (1MB). The errors you receive can
be non-intuitive (permission denied, for example), but may be indicative of
these limits. The `client_max_body_size` parameter can be set within the
`location` block to configure the maximum file upload size:

:::{code-block} nginx
:emphasize-lines: 8
location /guacamole/ {
    proxy_pass http://HOSTNAME:8080;
    proxy_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    client_max_body_size 1g;
    access_log off;
}
:::

(apache)=

Apache and mod_proxy
--------------------

Apache supports reverse proxy configurations through
[mod_proxy](http://httpd.apache.org/docs/2.4/mod/mod_proxy.html).  Apache 2.4.5
and later also support proxying of WebSocket through a sub-module called
[mod_proxy_wstunnel](http://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html).
Both of these modules will need to be enabled for proxying of Guacamole to work
properly.

Lacking mod_proxy_wstunnel, it is still possible to proxy Guacamole, but
Guacamole will be unable to use WebSocket. It will instead fallback to using
the HTTP tunnel, resulting in reduced performance.

(proxying-with-apache)=

### Proxying Guacamole

Configuring Apache to proxy HTTP requests requires using the `ProxyPass` and
`ProxyPassReverse` directives, which are provided by the mod_proxy module.
These directives describe how HTTP traffic should be routed to the web server
behind the proxy:

```apache
<Location /guacamole/>
    Order allow,deny
    Allow from all
    ProxyPass http://HOSTNAME:8080/guacamole/ flushpackets=on
    ProxyPassReverse http://HOSTNAME:8080/guacamole/
</Location>
```

Here, `HOSTNAME` is the hostname or IP address of the machine hosting your
servlet container, and `8080` is the port that servlet container is configured
to use. You will need to replace these values with the correct values for your
server.

:::{important}
*Do not forget the `flushpackets=on` option.*

Most proxies, including mod_proxy, will buffer all data sent over the
connection, waiting until the connection is closed before sending that data to
the client. As Guacamole's HTTP tunnel relies on streaming data to the client
over an open connection, excessive buffering will effectively block Guacamole
connections, rendering Guacamole useless.

*If the option `flushpackets=on` is not specified, Guacamole may not work*.
:::

(websocket-and-apache)=

### Proxying the WebSocket tunnel

Apache will not automatically proxy WebSocket connections, but you can proxy
them separately with Apache 2.4.5 and later using mod_proxy_wstunnel. After
enabling mod_proxy_wstunnel a secondary `Location` section can be added which
explicitly proxies the Guacamole WebSocket tunnel, located at
`/guacamole/websocket-tunnel`:

:::{code-block} apache
:emphasize-lines: 8-13
<Location /guacamole/>
    Order allow,deny
    Allow from all
    ProxyPass http://HOSTNAME:8080/guacamole/ flushpackets=on
    ProxyPassReverse http://HOSTNAME:8080/guacamole/
</Location>

<Location /guacamole/websocket-tunnel>
    Order allow,deny
    Allow from all
    ProxyPass ws://HOSTNAME:8080/guacamole/websocket-tunnel
    ProxyPassReverse ws://HOSTNAME:8080/guacamole/websocket-tunnel
</Location>
:::

Lacking this, Guacamole will still work by using normal HTTP, but network
latency will be more pronounced with respect to user input, and performance may
be lower.

:::{important}
**The `Location` section for `/guacamole/websocket-tunnel` must be placed after
the `Location` section for the rest of Guacamole.**

Apache evaluates all Location sections, giving priority to the last section
that matches. If the `/guacamole/websocket-tunnel` section comes first, the
section for `/guacamole/` will match instead, and WebSocket will not be proxied
correctly.
:::

(changing-path-with-apache)=

### Changing the path

If you wish to serve Guacamole through Apache under a path other than
`/guacamole/`, the easiest method is to simply rename the `.war` file. For
example, if intending to server Guacamole at `/new-path/`, you would:

1. Rename `guacamole.war` to `new-path.war`.

2. Update the paths within the Apache configuration to reflect the new path:

   :::{code-block} apache
   :emphasize-lines: 1,4-5,8,11-12
   <Location /new-path/>
       Order allow,deny
       Allow from all
       ProxyPass http://HOSTNAME:8080/new-path/ flushpackets=on
       ProxyPassReverse http://HOSTNAME:8080/new-path/
   </Location>

   <Location /new-path/websocket-tunnel>
       Order allow,deny
       Allow from all
       ProxyPass ws://HOSTNAME:8080/new-path/websocket-tunnel
       ProxyPassReverse ws://HOSTNAME:8080/new-path/websocket-tunnel
   </Location>
   :::

Alternatively, the configuration can be altered slightly to handle requests at
a different location externally while still serving internal requests at
`/guacamole/`:

:::{code-block} apache
:emphasize-lines: 1,8
<Location /new-path/>
    Order allow,deny
    Allow from all
    ProxyPass http://HOSTNAME:8080/guacamole/ flushpackets=on
    ProxyPassReverse http://HOSTNAME:8080/guacamole/
</Location>

<Location /new-path/websocket-tunnel>
    Order allow,deny
    Allow from all
    ProxyPass ws://HOSTNAME:8080/guacamole/websocket-tunnel
    ProxyPassReverse ws://HOSTNAME:8080/guacamole/websocket-tunnel
</Location>
:::

(disable-tunnel-logging)=

### Disabling logging of tunnel requests

If WebSocket is unavailable, Guacamole will fallback to using an HTTP-based
tunnel. The Guacamole HTTP tunnel works by transferring a continuous stream of
data over multiple short-lived streams, each associated with a separate HTTP
request. By default, Apache will log each of these requests, resulting in a
rather bloated access log.

There is little value in a log file filled with identical tunnel requests, so
it is recommended to explicitly disable logging of those requests. Apache does
provide a means of matching URL patterns and setting environment variables
based on whether the URL matches. Logging can then be restricted to requests
which lack this environment variable:

```apache
SetEnvIf Request_URI "^/guacamole/tunnel" dontlog
CustomLog  /var/log/apache2/guac.log common env=!dontlog
```

Note that if you are serving Guacamole under a path different from
`/guacamole/`, you will need to change the value of `Request_URI` above
accordingly.

