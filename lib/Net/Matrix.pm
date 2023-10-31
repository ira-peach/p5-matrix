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
package Net::Matrix;

use v5.32.1;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(pp);

use Carp::Always;
use HTTP::Tiny;
use JSON;
use DateTime;
use URI::Escape;

my $basic_http = HTTP::Tiny->new(default_headers => {"Content-Type" => "application/json"});

sub pp {
    use Data::Dumper;
    local $Data::Dumper::Indent = 1;
    print Dumper(\@_);
}

sub connect {
    my $class = shift;
    my ($server,$user,$password) = @_;

    my $api_server = $class->find_api_server($server);

    my $access_token = $class->get_access_token($api_server, $user, $password);

    my $authed_http = HTTP::Tiny->new(default_headers => {"Content-Type" => "application/json", Authorization => "Bearer $access_token"});

    return bless {
        server => $api_server,
        user => $user,
        access_token => $access_token,
        http => $authed_http,
    }, $class;
}

sub get_access_token {
    my $class = shift;
    my ($server, $user, $password) = @_;
    my $content = encode_json {
        identifier => {
            type => "m.id.user",
            user => $user,
        },
        refresh_token => JSON::false,
        type => "m.login.password",
        password => $password,
    };
    my $endpoint = "$server/_matrix/client/v3/login";
    my $response = $basic_http->request("POST", $endpoint, {content => $content});
    die "HTTP failure with $response->{status} $response->{reason}" unless $response->{success};
    $content = decode_json $response->{content};
    my $access_token = $content->{access_token};
    return $access_token;
}

sub find_api_server {
    my $class = shift;
    my ($server) = @_;
    my $response = $basic_http->get("https://$server/.well-known/matrix/client");
    die "HTTP failure with $response->{status} $response->{reason}" unless $response->{success};
    my $content = decode_json $response->{content};
    my $api_server = $content->{"m.homeserver"}{base_url};
    return $api_server;
}

sub server {
    my $class = shift;
    return $class->{server};
}

sub access_token {
    my $class = shift;
    return $class->{access_token};
}

sub retrieve_supported_login_types {
    my $class = shift;
    my ($server) = @_;
    $server //= $class->{server};

    my $response = $basic_http->get("$server/_matrix/client/v3/login");
    my $content = decode_json $response->{content};

    my @flow_types;
    for (@{$content->{flows}}) {
        #say "supported login type: $_->{type}";
        push @flow_types, $_->{type};
    }
    return @flow_types;
}

sub retrieve_rooms {
    my $class = shift;
    my $response = $class->http->get("$class->{server}/_matrix/client/v3/joined_rooms");
    my $content = decode_json $response->{content};
    return @{$content->{joined_rooms}};
}

sub retrieve_room_name {
    my $class = shift;
    my @rooms = $class->retrieve_rooms;
    my %params = (
        filter => encode_json {
            types => ["m.room.name"],
        }
    );
    my $params = $basic_http->www_form_urlencode(\%params);
    my @rooms_output = ();
    for my $room (@rooms) {
        my $response = $class->http->request("GET", "$class->{server}/_matrix/client/v3/rooms/$room/messages?$params");
        my $content = decode_json $response->{content};
        my @chunks = @{$content->{chunk}};
        return $chunks[0]{content}{name} if @chunks;
    }
}

sub retrieve_room_names {
    my $class = shift;
    my @room_ids = $class->retrieve_rooms;
    my @rooms = ();
    for (@room_ids) {
        my $room_name = $class->retrieve_room_name($_);
        push @rooms, {
            room_id => $_,
            room_name => $room_name,
        };
    }
    return @rooms;
}

sub retrieve_room_ids_by_name {
    my $class = shift;
    my ($room_name) = @_;

    my @rooms = $class->retrieve_room_names;
    my @room_ids = ();
    for my $room (@rooms) {
        push @room_ids, $room->{room_id} if $room->{room_name} eq $room_name;
    }
    return @room_ids;
}

sub retrieve_room_id_by_name {
    my $class = shift;
    my ($room_name) = @_;

    my @room_ids = $class->retrieve_room_ids_by_name($room_name);
    die "no room ids found with name '$room_name'" if scalar @room_ids == 0;
    die "more than one room id found with name '$room_name': " . (join ',',@room_ids) if scalar @room_ids > 1;
    return $room_ids[0];
}

sub http {
    my $class = shift;
    return $class->{http};
}

sub post_text_message {
    my $class = shift;
    my %args = @_;

    my $room_id = $args{room_id};
    my $room_name = $args{room_name};
    my $message = $args{message};

    die "only need room_id or room_name" if $room_id and $room_name;
    die "need message" unless $message;

    $room_id = $room_id // $class->retrieve_room_id_by_name($room_name);

    my $utc = DateTime->now;
    my $hostname = qx(hostname);
    chomp $hostname;
    my $hostuser = $ENV{USER};
    $message = "[$utc] [$hostuser\@$hostname] $message";

    my $content = encode_json {
        body => $message,
        msgtype => "m.text",
    };
    my %options = (
        content => $content,
    );
    my $endpoint = "$class->{server}/_matrix/client/v3/rooms/$room_id/send/m.room.message/$utc";
    my $response = $class->http->request("PUT", $endpoint, \%options);
    die "could not post message; status $response->{status} '$response->{reason}'" unless $response->{success};
    return 1;
}

1;
