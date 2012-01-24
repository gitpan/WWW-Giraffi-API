package WWW::Giraffi::API::Item;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.13';

sub all {

    my ( $self ) = @_;
    return $self->search;
}

sub search {

    my ( $self, $conditions ) = @_;
    return $self->get( "items.json", $conditions );
}

sub find {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "items/%s.json", $id ) );
}

sub find_service {

    my ( $self, $id, $conditions ) = @_;
    return $self->get( sprintf( "items/%s/services.json", $id ), $conditions );
}

sub find_agent {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "%s/items/%s/agent", $self->monitoringdata_endpoint, $id ) );
}

sub create {

    my ( $self, $conditions ) = @_;
    return $self->post( "items.json", undef, { item => $conditions } );
}

sub update {

    my ( $self, $id, $conditions ) = @_;
    return $self->put( sprintf("items/%s.json", $id), undef, { item => $conditions } );
}


sub destroy {

    my ( $self, $id ) = @_;
    return $self->delete( sprintf("items/%s.json", $id) );
}

sub reload {

    my ( $self, $id ) = @_;
    return $self->post("items/reload.json");
}

sub add_service {

    my ( $self, $id, $conditions ) = @_;
    return $self->post(sprintf("items/%s/services.json", $id), undef, { service => $conditions });
}

sub remove_service {

    my ( $self, $id, $service_id ) = @_;
    return $self->delete(sprintf("items/%s/services/%s.json", $id, $service_id));
}


1;

__END__

=head1 NAME

WWW::Giraffi::API::Item - Giraffi API Item Method Item Module

=head1 VERSION

0.13

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all item data
  my $arrayref = $g->item->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Item is Giraffi API Item Method Access Module

=head1 METHOD

=head2 all

Get All Item Setting

Example:

  $ create item object
  my $item = $g->item;
  my $arrayref = $item->all;

Return Array Reference:

  [
    {
      item => {
       warninginterval => 60,
       warningretry => 2,
       status => 1,
       ip => '127.0.0.1',
       name => 'Test Monitoring',
       allowcopy => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
       host => 'localhost',
       user_id => 16,
       id => 5,
       normalinterval => 120,
       customkey' => undef
      }
    }
  ]

=head2 search

Get Item Setting

Example:

  my $conditions = { 'name' => 'Test Monitoring' };
  my $arrayref = $item->search($conditions);

Return Array Reference:

  # only conditions match
  [
    {
      item => {
       warninginterval => 60,
       warningretry => 2,
       status => 1,
       ip => '127.0.0.1',
       name => 'Test Monitoring',
       allowcopy => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
       host => 'localhost',
       user_id => 16,
       id => 5,
       normalinterval => 120,
       customkey' => undef
      }
    }
  ]

=head2 find

Get One Item Setting

Example: 

  my $item_id = 1;
  my $ref = $item->find($item_id);

Return Reference:

  {
      item => {
       warninginterval => 60,
       warningretry => 2,
       status => 1,
       ip => '127.0.0.1',
       name => 'Test Monitoring',
       allowcopy => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
       host => 'localhost',
       user_id => 16,
       id => 5,
       normalinterval => 120,
       customkey' => undef
      }
  }

=head2 find_service

Get all services related to an item, specified by an item id parameter.

Example:

  my $item_id = 5;
  my $arrayref = $item->find_service($item_id);

Return Array Reference:

  [
    {
      service => {
          warninginterval => 60,
          options => {},
          warningretry => 2,
          status => 1,
          item_id => 5,
          id => 7,
          normalinterval => 120,
          servicetype => 'web_response_time'
      }
   }
 ]

=head2 find_agent

Downloads an agent (Shell script) that can collect and post system performance statistics from the specified host.

Example:

  my $item_id = 5;
  my $content = $item->find_agent($item_id);

$content is shell script string. see L<https://github.com/giraffi/giraffi/wiki/Giraffi-REST-API-Resources#wiki-get_items_item_id_agent>

=head2 create

Post Item Setting

Example:

  my $conditions = {
        name => 'Test Monitoring',
        host => "f00-196.238.145.203.fs-user.net",
        ip => "203.145.238.196",
        normalinterval => 120,
        warninginterval => 60,
        warningretry => 2,
        status => 1,
     };
  $item->create($conditions);

=head2 update

Update Item Setting

Example:

  my $item_id = 1;
  my $conditions = { name => 'Emergency Monitoring' };
  $item->update($item_id, $conditions);

=head2 destroy

Delete Item Setting

Example:

  my $item_id = 1;
  $item->delete($item_id);

=head2 add_service

Adds a new service to an item, specified by an item id parameter

Example:

  my $item_id = 2;
  my $service_conditions = {
      servicetype => "web_response_time",
      normalinterval => 120,
      warninginterval => 60,
      warningretry => 2,
      status => 1,
      options => {}
  };
  $item->add_service($item_id, $service_conditions);

=head2 remove_service

Deletes the specified service using the service id parameter from an item, specified by an item id parameter.

Example:

  my $item_id = 100;
  my $service_id = 2;
  $item->remove_service($item_id, $service_id);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
