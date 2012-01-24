package WWW::Giraffi::API::Media;

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
    return $self->get( "media.json", $conditions );
}

sub find {

    my ( $self, $id ) = @_;
    return $self->get( sprintf( "media/%s.json", $id ) );
}

sub find_oauth {

	my($self, $id) = @_;
    return $self->get( sprintf( "media/%s/oauth.json", $id ) );
}

sub find_oauth_callback {

	my($self, $id, $oauth_verifier) = @_;
    return $self->get( sprintf( "media/%s/oauth_callback.json", $id ), { oauth_verifier => $oauth_verifier} );
}

sub create {

    my ( $self, $conditions ) = @_;
    return $self->post( "media.json", undef, { medium => $conditions } );
}

sub update {

    my ( $self, $id, $conditions ) = @_;
    return $self->put( sprintf("media/%s.json", $id), undef, { medium => $conditions } );
}

sub destroy {

    my ( $self, $id ) = @_;
    return $self->delete( sprintf("media/%s.json", $id) );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::Media - Giraffi API Media Method Access Module

=head1 VERSION

0.1

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all media data
  my $arrayref = $g->media->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Media is Giraffi API Media Method Access Module

=head1 METHOD

=head2 all

Get All Media Setting

Example:

  $ create media object
  my $media = $g->media;
  my $arrayref = $media->all;

Return Array Reference:

  [
    {
      'medium' => {
           'options' => {
                'address' => 'me@domain'
           },
          'mediumtype' => 'email',
          'name' => 'Alert Email',
          'user_id' => 1639,
          'id' => 556
       }
    }
  ]

=head2 search

Get Media Setting

Example:

  my $conditions = { 'name' => 'Alert Email' };
  my $arrayref = $media->search($conditions);

Return Array Reference:

  # only conditions match
  [
    {
      'medium' => {
           'options' => {
                'address' => 'me@domain'
           },
          'mediumtype' => 'email',
          'name' => 'Alert Email',
          'user_id' => 1639,
          'id' => 556
       }
    }
  ]

=head2 find

Get One Media Setting

Example: 

  my $media_id = 1;
  my $ref = $media->find($media_id);

Return Reference:

  {
    'medium' => {
         'options' => {
              'address' => 'me@domain'
         },
        'mediumtype' => 'email',
        'name' => 'Alert Email',
        'user_id' => 1639,
        'id' => 556
     }
  }


=head2 find_oauth

todo

=head2 find_oauth_callback

todo

=head2 create

Post Media Setting

Example:

  my $conditions = {
        options => {
              address => 'me@domain'
        },
        mediumtype => 'email',
        name => 'Alert Email',
     };
  $media->create($conditions);

=head2 update

Update Media Setting

Example:

  my $media_id = 1;
  my $conditions = {
        options => {
              address => 'you@domain'
        },
        mediumtype => 'email',
        name => 'Emergency Email',
     };
  $media->update($media_id, $conditions);

=head2 destroy

Delete Media Setting

Example:

  my $media_id = 1;
  $media->delete($media_id);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
