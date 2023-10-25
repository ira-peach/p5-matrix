matrix.pl
=========

NAME
----

matrix.pl - send text message to Matrix room in a oneshot manner.

SYNOPSIS
--------

matrix.pl [OPTIONS]... -m MESSAGE

DESCRIPTION
-----------

matrix.pl is a perl script that will log into a Matrix server with a specified
user and password (via the m.login.password login flow), then send a message to
a room by the specified name.

OPTIONS
-------

Mandatory arguments to long options are mandatory for short options too.
-u, --user USER
    Use specified user to log in with.  You may also use the environment
    variable MATRIX_USER or answer the prompt at runtime.

-P, --password PASSWORD
    Use specified password to log in with.  It is recommended to either use the
    environment variable MATRIX_PASSWORD or answer the prompt at runtime as
    there are security implications with using a plain text password on the
    command line (namely, it can be seen via `ps` on multi-user system).

-r, --room-name NAME
    Use the specified room name to message.  The script will exit with an error
    if multiple rooms match the room name.

-H, --home-server SERVER
    Use the specified server as the home server.  The script will determine the
    appropriate API server via the `/.well-known/matrix/client` endpoint.  You
    may also use the environment variable MATRIX_SERVER or answer the prompt at
    runtime.

-m, --message MESSAGE
    Send the specified message.

NOTES
-----

This is super basic, and the author is learning how to cobble together perl
modules.  Namely, you need to set @INC somehow to include lib, or else the
script will likely not work.

BUGS
----

Bugs, bugs, here or there.  Skitter, scatter, everywhere.

The dependencies are mostly undocumented.

SEE ALSO
--------

Protocol::Matrix
Net::Matrix::Webhook
Net::Async::Matrix
App::MatrixClient::Matrix
App::MatrixTool
    Modules the author found for Matrix protocol interaction.  The unfortunate
    part of the name "Matrix" for a protocol is that we also see a lot of data
    structure modules in CPAN with "Matrix" in the name.

https://spec.matrix.org/v1.8/
    Specification of the Matrix API, which has been between confusingly helpful
    to super helpful at different times.
