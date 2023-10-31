#!/usr/bin/env perl

use v5.32.1;
use warnings;
use strict;

use Test2::V0;

use Net::Matrix;

$ENV{MATRIX_SERVER} and $ENV{MATRIX_USER} and $ENV{MATRIX_PASSWORD} or die "Please set environment variables: MATRIX_SERVER, MATRIX_USER, MATRIX_PASSWORD.  Sample .env file to create and source in current directory:

export MATRIX_SERVER=matrix.org
export MATRIX_USER=my_bot_1
export MATRIX_PASSWORD=my_secret_password";

my $home_server = $ENV{MATRIX_SERVER};
my $user = $ENV{MATRIX_USER};
my $password = $ENV{MATRIX_PASSWORD};

my $conn = Net::Matrix->connect($home_server, $user, $password);
ok($conn, "connection successful");

done_testing;
