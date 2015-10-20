package Net::Cisco::MSE::REST;

use warnings;
use strict;

use Carp;
use LWP::UserAgent;
use JSON;
use HTTP::Request;

our $VERSION = 0.1;

sub new {
    my ($class, %params) = @_;

    my $url   = $params{url} || 'http://localhost:8083/';

    my $user = $params{user} || 'cisco';
    my $pass = $params{pass} || 'cisco';

    my $agent = LWP::UserAgent->new();

    $agent->timeout($params{timeout})
        if $params{timeout};
    $agent->ssl_opts(%{$params{ssl_opts}})
        if $params{ssl_opts} && ref $params{ssl_opts} eq 'HASH';

    my $req = new HTTP::Request;
    $req->authorization_basic($user,$pass);
    $req->header(Accept => " application/json");
    my $self = {
        url   => $url,
        agent => $agent,
        req => $req,
    };
    bless $self, $class;

    return $self;
}

sub maps {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/maps");
}

sub maps_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/maps/count");
}


sub maps_info {
    my ($self, $args) = @_;

    croak "missing campusName parameter" unless $args->{campusName};
    croak "missing buildingName parameter" unless $args->{buildingName};
    croak "missing floorName parameter" unless $args->{floorName};

    return $self->_get("/api/contextaware/v1/maps/info/$args->{campusName}/$args->{buildingName}/$args->{floorName}");
}

sub maps_image {
    my ($self, $args) = @_;

    croak "missing campusName parameter" unless $args->{campusName};
    croak "missing buildingName parameter" unless $args->{buildingName};
    croak "missing floorName parameter" unless $args->{floorName};

    return $self->_get("/api/contextaware/v1/maps/image/$args->{campusName}/$args->{buildingName}/$args->{floorName}");
}

sub maps_image_source {
    my ($self, $args) = @_;

    croak "missing imageName parameter" unless $args->{imageName};

    return $self->_get_bin("/api/contextaware/v1/maps/imagesource/$args->{imageName}");
}

sub real_time_localisation_for_client {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/clients/$args->{id}");
}

sub real_time_localisation_for_client_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/clients/count");
}

sub real_time_localisation_for_tags {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/tags");
}

sub real_time_localisation_for_tags_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/tags/count");
}

sub real_time_localisation_for_rogueaps {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/rogueaps");
}

sub real_time_localisation_for_rogueaps_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/rogueaps/count");
}

sub real_time_localisation_for_rogueclients {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/rogueclients");
}

sub real_time_localisation_for_rogueclients_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/rogueclients/count");
}

sub real_time_localisation_for_interferers {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/interferers/$args->{id}");
}

sub real_time_localisation_for_interferers_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/interferers/count");
}

sub localisation_history_for_client {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/history/clients/$args->{id}");
}

sub localisation_history_for_client_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/history/clients/count");
}

sub localisation_history_for_tags {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/history/tags/");
}

sub localisation_history_for_tags_count {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/history/tags/count");
}

sub localisation_history_for_rogueaps {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/history/rogueaps");
}

sub localisation_history_for_rogueaps_count {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/history/rogueaps/$args->{id}/count");
}

sub localisation_history_for_rogueclients {
    my ($self) = @_;

    return $self->_get("/api/contextaware/v1/location/history/rogueclients");
}

sub localisation_history_for_rogueclients_count {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/history/rogueclients/count");
}

sub localisation_history_for_interferers {
    my ($self) = @_;


    return $self->_get("/api/contextaware/v1/location/history/interferers");
}

sub localisation_history_for_interferers_count {
    my ($self, $args) = @_;

    croak "missing id parameter" unless $args->{id};

    return $self->_get("/api/contextaware/v1/location/history/interferers/$args->{id}/count");
}

sub _get_bin {
    my ($self, $path, %params) = @_;

    $self->{req}->method("GET");
    $self->{req}->uri($self->{url} . $path);
    $self->{req}->header(Accept => "image/jpeg");

    my $response = $self->{agent}->request($self->{req});

    if ($response->is_success()) {
        return $response->content;
    } else {
        croak "communication error: " . $response->message()
    }
}

sub _get {
    my ($self, $path, %params) = @_;

    $self->{req}->method("GET");
    $self->{req}->uri($self->{url} . $path);

    my $response = $self->{agent}->request($self->{req});

    my $result = eval { from_json($response->content()) };

    if ($response->is_success()) {
        return $result;
    } else {
        if ($result) {
            croak "server error: " . $result->{error};
        } else {
            croak "communication error: " . $response->message()
        }
    }
}

1;
__END__

=head1 NAME

Net::Cisco::MSE::REST - REST interface for Cisco MSE

=head1 DESCRIPTION

This module provides a Perl interface for communication with Cisco MSE
using REST interface.

=head1 SYNOPSIS

    use Net::Cisco::MSE::REST;

    my $rest = Net::Cisco::MSE::REST->new(
        url => 'https://my.mse:8034',
        user => 'cisco',
        pass => 'cisco'
    ):
    my $location = $rest->real_time_localisation_for_client({id => '2c:1f:23:ca:1a:cf'});


=head1 CLASS METHODS

=head2 Net::Cisco::MSE::REST->new(url => $url, [ssl_opts => $opts, timeout => $timeout], user => 'cisco', pass => 'cisco')

Creates a new L<Net::Cisco::MSE::Rest> instance.

=head1 INSTANCE METHODS

=head2 $rest->create_session(username => $username, password => $password)

Creates a new session token for the given user.


=head2 maps


=head2 maps_count
=head2 maps_info
=head2 maps_image
=head2 maps_image_source
=head2 real_time_localisation_for_client
=head2 real_time_localisation_for_client_count
=head2 real_time_localisation_for_tags
=head2 real_time_localisation_for_tags_count
=head2 real_time_localisation_for_rogueaps
=head2 real_time_localisation_for_rogueaps_count
=head2 real_time_localisation_for_rogueclients
=head2 real_time_localisation_for_rogueclients_count
=head2 real_time_localisation_for_interferers
=head2 real_time_localisation_for_interferers_count
=head2 localisation_history_for_client
=head2 localisation_history_for_client_count
=head2 localisation_history_for_tags
=head2 localisation_history_for_tags_count
=head2 localisation_history_for_rogueaps
=head2 localisation_history_for_rogueaps_count
=head2 localisation_history_for_rogueclients
=head2 localisation_history_for_rogueclients_count
=head2 localisation_history_for_interferers
=head2 localisation_history_for_interferers_count


=head1 LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>