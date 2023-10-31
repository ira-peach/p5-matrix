#!/usr/bin/env perl

# Net::Matrix library for Matrix protocol interaction.
# Copyright (C) 2023  Ira Peach
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
use v5.32.1;
use warnings;
use strict;

use HTTP::Tiny;
use JSON;
use DateTime;
use URI::Escape;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);
use Term::Clui;
use DDP;
use File::Basename;

use Net::Matrix qw(pp);

sub usage_and_exit {
    my ($status) = @_;

    my $stream = *STDOUT;
    $stream = *STDERR if $status;

    my $program = basename $0;
    my $usage =<<EOF;
$program [OPTIONS]... -m MESSAGE
$program -h

Mandatory arguments to long options are mandatory for short options too.
-h, --help
    Display this help
-u, --user NAME
    User to log into home server as.  You may also set the environment variable MATRIX_USER instead.
-p, --password PASSWORD
    User password to log in with.  It is recommended to set the environment variable MATRIX_PASSWORD instead or omit this option to allow interactive input
-r, --room-name NAME
    Room name to find.  If multiple room names are returned, this will error.
-H, --home-server SERVER
    Home server to use.  Defaults to matrix.org.  You may also set the environment variable MATRIX_SERVER instead.
-m, --message MESSAGE
    Message to send; required.
EOF

    say $stream $usage;
    say STDERR "ERROR: invalid invocation" if $status;

    exit $status;
}

my $home_server;
my $user;
my $password;
my $room_name;
my $message;
my $help;
my $get_login_types;
GetOptions(
    "help|h" => \$help,
    "user|u=s" => \$user,
    "password|P=s" => \$password,
    "room-name|r=s" => \$room_name,
    "home-server|H=s" => \$home_server,
    "message|m=s" => \$message)
or die("error parsing command line arguments");

usage_and_exit 0 if $help;
usage_and_exit 1 unless $message;

$home_server = $home_server // $ENV{MATRIX_SERVER} // ask("Home server: ", "matrix.org");

$room_name = $room_name // ask("Room name: ", "Automation");
$user = $user // $ENV{MATRIX_USER} // ask("User: ");
$password = $password // $ENV{MATRIX_PASSWORD} // ask_password("Password ");

my $foo = Net::Matrix->connect($home_server, $user, $password);

$foo->post_text_message(
    room_name => $room_name,
    message => $message);
