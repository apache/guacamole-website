guacamole-ext
=============

While not strictly part of the Java API provided by the Guacamole project,
guacamole-ext is an API exposed by the Guacamole web application within a
separate project such that extensions, specifically authentication providers,
can be written to tweak Guacamole to fit well in existing deployments.

Extensions to Guacamole can:

1. Provide alternative authentication methods and sources of connection/user
   data.

2. Provide event listeners that will be notified as Guacamole performs tasks
   such as authentication and tunnel connection.

3. Theme or brand Guacamole through additional CSS files and static resources.

4. Extend Guacamole's JavaScript code by providing JavaScript that will be
   loaded automatically.

5. Add additional display languages, or alter the translation strings of
   existing languages.

(ext-file-format)=

Guacamole extension format
--------------------------

Guacamole extensions are standard Java `.jar` files which contain all classes
and resources required by the extension, as well as the Guacamole extension
manifest. There is no set structure to an extension except that the manifest
must be in the root of the archive. Java classes and packages, if any, will be
read from the `.jar` relative to the root, as well.

Beyond this, the semantics and locations associated with all other resources
within the extension are determined by the extension manifest alone.

(ext-manifest)=

### Extension manifest

The Guacamole extension manifest is a single JSON file, `guac-manifest.json`,
which describes the location of each resource, the type of each resource, and
the version of Guacamole that the extension was built for. The manifest can
contain the following properties:

`guacamoleVersion`
: The version string of the Guacamole release that this extension is written
  for. *This property is required for all extensions.* The special version
  string `"*"` can be used if the extension does not depend on a particular
  version of Guacamole, but be careful - this will bypass version compatibility
  checks, and should never be used if the extension does more than basic
  theming or branding.

`name`
: A human-readable name for the extension. *This property is required for all
  extensions.* When your extension is successfully loaded, a message
  acknowledging the successful loading of your extension by name will be
  logged.

`namespace`
: A unique string which identifies your extension. *This property is required
  for all extensions.* This string should be unique enough that it is unlikely
  to collide with the namespace of any other extension.

  If your extension contains static resources, those resources will be served
  at a path derived from the namespace provided here.

`authProviders`
: An array of the classnames of all `AuthenticationProvider` subclasses
  provided by this extension.

`listeners`
: An array of the classnames of all `Listener` subclasses provided by this
  extension.

`js`
: An array of all JavaScript files within the extension. All paths within this
  array must be relative paths, and will be interpreted relative to the root of
  the archive.

  JavaScript files declared here will be automatically loaded when the web
  application loads within the user's browser.

`css`
: An array of all CSS files within the extension. All paths within this array
  must be relative paths, and will be interpreted relative to the root of the
  archive.

  CSS files declared here will be automatically applied when the web
  application loads within the user's browser.

`html`
: An array of all HTML files within the extension that should be used to update
  or replace existing HTML within the Guacamole interface. All paths within
  this array must be relative paths, and will be interpreted relative to the
  root of the archive.

  HTML files declared here will be automatically applied to other HTML within
  the Guacamole interface when the web application loads within the user's
  browser. The manner in which the files are applied is dictated by
  `<meta ...>` tags within those same files.

`translations`
: An array of all translation files within the extension. All paths within this
  array must be relative paths, and will be interpreted relative to the root of
  the archive.

  Translation files declared here will be automatically added to the available
  languages. If a translation file provides a language that already exists
  within Guacamole, its strings will override the strings of the existing
  translation.

`resources`
: An object where each property name is the name of a web resource file, and
  each value is the mimetype for that resource. All paths within this object
  must be relative paths, and will be interpreted relative to the root of the
  archive.

  Web resources declared here will be made available to the application at
  {samp}`app/ext/{NAMESPACE}/{PATH}`, where `NAMESPACE` is the value of the
  namespace property, and `PATH` is the declared web resource filename.

The only absolutely required properties are `guacamoleVersion`, `name`, and
`namespace`, as they are used to identify the extension and for compatibility
checks. The most minimal `guac-manifest.json` will look something like this:

```json
{
    "guacamoleVersion" : "1.4.0",
    "name" : "My Extension",
    "namespace" : "my-extension"
}
```

This will allow the extension to load, but does absolutely nothing otherwise.
Lacking the semantic information provided by the other properties, no other
files within the extension will be used. A typical `guac-manifest.json` for an
extension providing theming or branding would be more involved:

```json
{

    "guacamoleVersion" : "1.4.0",

    "name"      : "My Extension",
    "namespace" : "my-extension",

    "css" : [ "theme.css" ],

    "html" : [ "loginDisclaimer.html" ],

    "resources" : {
        "images/logo.png"   : "image/png",
        "images/cancel.png" : "image/png",
        "images/delete.png" : "image/png"
    }

}
```

(ext-patch-html)=

### Updating existing HTML

The existing HTML structure of Guacamole's interface can be modified by
extensions through special "patch" HTML files declared by the html property in
`guac-manifest.json`. These files are HTML fragments and are identical to any
other HTML file except that they contain Guacamole-specific meta tags that
instruct Guacamole to modify its own HTML in a particular way. Each meta tag
takes the following form:

```html
<meta name="NAME" content="SELECTOR">
```

where `SELECTOR` is a CSS selector that matches the elements within the
Guacamole interface that serve as a basis for the modification, and `NAME` is
any one of the following defined modifications:

`before`
: Inserts the specified HTML immediately before any element matching the CSS
  selector.

`after`
: Inserts the specified HTML immediately after any element matching the CSS
  selector.

`replace`
: Replaces any element matching the CSS selector with the specified HTML.

`before-children`
: Inserts the specified HTML immediately before the first child (if any) of any
  element matching the CSS selector. If a matching element has no children, the
  HTML simply becomes the entire contents of the matching element.

`after-children`
: Inserts the specified HTML immediately after the last child (if any) of any
  element matching the CSS selector. If a matching element has no children, the
  HTML simply becomes the entire contents of the matching element.

`replace-children`
: Replaces the entire contents of any element matching the CSS selector with
  the specified HTML.

For example, to add a welcome message and link to some corporate privacy policy
(a fairly common need), you would add an HTML file like the following:

```html
<meta name="after" content=".login-ui .login-dialog">

<div class="welcome">
    <h2>Welcome to our Guacamole server!</h2>
    <p>
        Please be sure to read our <a href="/path/to/some/privacy.html">privacy
        policy</a> before continuing.
    </p>
</div>
```

After the extension is installed and Guacamole is restarted, the "welcome" div
and its contents will automatically be inserted directly below the login dialog
(the only element that would match `.login-ui .login-dialog`) as if they were
part of Guacamole's HTML in the first place.

An example of an extension that modifies style and HTML components for the
purpose of providing custom "branding" of the Guacamole interface can be found
in the `doc/guacamole-branding-example` directory of the guacamole-client
source code, which can be found here:
<https://github.com/apache/guacamole-client/tree/master/doc/guacamole-branding-example>

(ext-environment)=

Accessing the server configuration
----------------------------------

The configuration of the Guacamole server is exposed through the `Environment`
interface, specifically the `LocalEnvironment` implementation of this
interface. Through `Environment`, you can access all properties declared within
`guacamole.properties`, determine the proper hostname/port of guacd, and access
the contents of `GUACAMOLE_HOME`.

(ext-simple-config)=

### Custom properties

If your extension requires generic, unstructured configuration parameters,
`guacamole.properties` is a reasonable and simple location for them. The
`Environment` interface provides direct access to `guacamole.properties` and
simple mechanisms for reading and parsing the properties therein. The value of
a property can be retrieved by calling `getProperty()`, which will return
`null` or a default value for undefined properties, or `getRequiredProperty()`,
which will throw an exception for undefined properties.

For convenience, guacamole-ext contains several pre-defined property base
classes for common types:

`BooleanGuacamoleProperty`
: The values "true" and "false" are parsed as their corresponding `Boolean`
  values. Any other value results in a parse error.

`IntegerGuacamoleProperty`
: Numeric strings are parsed as `Integer` values. Non-numeric strings will
  result in a parse error.

`LongGuacamoleProperty`
: Numeric strings are parsed as `Long` values. Non-numeric strings will result
  in a parse error.

`StringGuacamoleProperty`
: The property value is returned as an untouched `String`. No parsing is
  performed, and parse errors cannot occur.

`FileGuacamoleProperty`
: The property is interpreted as a filename, and a new `File` pointing to that
  filename is returned. If the filename is invalid, a parse error will be
  thrown. Note that the file need not exist or be accessible for the filename
  to be valid.

To use these types, you must extend the base class, implementing the
`getName()` function to identify your property. Typically, you would declare
these properties as static members of some class containing all properties
relevant to your extension:

```java
public class MyProperties {

    public static MY_PROPERTY = new IntegerGuacamoleProperty() {

        @Override
        public String getName() { return "my-property"; }

    };

}
```

Your property can then be retrieved with `getProperty()` or
`getRequiredProperty()`:

```java
Integer value = environment.getProperty(MyProperties.MY_PROPERTY);
```

If you need more sophisticated parsing, you can also implement your own
property types by implementing the `GuacamoleProperty` interface. The only
functions to implement are `getName()`, which returns the name of the property,
and `parseValue()`, which parses a given string and returns its value.

(ext-advanced-config)=

### Advanced configuration

If you need more structured data than provided by simple properties, you can
place completely arbitrary files in a hierarchy of your choosing anywhere
within `GUACAMOLE_HOME` as long as you avoid placing your files in directories
reserved for other purposes as described above.

The `Environment` interface exposes the location of `GUACAMOLE_HOME` through
the `getGuacamoleHome()` function. This function returns a standard Java `File`
which can then be used to locate other files or directories within
`GUACAMOLE_HOME`:

```java
File myConfigFile = new File(environment.getGuacamoleHome(), "my-config.xml");
```

There is no guarantee that `GUACAMOLE_HOME` or your file will exist, and you
should verify this before proceeding further in your extension's configuration
process, but once this is done you can simply parse your file as you see fit.

(ext-auth-providers)=

Authentication providers
------------------------

Guacamole's authentication system is driven by authentication providers, which
are classes which implement the `AuthenticationProvider` interface defined by
guacamole-ext. When any page within Guacamole is visited, the following process
occurs:

1. All currently installed extensions are polled, in lexicographic order of
   their filenames, by invoking the `getAuthenticatedUser()` function with a
   `Credentials` object constructed with the contents of the HTTP request.

   The credentials given are abstract. While the `Credentials` object provides
   convenience access to a traditional username and password, *implementations
   are not required to use usernames and passwords*. The entire contents of
   the HTTP request is at your disposal, including parameters, cookies, and SSL
   information.

2. If an authentication attempt fails, the extension throws either a
   `GuacamoleInsufficientCredentialsException` (if more credentials are needed
   before validity can be determined) or `GuacamoleInvalidCredentialsException`
   (if the credentials are technically sufficient, but are invalid as
   provided). If all extensions fail to authenticate the user, the contents of
   the exception thrown by the first extension to fail are used to produce the
   user login prompt.

   *Note that this means there is no "login screen" in Guacamole per se; the
   prompt for credentials for unauthenticated users is determined purely based
   on the needs of the extension as declared within the authentication failure
   itself.*

   If an authentication attempt succeeds, the extension returns an instance of
   `AuthenticatedUser` describing the identity of the user that just
   authenticated, and no further extensions are polled.

3. If authentication has succeeded, and thus an `AuthenticatedUser` is
   available, that `AuthenticatedUser` is passed to the `getUserContext()`
   function of all extensions' authentication providers. Each extension now has
   the opportunity to provide access to data for a user, even if that extension
   did not originally authenticate the user. If no `UserContext` is returned
   for the given `AuthenticatedUser`, then that extension has simply refused to
   provide data for that user.

   The Guacamole interface will transparently unify the data from each
   extension, providing the user with a view of all available connections. If
   the user has permission to modify or administer any objects associated with
   an extension, access to the administrative interface will be exposed as
   well, again with a unified view of all applicable objects.

:::{important}
Because authentication is decoupled from data storage/access, *you do not need
to implement full-blown data storage if you only wish to provide an additional
authentication mechanism*. You can instead implement only the authentication
portion of an `AuthenticationProvider`, and otherwise rely on the storage and
features provided by other extensions, such as the [database authentication
extension](jdbc-auth).
:::

The Guacamole web application includes a basic authentication provider
implementation which parses an XML file to determine which users exist, their
corresponding passwords, and what configurations those users have access to.
This is the part of Guacamole that reads the `user-mapping.xml` file. If you
use a custom authentication provider for your authentication, this file will
probably not be required.

The community has implemented authentication providers which access databases,
use LDAP, or even perform no authentication at all, redirecting all users to a
single configuration specified in `guacamole.properties`.

A minimal authentication provider is implemented in the tutorials later, and
the upstream authentication provider implemented within Guacamole, as well as
the authentication providers implemented by the community, are good examples
for how authentication can be extended without having to implement a whole new
web application.

(ext-simple-auth)=

### `SimpleAuthenticationProvider`

The `SimpleAuthenticationProvider` class provides a much simpler means of
implementing authentication when you do not require the ability to add and
remove users and connections. It is an abstract class and requires only one
function implementation: `getAuthorizedConfigurations()`.

This function is required to return a `Map` of unique IDs to configurations,
where these configurations are all configurations accessible with the provided
credentials. As before, the credentials given are abstract. You are not
required to use usernames and passwords.

The configurations referred to by the function name are instances of
`GuacamoleConfiguration` (part of guacamole-common), which is just a wrapper
around a protocol name and set of parameter name/value pairs. The name of the
protocol to use and a set of parameters is the minimum information required for
other parts of the Guacamole API to complete the handshake required by the
Guacamole protocol.

When a class that extends `SimpleAuthenticationProvider` is asked for more
advanced operations by the web application, `SimpleAuthenticationProvider`
simply returns that there is no permission to do so. This effectively disables
all administrative functionality within the web interface.

If you choose to go the simple route, most of the rest of this chapter is
irrelevant. Permissions, security model, and various classes will be discussed
that are all handled for you automatically by `SimpleAuthenticationProvider`.

(ext-user-context)=

The `UserContext`
-----------------

The `UserContext` is the root of all data-related operations. It is used to
list, create, modify, or delete users and connections, as well as to query
available permissions. If an extension is going to provide access to data of
any sort, it must do so through the `UserContext`.

The Guacamole web application uses permissions queries against the
`UserContext` to determine what operations to present, but *beware that it is
up to the `UserContext` to actually enforce these restrictions*. The Guacamole
web application will not enforce restrictions on behalf of the `UserContext`.

The `UserContext` is the sole means of entry and the sole means of modification
available to a logged-in user. If the `UserContext` refuses to perform an
operation (by throwing an exception), the user cannot perform the operation at
all.

(ext-object-directories)=

`Directory` classes
-------------------

Access to objects beneath the `UserContext` is given through `Directory`
classes. These `Directory` classes are similar to Java collections, but they
also embody update and batching semantics. Objects can be retrieved from a
`Directory` using its `get()` function and added or removed with `add()` and
`remove()` respectively, but objects already in the set can also be updated by
passing an updated object to its `update()` function.

An implementation of a `Directory` can rely on these functions to define the
semantics surrounding all operations. The `add()` function is called only when
creating new objects, the `update()` function is called only when updating an
object previously retrieved with `get()`, and `remove()` is called only when
removing an existing object by its identifier.

When implementing an `AuthenticationProvider`, you must ensure that the
`UserContext` will only return `Directory` classes that automatically enforce
the permissions associated with all objects and the associated user.

(ext-rest-resources)=

REST resources
--------------

Arbitrary REST resources may be exposed by extensions at the
`AuthenticationProvider` level, if the resource does not require an associated
authenticated user, or at the `UserContext` level, if the resource should be
available to authenticated users only. In both cases, the REST resource is
provided through implementing the `getResource()` function, returning an object
which is annotated with JAX-RS annotations (JSR 311).

The resource returned by `getResource()` functions as the root resource,
providing access to other resources beneath itself. The root resource for the
`AuthenticationProvider` is exposed at {samp}`{PATH}/api/ext/{IDENTIFIER}`, and
the root resource for the `UserContext` is exposed at
{samp}`{PATH}/api/session/ext/{IDENTIFIER}`, where `PATH` is the path to which
Guacamole has been deployed (typically `/guacamole/`) and `IDENTIFIER` is the
unique identifier for the `AuthenticationProvider`, as returned by
`getIdentifier()`.

The behavior of extension REST resources is generally left entirely to the
implementation, with the exception that the "token" request parameter is
reserved for use by Guacamole. This parameter contains the user's
authentication token when the user is logged in, and must be present on all
requests which require authentication. Though not relevant to REST resources
exposed at the `AuthenticationProvider` level, resources exposed at the
`UserContext` level inherently require the "token" parameter to be present, as
it is the sole means of locating the user's session.

(ext-permissions)=

Permissions
-----------

The permissions system within guacamole-ext is an advisory system. It is the
means by which an authentication module describes to the web application what a
user is allowed to do. The body of permissions granted to a user describes
which objects that user can see and what they can do to those objects, and thus
suggests how the Guacamole interface should appear to that user.

*Permissions are not the means by which access is restricted*; they are purely
a means of describing access level. An implementation may internally use the
permission objects to define restrictions, but this is not required. It is up
to the implementation to enforce its own restrictions by throwing exceptions
when an operation is not allowed, and to correctly communicate the abilities of
individual users through these permissions.

The permissions available to a user are exposed through the
`SystemPermissionSet` and `ObjectPermissionSet` classes which are accessible
through the `UserContext`. These classes also serve as the means for
manipulating the permissions granted to a user.

### System permissions

System permissions describe access to operations that manipulate the system as
a whole, rather than specific objects. This includes the creation of new
objects, as object creation directly affects the system, and per-object
controls cannot exist before the object is actually created.

`ADMINISTER`
: The user is a super-user - the Guacamole equivalent of root. They are allowed
  to manipulate of system-level permissions and all other objects. This
  permission implies all others.

`CREATE_CONNECTION`
: The user is allowed to create new connections. If a user has this permission,
  the management interface will display components related to connection
  creation.

`CREATE_CONNECTION_GROUP`
: The user is allowed to create new connection groups. If a user has this
  permission, the management interface will display components related to
  connection group creation.

`CREATE_SHARING_PROFILE`
: The user is allowed to create new sharing profiles. If a user has this
  permission, the management interface will display components related to
  sharing profile creation.

`CREATE_USER`
: The user is allowed to create other users. If a user has this permission, the
  management interface will display components related to user creation.

### Object permissions

Object permissions describe access to operations that affect a particular
object. Guacamole currently defines four types of objects which can be
associated with permissions: users, connections, connection groups, and sharing
profiles. Each object permission associates a single user with an action that
may be performed on a single object.

`ADMINISTER`
: The user may grant or revoke permissions involving this object. "Involving",
  in this case, refers to either side of the permission association, and
  includes both the user to whom the permission is granted and the object the
  permission affects.

`DELETE`
: The user may delete this object. This is distinct from the `ADMINISTER`
  permission which deals only with permissions. A user with this permission
  will see the "Delete" button when applicable.

`READ`
: The user may see that this object exists and read the properties of that
  object.

  Note that the implementation is *not required to divulge the true underlying
  properties of any object*. The parameters of a connection or sharing profile,
  the type or contents of a connection group, the password of a user, etc. all
  need not be exposed.

  This is particularly important from the perspective of security when it comes
  to connections, as the parameters of a connection are only truly needed when
  a connection is being modified, and likely should not be exposed otherwise.
  The actual connection operation is always performed internally by the
  authentication provider, and thus does not require client-side knowledge of
  anything beyond the connection's existence.

`UPDATE`
: The user may change the properties of this object.

  In the case of users, this means the user's password can be altered.
  *Permissions are not considered properties of a user*, nor objects in their
  own right, but rather associations between a user and an action which may
  involve another object.

  The properties of a connection include its name, protocol, parent connection
  group, and parameters. The properties of a connection group include its name,
  type, parent connection group, and children. The properties of a sharing
  profile include its name, primary connection, and parameters.

(ext-connections)=

Connections
-----------

Guacamole connections are organized in a hierarchy made up of connection
groups, which each act as folders organizing the connections themselves. The
hierarchy is accessed through the root-level connection group, exposed by
`getRootConnectionGroup()` by the `UserContext`. The connections and connection
groups exposed beneath the root connection group must also be accessible
directly through the connection and connection group directories exposed by
`getConnectionDirectory()` and `getConnectionGroupDirectory()` of the
`UserContext`.

When a user attempts to use a connection the `connect()` of the associated
`Connection` object will be invoked. It is then up to the implementation of
this function to establish the TCP connection to guacd, perform the connection
handshake (most likely via an `InetGuacamoleSocket` wrapped within a
`ConfiguredGuacamoleSocket`), and then return a `GuacamoleTunnel` which
controls access to the established socket.

Extensions may maintain historical record of connection use via
`ConnectionRecord` objects, which are exposed both at the `Connection` level
and across all connections via the `UserContext`. Such record maintenance is
optional, and it is expected that most implementations will simply return empty
lists.

:::{important}
If connection state will not be tracked by the extension, and the parameters
associated with the connection will be known at the time the connection object
is created, the `SimpleConnection` implementation of `Connection` can be used
to make life easier.
:::

(ext-active-connections)=

Managing/sharing active connections
-----------------------------------

After a connection has been established, its underlying `GuacamoleTunnel` can
be exposed by a `UserContext` through the `Directory` returned by
getActiveConnectionDirectory(). The `ActiveConnection` objects accessible
through this `Directory` are the means by which an administrator may monitor or
forcibly terminate another user's connection, ultimately resulting in Guacamole
invoking the `close()` function of the underlying `GuacamoleTunnel`, and also
serve as the basis for screen sharing.

Screen sharing is implemented through the use of `SharingProfile` objects,
exposed through yet another `Directory` beneath the `UserContext`. Each sharing
profile is associated with a single connection that it can be used to share,
referred to as the "primary connection". If a user has read access to a sharing
profile associated with their current connection, that sharing profile will be
displayed as an option within [the share menu of the Guacamole
menu](client-share-menu).

The overall sharing process is as follows:

1. A user, having access to a sharing profile associated with their current
   active connection, clicks its option within the [share menu](client-share-menu).

2. Guacamole locates the `ActiveConnection` and invokes its
   `getSharingCredentials()` function with the identifier of the sharing
   profile. The contents of the returned `UserCredentials` object is used by
   Guacamole to generate a sharing link which can be given to other users.

3. When another user visits the sharing link, the credentials embedded in the
   link are passed to the authentication providers associated with each
   installed extension. *It is up to the extension that originally provided
   those credentials to authenticate the user and provide them with access to
   the shared connection.*

4. When the user attempts to connect to the shared connection, the extension
   establishes the connection using the ID of the connection being joined.
   *This is not the connection identifier as dictated by guacamole-ext, but
   rather [the unique ID assigned by guacd as required by the Guacamole
   protocol](guacamole-protocol-joining).* This ID can be retrieved from a
   `ConfiguredGuacamoleSocket` via `getConnectionID()`, and can be passed
   through a `GuacamoleConfiguration` through `setConnectionID()` (instead of
   specifying a protocol, as would be done for a brand new connection).

