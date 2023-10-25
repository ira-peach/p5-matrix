#!/usr/bin/env perl

use v5.32.1;
use warnings;
use strict;

use HTTP::Tiny;
use JSON;
use DateTime;
use URI::Escape;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);
use Term::Clui;

use Net::Matrix qw(pp);

my $home_server;
my $user;
my $password;
my $room_name;
my $message;
GetOptions(
    "user|u=s" => \$user,
    "password|P=s" => \$password,
    "room-name|r=s" => \$room_name,
    "home-server|H=s" => \$home_server,
    "message|m=s" => \$message)
or die("error parsing command line arguments");

$home_server = $home_server // $ENV{MATRIX_SERVER} // ask("Home server: ", "matrix.org");
$room_name = $room_name // ask("Room name: ", "Automation");
$user = $user // $ENV{MATRIX_USER} // ask("User: ");
$password = $password // $ENV{MATRIX_PASSWORD} // ask_password("Password ");

my $foo = Net::Matrix->connect($home_server, $user, $password);

$foo->post_text_message(
    room_name => $room_name,
    message => $message);
