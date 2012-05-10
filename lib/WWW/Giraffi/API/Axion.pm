package WWW::Giraffi::API::Axion;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.2_01';

sub all {

    my ( $self, $other_options ) = @_;
    return $self->search(undef, $other_options);
}

sub search {

    my ( $self, $conditions, $other_options ) = @_;
    return $self->get( "axions.json", $conditions, $other_options );
}

sub find {

    my ( $self, $id, $other_options ) = @_;
    return $self->get( sprintf( "axions/%s.json", $id ), undef, $other_options );
}

sub find_media {

    my ( $self, $id, $conditions, $other_options ) = @_;
    return $self->get( sprintf( "axions/%s/media.json", $id ), $conditions, $other_options );
}


sub create {

    my ( $self, $conditions, $other_options ) = @_;
    return $self->post( "axions.json", undef, { axion => $conditions }, $other_options );
}

sub exec {

    my ( $self, $id, $other_options ) = @_;
    return $self->post( sprintf("axions/%s/execute.json", $id), undef, undef, $other_options );
}

sub update {

    my ( $self, $id, $conditions, $other_options ) = @_;
    return $self->put( sprintf("axions/%s.json", $id), undef, { axion => $conditions }, $other_options );
}

sub destroy {

    my ( $self, $id, $other_options ) = @_;
    return $self->delete( sprintf("axions/%s.json", $id), undef, undef, $other_options );
}

sub add_media {

    my ( $self, $id, $media_id, $other_options ) = @_;
    return $self->put( sprintf("axions/%s/media/%s.json", $id, $media_id), undef, {}, $other_options );
}

sub remove_media {

    my ( $self, $id, $media_id, $other_options ) = @_;
    return $self->delete( sprintf("axions/%s/media/%s.json", $id, $media_id), undef, undef, $other_options );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::Axion - Giraffi API Axion Method Axion Module

=head1 VERSION

0.2_01

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all axion data
  my $arrayref = $g->axion->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Axion is Giraffi API Axion Method Access Module

=head1 METHOD

=head2 all

Get All Axion Setting

Example:

  $ create axion object
  my $axion = $g->axion;
  my $arrayref = $axion->all;

Return Array Reference:

  [
    {
      'axion' => {
           'options' => {},
           'name' => 'Aborted Alert',
           'axiontype' => 'messaging',
           'user_id' => 16,
           'id' => 2
       }
    }
  ]

=head2 search

Get Axion Setting

Example:

  my $conditions = { 'name' => 'Aborted Alert' };
  my $arrayref = $axion->search($conditions);

Return Array Reference:

  # only conditions match
  [
    {
      'axion' => {
           'options' => {},
           'name' => 'Aborted Alert',
           'axiontype' => 'messaging',
           'user_id' => 16,
           'id' => 2
       }
    }
  ]

=head2 find

Get One Axion Setting

Example: 

  my $axion_id = 1;
  my $ref = $axion->find($axion_id);

Return Reference:

  {
    'axion' => {
         'options' => {},
         'name' => 'Aborted Alert',
         'axiontype' => 'messaging',
         'user_id' => 16,
         'id' => 1 
     }
  }

=head2 find_media
Get all media related to an axion, specified by an axion id parameter

Example:

  my $axion_id = 1;
  my $arrayref = $axion->find_media($axion_id);

Return Array Reference:

  # media by add_media_by_id
  [
    {
      medium => {
             options => {
                  'address' => 'me@domain'
              },
              mediumtype => 'email',
              name => 'Alert Email',
              user_id => 16,
              id => 5
      }
    }
  ]

=head2 create

Post Axion Setting

Example:

  # axiontype is "messaging"
  my $conditions = {
        axiontype => "messaging",
        name => 'Aborted alert',
     };
  
  # axiontype is "http_request"
  my $conditions = {
        axiontype => "http_request",
        name => 'Aborted alert post request',
        options => {
          header => {
            "content-type" => "application/x-www-form-urlencoded",
            Authorization => "Basic ****"
          },
          uri => "https://convore.com/api/topics/19099/messages/create.json",
          method => "post",
          body => {
            message => "Aborted alert post message by API"
          }
        }
     };
  $axion->create($conditions);

=head2 exec

Execute Axion. add_media_by_id method is executed in advance

Example:

  my $axion_id = 1;
  $axion->exec($axion_id);

=head2 update

Update Axion Setting

Example:

  my $axion_id = 1;
  my $conditions = { name => 'Emergency Axion' };
  $axion->update($axion_id, $conditions);

=head2 destroy

Delete Axion Setting

Example:

  my $axion_id = 1;
  $axion->delete($axion_id);

=head2 add_media

Adds the specified media using the media id parameter to an axion, specified by an axion id parameter

Example:

  my $media_id = 100;
  my $axion_id = 2;
  $axion->add_media($axion_id, $media_id);

=head2 remove_media

Deletes the specified medium using the medium id parameter from an axion, specified by an axion id parameter

Example:

  my $media_id = 100;
  my $axion_id = 2;
  $axion->remove_media($axion_id, $media_id);


=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

