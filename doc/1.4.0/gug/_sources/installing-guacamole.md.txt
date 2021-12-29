Installing Guacamole natively
=============================

Guacamole is separated into two pieces: guacamole-server, which provides the
guacd proxy and related libraries, and guacamole-client, which provides the
client to be served by your servlet container, usually [Apache
Tomcat](http://tomcat.apache.org/).

guacamole-client is available in binary form, but guacamole-server must be
built from source. Don't be discouraged: building the components of Guacamole
from source is *not* as difficult as it sounds, and the build process is
automated. You just need to be sure you have the necessary tools installed
ahead of time. With the necessary dependencies in place, building Guacamole
only takes a few minutes.

(building-guacamole-server)=

Building guacamole-server
-------------------------

guacamole-server contains all the native, server-side components required by
Guacamole to connect to remote desktops. It provides a common C library,
libguac, which all other native components depend on, as well as separate
libraries for each supported protocol, and guacd, the heart of Guacamole.

guacd is the proxy daemon that runs on your Guacamole server, accepts users'
connections that are tunneled through the Guacamole web application, and then
connects to remote desktops on their behalf. Building guacd creates an
executable called {program}`guacd` which can be run manually or, if you wish,
automatically when your computer starts up.

To build guacamole-server, you will need a C compiler (such as gcc) and the
libraries that guacamole-server depends on. Some dependencies are absolutely
required, while others are optional. The presence of optional dependencies
enables additional features.

:::{important}
Many Linux distributions separate library packages into binary and
"development" packages; *you will need to install the development packages*.
These will usually end in a "-dev" or "-devel" suffix.
:::

### Required dependencies

In order to build guacamole-server, you will need Cairo, libjpeg (or
libjpeg-turbo), libpng, and libuuid (or the OSSP UUID library). These libraries
are strictly required *in all cases* - Guacamole cannot be built without them.

[Cairo](http://cairographics.org/)
: Cairo is used by libguac for graphics rendering.  Guacamole cannot function
  without Cairo installed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libcairo2-dev`
  * - Fedora / CentOS / RHEL package
    - `cairo-devel`
  :::

[libjpeg-turbo](http://libjpeg-turbo.virtualgl.org/)
: libjpeg-turbo is used by libguac to provide JPEG support. Guacamole will not
  build without this library present:

  :::{list-table}
  :stub-columns: 1
  * - Debian package
    - `libjpeg62-turbo-dev`
  * - Ubuntu package
    - `libjpeg-turbo8-dev`
  * - Fedora / CentOS / RHEL package
    - `libjpeg-turbo-devel`
  :::

  If libjpeg-turbo is unavailable on your platform, and you do not wish to
  build it from source, [libjpeg](http://www.ijg.org/) will work as well,
  though it will not be quite as fast:

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libjpeg62-dev`
  * - Fedora / CentOS / RHEL package
    - `libjpeg-devel`
  :::

[libpng](http://www.libpng.org/pub/png/libpng.html)
: libpng is used by libguac to write PNG images, the core image type used by
  the Guacamole protocol. Guacamole cannot function without libpng.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libpng12-dev`
  * - Fedora / CentOS / RHEL package
    - `libpng-devel`
  :::

[libtool](https://www.gnu.org/software/libtool/manual/libtool.html)
: libtool is used during the build process. libtool creates compiled libraries
  needed for Guacamole.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libtool-bin`
  * - Fedora / CentOS / RHEL package
    - `libtool`
  :::

libuuid (part of [util-linux](https://www.kernel.org/pub/linux/utils/util-linux/))
: libuuid is used by libguac to assign unique, internal IDs to each Guacamole
  user and connection. These unique IDs are the basis for connection sharing
  support.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `uuid-dev`
  * - Fedora / CentOS / RHEL package
    - `libuuid-devel`
  :::

  If libuuid is unavailable, the [OSSP UUID](http://www.ossp.org/pkg/lib/uuid/)
  library may also be used:

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libossp-uuid-dev`
  * - Fedora / CentOS / RHEL package
    - `uuid-devel`
  :::

### Optional dependencies

The optional dependencies of Guacamole dictate which parts of guacamole-server
will be built. This includes the support for various remote desktop protocols,
as well as any additional features of those protocols:

* VNC support depends on the libvncclient library, which is part of
  libVNCServer.

* RDP support depends on a recent version of FreeRDP (2.0.0 or higher, but
  please *not a non-release version from git*).

* SSH support depends on libssh2, OpenSSL and Pango (a font rendering and text
  layout library, used by Guacamole's built-in terminal emulator).

* Telnet depends on libtelnet and Pango.

* Kubernetes support depends on libwebsockets, OpenSSL, and Pango.

The `guacenc` utility, provided by guacamole-server to translate screen
recordings into video, depends on FFmpeg, and will only be built if at least
the libavcodec, libavformat, libavutil, and libswscale libraries provided by
FFmpeg are installed.

:::{important}
If you lack these dependencies, *then the features or protocols which
depend on them will not be enabled*. Please read this section
carefully before deciding not to install an optional dependency.
:::

[FFmpeg](https://ffmpeg.org/)
: The libavcodec, libavformat, libavutil, and libswscale libraries provided by
  FFmpeg are used by `guacenc` to encode video streams when translating
  recordings of Guacamole sessions. Without FFmpeg, the `guacenc` utility will
  simply not be built.

  If you do not wish to make graphical recordings of Guacamole sessions, or do
  not wish to translate such recordings into video, then FFmpeg is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libavcodec-dev`, `libavformat-dev`, `libavutil-dev`, `libswsccale-dev`
  * - Fedora / CentOS / RHEL package
    - `ffmpeg-devel`
  :::

[FreeRDP](http://www.freerdp.com/)
: FreeRDP 2.0.0 or later is required for RDP support. If you do not wish to
  build RDP support, this library is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `freerdp2-dev`
  * - Fedora / CentOS / RHEL package
    - `freerdp-devel`
  :::

[Pango](http://www.pango.org/)
: Pango is a text layout library which Guacamole uses to render text for
  protocols that require a terminal (Kubernetes, SSH, and telnet). If you do
  not wish to build any terminal-based protocol support, this library is not
  needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libpango1.0-dev`
  * - Fedora / CentOS / RHEL package
    - `pango-devel`
  :::

[libssh2](http://www.libssh2.org/)
: libssh2 is required for SSH and SFTP support. If you do not wish to build SSH
  or SFTP support, this library is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libssh2-1-dev`
  * - Fedora / CentOS / RHEL package
    - `libssh2-devel`
  :::

[libtelnet](https://github.com/seanmiddleditch/libtelnet)
: libtelnet is required for telnet support. If you do not wish to build telnet
  support, this library is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libtelnet-dev`
  * - Fedora / CentOS / RHEL package
    - `libtelnet-devel`
  :::

[libVNCServer](http://libvnc.github.io/)
: libVNCServer provides libvncclient, which is required for VNC support. If you
  do not wish to build VNC support, this library is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libvncserver-dev`
  * - Fedora / CentOS / RHEL package
    - `libvncserver-devel`
  :::

[libwebsockets](https://libwebsockets.org/)
: libwebsockets is required for Kubernetes support. If you do not wish to build
  Kubernetes support, this library is not needed.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libwebsockets-dev`
  * - Fedora / CentOS / RHEL package
    - `libwebsockets-devel`
  :::

[PulseAudio](http://www.freedesktop.org/wiki/Software/PulseAudio/)
: PulseAudio provides libpulse, which is used by Guacamole's VNC support to
  provide experimental audio support. If you are not going to be using the
  experimental audio support for VNC, you do not need this library.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libpulse-dev`
  * - Fedora / CentOS / RHEL package
    - `pulseaudio-libs-devel`
  :::

[OpenSSL](https://www.openssl.org/)
: OpenSSL provides support for SSL and TLS - two common encryption schemes that
  make up the majority of encrypted web traffic.

  If you have libssl installed, guacd will be built with SSL support, allowing
  communication between the web application and guacd to be encrypted. This
  library is also required for SSH support, for manipulating public/private keys,
  and for Kubernetes support, for SSL/TLS connections to the Kubernetes server.

  Without SSL support, there will be no option to encrypt communication to
  guacd, and support for SSH and Kubernetes cannot be built.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libssl-dev`
  * - Fedora / CentOS / RHEL package
    - `openssl-devel`
  :::

[libvorbis](http://xiph.org/vorbis/)
: libvorbis provides support for Ogg Vorbis - a free and open standard for
  sound compression. If installed, libguac will be built with support for Ogg
  Vorbis, and protocols supporting audio will use Ogg Vorbis compression when
  possible.

  Otherwise, sound will only be encoded as WAV (uncompressed), and will only be
  available if your browser also supports WAV.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libvorbis-dev`
  * - Fedora / CentOS / RHEL package
    - `libvorbis-devel`
  :::

[libwebp](https://developers.google.com/speed/webp/)
: libwebp is used by libguac to write WebP images.  Though support for WebP is
  not mandated by the Guacamole protocol, WebP images will be used if supported
  by both the browser and by libguac.

  Lacking WebP support, Guacamole will simply use JPEG in cases that it would
  have preferred WebP.

  :::{list-table}
  :stub-columns: 1
  * - Debian / Ubuntu package
    - `libwebp-dev`
  * - Fedora / CentOS / RHEL package
    - `libwebp-devel`
  :::

(guacamole-server-source)=

### Obtaining the source code

You can obtain a copy of the guacamole-server source from the Guacamole project
web site. These releases are stable snapshots of the latest code which have
undergone enough testing that the Guacamole team considers them fit for public
consumption. Source downloaded from the project web site will take the form of
a `.tar.gz` archive which you can extract
from the command line:

```console
$ tar -xzf guacamole-server-1.4.0.tar.gz
$ cd guacamole-server-1.4.0/
$
```

If you want the absolute latest code, and don't care that the code hasn't been
as rigorously tested as the code in stable releases, you can also clone the
Guacamole team's git repository on GitHub:

```console
$ git clone git://github.com/apache/guacamole-server.git
Cloning into 'guacamole-server'...
remote: Counting objects: 6769, done.
remote: Compressing objects: 100% (2244/2244), done.
remote: Total 6769 (delta 3058), reused 6718 (delta 3008)
Receiving objects: 100% (6769/6769), 2.32 MiB | 777 KiB/s, done.
Resolving deltas: 100% (3058/3058), done.
$
```

(guacamole-server-build-process)=

### The build process

Once the guacamole-server source has been downloaded and extracted, you need to
run `configure`. This is a shell script automatically generated by GNU
Autotools, a popular build system used by the Guacamole project for
guacamole-server. Running `configure` will determine which libraries are
available on your system and will select the appropriate components for
building depending on what you actually have installed.

:::{important}
Source downloaded directly from git will not contain this `configure` script,
as autogenerated code is not included in the project's repositories. If you
downloaded the code from the project's git repositories directly, you will need
to generate `configure` manually:

```console
$ cd guacamole-server/
$ autoreconf -fi
$
```

Doing this requires GNU Autotools to be installed.

Source archives downloaded from the project website contain the `configure`
script and all other necessary build files, and thus do not require GNU
Autotools to be installed on the build machine.
:::

Once you run `configure`, you can see what a listing of what libraries were
found and what it has determined should be built:

```console
$ ./configure --with-init-dir=/etc/init.d
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
...

------------------------------------------------
guacamole-server version 1.4.0
------------------------------------------------

   Library status:

     freerdp2 ............ yes
     pango ............... yes
     libavcodec .......... yes
     libavformat ......... yes
     libavutil ........... yes
     libssh2 ............. yes
     libssl .............. yes
     libswscale .......... yes
     libtelnet ........... yes
     libVNCServer ........ yes
     libvorbis ........... yes
     libpulse ............ yes
     libwebsockets ....... yes
     libwebp ............. yes
     wsock32 ............. no

   Protocol support:

      Kubernetes .... yes
      RDP ........... yes
      SSH ........... yes
      Telnet ........ yes
      VNC ........... yes

   Services / tools:

      guacd ...... yes
      guacenc .... yes
      guaclog .... yes

   Init scripts: /etc/init.d
   Systemd units: no

Type "make" to compile guacamole-server.

$
```

The `--with-init-dir=/etc/init.d` shown above prepares the build to install a
startup script for guacd into the `/etc/init.d` directory, such that we can
later easily configure guacd to start automatically on boot. If you do not wish
guacd to start automatically at boot, leave off the `--with-init-dir` option.
If the directory containing your distribution's startup scripts differs from
the common `/etc/init.d`, replace `/etc/init.d` with the proper directory here.
You may need to consult your distribution's documentation, or do a little
digging in `/etc`, to determine the proper location.

Here, `configure` has found everything, including all optional libraries, and
will build all protocol support, even support for Ogg Vorbis sound in RDP. If
you are missing some libraries, some of the "`yes`" answers above will read
"`no`". If a library which is strictly required is missing, the script will
fail outright, and you will need to install the missing dependency. If, after
running `configure`, you find support for something you wanted is missing,
simply install the corresponding dependencies and run `configure` again.

:::{important}
All protocols that require a terminal (Kubernetes, SSH, and telnet) require
that fonts are installed on the Guacamole server in order to function, as
output from the terminal cannot be rendered otherwise. Support for these
protocols will build just fine if fonts are not installed, but it will fail to
connect when used:

```
Aug 23 14:09:45 my-server guacd[5606]: Unable to get font "monospace"
```

If terminal-based connections are not working and you see such a message in
syslog, you should make sure fonts are installed and try again.
:::

Once `configure` is finished, just type "`make`", and it will guacamole-server
will compile:

```console
$ make
Making all in src/libguac
make[1]: Entering directory `/home/mjumper/guacamole/guacamole-server/src/libguac'
...
make[1]: Leaving directory `/home/mjumper/guacamole/guacamole-server/src/protocols/vnc'
make[1]: Entering directory `/home/mjumper/guacamole/guacamole-server'
make[1]: Nothing to be done for `all-am'.
make[1]: Leaving directory `/home/mjumper/guacamole/guacamole-server'
$
```

Quite a bit of output will scroll up the screen as all the components are
compiled.

(guacamole-server-installation)=

### Installation

Once everything finishes, all you have left to do is type "`make install`" to
install the components that were built, and then "`ldconfig`" to update your
system's cache of installed libraries:

```console
# make install
Making install in src/libguac
make[1]: Entering directory `/home/mjumper/guacamole/guacamole-server/src/libguac'
make[2]: Entering directory `/home/mjumper/guacamole/guacamole-server/src/libguac'
...
----------------------------------------------------------------------
Libraries have been installed in:
   /usr/local/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.
----------------------------------------------------------------------
make[2]: Nothing to be done for `install-data-am'.
make[2]: Leaving directory `/home/mjumper/guacamole/guacamole-server/src/protocols/vnc'
make[1]: Leaving directory `/home/mjumper/guacamole/guacamole-server/src/protocols/vnc'
make[1]: Entering directory `/home/mjumper/guacamole/guacamole-server'
make[2]: Entering directory `/home/mjumper/guacamole/guacamole-server'
make[2]: Nothing to be done for `install-exec-am'.
make[2]: Nothing to be done for `install-data-am'.
make[2]: Leaving directory `/home/mjumper/guacamole/guacamole-server'
make[1]: Leaving directory `/home/mjumper/guacamole/guacamole-server'
# ldconfig
#
```   

At this point, everything is installed, but guacd is not running. You will need
to run guacd in order to use Guacamole once the client components are installed
as well.

Beware that even after installing guacd and its startup script, you will likely
still have to activate the service for it to start automatically.  Doing this
varies by distribution, but each distribution will have documentation
describing how to do so.

(building-guacamole-client)=

guacamole-client
----------------

:::{important}
Normally, you don't need to build guacamole-client, as it is written in Java
and is cross-platform. You can easily obtain the latest version of
guacamole-client from the release archives of the Guacamole project web site,
including all supported extensions, without having to build it yourself.

If you do not want to build guacamole-client from source, just download
`guacamole.war` from the project web site, along with any desired extensions,
and skip ahead to [](deploying-guacamole).
:::

guacamole-client contains all Java and JavaScript components of Guacamole
(guacamole, guacamole-common, guacamole-ext, and guacamole-common-js). These
components ultimately make up the web application that will serve the HTML5
Guacamole client to users that connect to your server. This web application
will then connect to guacd, part of guacamole-server, on behalf of connected
users in order to serve them any remote desktop they are authorized to access.

To compile guacamole-client, all you need is Apache Maven and a copy of the
Java JDK. Most, if not all, Linux distributions will provide packages for
these.

You can obtain a copy of the guacamole-client source from the Guacamole project
web site. These releases are stable snapshots of the latest code which have
undergone enough testing that the Guacamole team considers them fit for public
consumption. Source downloaded from the project web site will take the form of
a `.tar.gz` archive which you can extract from the command line:

```console
$ tar -xzf guacamole-client-1.4.0.tar.gz
$ cd guacamole-client-1.4.0/
$
```

As with guacamole-server, if you want the absolute latest code, and don't care
that the code hasn't been as rigorously tested as the code in stable releases,
you can also clone the Guacamole team's git repository on GitHub:

```console
$ git clone git://github.com/apache/guacamole-client.git
Cloning into 'guacamole-client'...
remote: Counting objects: 12788, done.
remote: Compressing objects: 100% (4183/4183), done.
remote: Total 12788 (delta 3942), reused 12667 (delta 3822)
Receiving objects: 100% (12788/12788), 3.23 MiB | 799 KiB/s, done.
Resolving deltas: 100% (3942/3942), done.
$
```

Unlike guacamole-server, even if you grab the code from the git repositories,
you won't need to run anything before building. There are no scripts that need
to be generated before building - all Maven needs is the `pom.xml` file
provided with the source.

To build guacamole-client, just run "`mvn package`". This will invoke Maven
to automatically build and package all components, producing a single `.war`
file, which contains the entire web application:

```console
$ mvn package
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO] 
[INFO] guacamole-common
[INFO] guacamole-ext
[INFO] guacamole-common-js
[INFO] guacamole
[INFO] guacamole-auth-cas
[INFO] guacamole-auth-duo
[INFO] guacamole-auth-header
[INFO] guacamole-auth-jdbc
[INFO] guacamole-auth-jdbc-base
[INFO] guacamole-auth-jdbc-mysql
[INFO] guacamole-auth-jdbc-postgresql
[INFO] guacamole-auth-jdbc-sqlserver
[INFO] guacamole-auth-jdbc-dist
[INFO] guacamole-auth-ldap
[INFO] guacamole-auth-openid
[INFO] guacamole-auth-quickconnect
[INFO] guacamole-auth-totp
[INFO] guacamole-example
[INFO] guacamole-playback-example
[INFO] guacamole-client
...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] guacamole-common ................................... SUCCESS [ 21.852 s]
[INFO] guacamole-ext ...................................... SUCCESS [  9.055 s]
[INFO] guacamole-common-js ................................ SUCCESS [  1.988 s]
[INFO] guacamole .......................................... SUCCESS [ 18.040 s]
[INFO] guacamole-auth-cas ................................. SUCCESS [  4.203 s]
[INFO] guacamole-auth-duo ................................. SUCCESS [  2.251 s]
[INFO] guacamole-auth-header .............................. SUCCESS [  1.399 s]
[INFO] guacamole-auth-jdbc ................................ SUCCESS [  1.396 s]
[INFO] guacamole-auth-jdbc-base ........................... SUCCESS [  3.266 s]
[INFO] guacamole-auth-jdbc-mysql .......................... SUCCESS [  4.665 s]
[INFO] guacamole-auth-jdbc-postgresql ..................... SUCCESS [  3.764 s]
[INFO] guacamole-auth-jdbc-sqlserver ...................... SUCCESS [  3.738 s]
[INFO] guacamole-auth-jdbc-dist ........................... SUCCESS [  1.214 s]
[INFO] guacamole-auth-ldap ................................ SUCCESS [  1.991 s]
[INFO] guacamole-auth-openid .............................. SUCCESS [  2.204 s]
[INFO] guacamole-auth-quickconnect ........................ SUCCESS [  2.983 s]
[INFO] guacamole-auth-totp ................................ SUCCESS [  8.154 s]
[INFO] guacamole-example .................................. SUCCESS [  0.895 s]
[INFO] guacamole-playback-example ......................... SUCCESS [  0.795 s]
[INFO] guacamole-client ................................... SUCCESS [  7.478 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 01:41 min
[INFO] Finished at: 2018-10-15T17:08:29-07:00
[INFO] Final Memory: 42M/379M
[INFO] ------------------------------------------------------------------------
$
```

Once the Guacamole web application is built, there will be a .war file in the
`guacamole/target/` subdirectory of the current directory (the directory you
were in when you ran mvn), ready to be deployed to a servlet container like
Tomcat.

(deploying-guacamole)=

Deploying Guacamole
-------------------

The web application portion of Guacamole is packaged as a fully self-contained
`.war` file. If you downloaded Guacamole from the main project web site, this
file will be called `guacamole.war`. Deploying this involves copying the file
into the directory your servlet container uses for `.war` files. In the case of
Tomcat, this will be `CATALINA_HOME/webapps/`. The location of `CATALINA_HOME`
will vary by how Tomcat was installed, but is commonly `/var/lib/tomcat`,
`/var/lib/tomcat7`, or similar:

```console
# cp guacamole.war /var/lib/tomcat/webapps
#
```

If you have built guacamole-client from source, the required `.war` file will
be within the `guacamole/target/` directory and will contain an additional
version suffix. As Tomcat will determine the location of the web application
from the name of the `.war` file, you will likely want to rename this to simply
`guacamole.war` while copying:

```console
# cp guacamole/target/guacamole-1.4.0.war /var/lib/tomcat/webapps/guacamole.war
#
```

Again, if you are using a different servlet container or if Tomcat is installed
to a different location, you will need to check the documentation of your
servlet container, distribution, or both to determine the proper location for
deploying `.war` files like `guacamole.war`.

Once the `.war` file is in place, you may need to restart Tomcat to force
Tomcat to deploy the new web application, and the guacd daemon must be started
if it isn't running already. The command to restart Tomcat and guacd will vary
by distribution. Typically, you can do this by running the corresponding init
scripts with the "restart" option:

```console
# /etc/init.d/tomcat7 restart
Stopping Tomcat... OK
Starting Tomcat... OK
# /etc/init.d/guacd start
Starting guacd: SUCCESS
guacd[6229]: INFO:  Guacamole proxy daemon (guacd) version 1.4.0 started
#
```

:::{important}
If you want Guacamole to start on boot, you will need to configure
the Tomcat and guacd services to run automatically. Your distribution
will provide documentation for doing this.
:::

After restarting Tomcat and starting guacd, Guacamole is successfully
installed, though it will not be fully running. In its current state, it is
completely unconfigured, and further steps are required to add at least one
Guacamole user and a few connections. This is covered in
[](configuring-guacamole).

### What about WebSocket?

Guacamole will use WebSocket automatically if supported by the browser and your
servlet container. In the event that Guacamole cannot connect using WebSocket,
it will immediately and transparently fall back to using HTTP.

WebSocket is supported in Guacamole for Tomcat 7.0.37 or higher, Jetty 8 or
higher, and any servlet container supporting JSR 356, the standardized Java API
for WebSocket.

