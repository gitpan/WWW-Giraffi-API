package WWW::Giraffi::API::Service;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.1';

sub all {

    my ( $self ) = @_;
    return $self->search;
}

sub search {

    my ( $self, $conditions ) = @_;
    return $self->get( "services.json", $conditions );
}

sub find {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "services/%s.json", $id ) );
}

sub find_region {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "services/%s/regions.json", $id ) );
}

sub find_trigger {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "services/%s/triggers.json", $id ) );
}

sub update {

    my ( $self, $id, $conditions ) = @_;
    return $self->put( sprintf("services/%s.json", $id), undef, { service => $conditions } );
}

sub update_region {

    my ( $self, $id, $region_code ) = @_;
    return $self->put( sprintf("services/%s/regions/%s.json", $id, $region_code), undef, {} );
}

sub destroy {

    my ( $self, $id ) = @_;
    return $self->delete( sprintf("services/%s.json", $id) );
}

sub add_trigger {

    my ( $self, $id, $conditions ) = @_;
    return $self->post( sprintf("services/%s/triggers.json", $id), undef, { trigger => $conditions } );
}

sub remove_trigger {

    my ( $self, $id, $trigger_id ) = @_;
    return $self->delete( sprintf("services/%s/triggers/%s.json", $id, $trigger_id) );
}
1;

__END__

=head1 NAME

WWW::Giraffi::API::Service - Giraffi API Service Method Service Module

=head1 VERSION

0.1

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all service data
  my $arrayref = $g->service->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Service is Giraffi API Service Method Access Module

=head1 METHOD

=head2 all

Get All Service Setting

Example:

  $ create service object
  my $service = $g->service;
  my $arrayref = $service->all;

Return Array Reference:

  [
    {
      service => {
          warninginterval => 60,
          options         => {},
          warningretry    => 2,
          status          => 1,
          item_id         => 5,
          id              => 7,
          normalinterval  => 120,
          servicetype     => 'web_response_time'
      }
    }
  ]

=head2 search

Get Service Setting

Example:

  my $conditions = { 'name' => 'Test Monitoring' };
  my $arrayref = $service->search($conditions);

Return Array Reference:

  # only conditions match
  [
    {
      service => {
          warninginterval => 60,
          options         => {},
          warningretry    => 2,
          status          => 1,
          item_id         => 5,
          id              => 7,
          normalinterval  => 120,
          servicetype     => 'web_response_time'
      }
    }
  ]

=head2 find

Get One Service Setting

Example: 

  my $service_id = 1;
  my $ref = $service->find($service_id);

Return Reference:

   {
      service => {
          warninginterval => 60,
          options         => {},
          warningretry    => 2,
          status          => 1,
          item_id         => 5,
          id              => 7,
          normalinterval  => 120,
          servicetype     => 'web_response_time'
      }

=head2 find_region

Get all regions related to an service, specified by an service id parameter.

Example: 

  my $service_id = 7;
  my $arrayref = $service->find_region($service_id);

Return Array Reference:

  [
   {
      region => {
          id   => 1,
		  code => "JP"
      }
   }
 ]

=head2 find_trigger

Get all triggers related to an service, specified by an service id parameter.

Example: 

  my $service_id = 7;
  my $arrayref = $service->find_trigger($service_id);

Return Array Reference:

  [
   {
      trigger => {
          axioninterval => 180,
          level => 0,
          options => {
                time => '3'
          },
          triggertype => 'timeout',
          service_id => 9,
          id => 4
      }
   }
 ] 

=head2 update

Update Service Setting

Example:

  my $service_id = 5;
  my $conditions = { status => 2 };
  $service->update($service_id, $conditions);

=head2 update_region

Update regions related to an service, specified by an service id parameter.

Example:

  my $service_id = 5;
  my $region_code = "JP";
  $service->update_region($service_id, $region_code);

=head2 destroy

Delete Service Setting

Example:

  my $service_id = 5;
  $service->delete($service_id);


=head2 add_trigger

Adds a new trigger to an service, specified by an service id parameter

Example:

  my $service_id = 5;
  my $trigger_conditions = {
      triggertype   => "timeout",
      axioninterval => 180,
      options       => { time => "3" }
  };
  my $ref = $service->add_trigger($service_id, $trigger_conditions);

Return Reference:

  {
    trigger => {
       axioninterval => 180,
       level => 0,
       options => {
           time => '3'
       },
       triggertype => 'timeout',
       service_id => 9,
       id => 4
     }
   }

=head2 remove_trigger

Deletes the specified trigger using the trigger id parameter from an service, specified by an service id parameter.

Example:

  my $service_id = 5;
  my $trigger_id = 4;
  $service->remove_trigger($service_id, $trigger_id);


=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
