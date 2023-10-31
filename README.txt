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

TESTING
-------

Recommended way to test, using bash and `prove`:

1. Create a .env file in the repository with limited permissions;
2. Export the appropriate environment variables for MATRIX_SERVER, MATRIX_USER,
   and MATRIX_PASSWORD; then
3. Dot-source the .env via.

Sample .env file:

    export MATRIX_SERVER=matrix.org
    export MATRIX_USER=my_bot_1
    export MATRIX_PASSWORD=my_bot_1_password

Do `chmod 600` on the .env file to ensure no other user can read it, especially
if you are in a multiuser environment.  Then adapt the sample .env file values.

On the Matrix home server, create the user matching the MATRIX_USER and
MATRIX_PASSWORD values.  Then, create or add a room for the bot named
"Automation".

The .env file is added to the .gitignore, so do not worry about accidentally
committing the file.  However, it is recommended to use a dedicated bot user
for testing, both to control the test environment, and to narrow the
compromised surface area in case credentials are leaked.

Dot-source the .env file to set up your environment variables:

    . .env

After following the above, you should be able to execute the following in the
repository root and run the tests successfully:

    prove -l

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
