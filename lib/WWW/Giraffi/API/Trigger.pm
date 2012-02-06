package WWW::Giraffi::API::Trigger;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.13_01';

sub all {

    my ( $self ) = @_;
    return $self->search;
}

sub search {

    my ( $self, $conditions ) = @_;
    return $self->get( "triggers.json", $conditions );
}

sub find {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "triggers/%s.json", $id ) );
}

sub find_axion {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "triggers/%s/axions.json", $id ) );
}

sub exec_axion {

    my ( $self, $id ) = @_;
    return $self->post( sprintf( "triggers/%s/axions/execute.json", $id ) );
}

sub update {

    my ( $self, $id, $conditions ) = @_;
    return $self->put( sprintf("triggers/%s.json", $id), undef, { trigger => $conditions } );
}

sub update_axion {

	# $axion_kind is problem or recovery
    my ( $self, $id, $axion_id, $axion_kind ) = @_;
    return $self->put( sprintf("triggers/%s/axions/%s.json", $id, $axion_id), undef, { axionkind => $axion_kind } );
}

sub destroy {

    my ( $self, $id ) = @_;
    return $self->delete( sprintf("triggers/%s.json", $id) );
}

sub remove_axion {

    my ( $self, $id, $axion_id, $axion_kind ) = @_;
    return $self->delete( sprintf("triggers/%s/axions/%s.json", $id, $axion_id ), undef, { axionkind => $axion_kind } );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::Trigger - Giraffi API Trigger Method Trigger Module

=head1 VERSION

0.13_01

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all trigger data
  my $arrayref = $g->trigger->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Trigger is Giraffi API Trigger Method Access Module

=head1 METHOD

=head2 all

Get All Trigger Setting

Example:

  $ create trigger object
  my $trigger = $g->trigger;
  my $arrayref = $trigger->all;

Return Array Reference:

  [
    {
      trigger => {
           axioninterval => 180,
           level => 0,
           options => { time' => 3 },
           triggertype => 'timeout',
           service_id => 9,
           id => 5
      }
    }
  ]

=head2 search

Get Trigger Setting

Example:

  my $conditions = { 'triggertype' => 'timeout' };
  my $arrayref = $trigger->search($conditions);

Return Array Reference:

  # only conditions match
  [
    {
      trigger => {
           axioninterval => 180,
           level => 0,
           options => { time' => 3 },
           triggertype => 'timeout',
           service_id => 9,
           id => 5
      }
    }
  ]

=head2 find

Get One Trigger Setting

Example: 

  my $trigger_id = 1;
  my $ref = $trigger->find($trigger_id);

Return Reference:

  {
    trigger => {
         axioninterval => 180,
         level => 0,
         options => { time' => 3 },
         triggertype => 'timeout',
         service_id => 9,
         id => 5
    }
  }

=head2 find_axion

Get all axions related to an trigger, specified by an trigger id parameter.

Example: 

  my $trigger_id = 5;
  my $arrayref = $service->find_axion($trigger_id);

Return Array Reference:

  [
    {
      axion => {
          options => {},
          name => 'Aborted Alert',
          axiontype => 'messaging',
          user_id => 16,
          id => 4
        }
    }
  ] 

=head2 exec_axion

Execute axion related to an trigger, specified by an trigger id parameter.

Example:

  $trigger_id = 5;
  $trigger->exec_axion($trigger_id);

=head2 update

Update Trigger Setting

Example:

  my $trigger_id = 5;
  my $conditions = { options => { timeout => 10 } };
  $trigger->update($trigger_id, $conditions);

=head2 update_axion

Update the specified axion using the axion id/axion kind parameter from an trigger, specified by an trigger id parameter.

Example:

  my $trigger_id = 5;
  my $axion_id = 1;
  my $axion_kind = "problem"; # problem or recovery
  $service->update_axion($trigger_id, $axion_id, $axion_kind);


=head2 destroy

Delete Trigger Setting

Example:

  my $trigger_id = 5;
  $trigger->delete($trigger_id);

=head2 remove_axion

Deletes the specified axion using the axion id/axion kind parameter from an trigger, specified by an trigger id parameter.

Example:

  my $trigger_id = 5;
  my $axion_id = 1;
  my $axion_kind = "problem"; # problem or recovery
  $service->remove_trigger($trigger_id, $axion_id, $axion_kind);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
