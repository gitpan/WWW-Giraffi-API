package WWW::Giraffi::API::Region;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.13_02';

sub all {

    my ( $self ) = @_;
    return $self->get( "regions.json" );
}

#sub search {

#    my ( $self, $conditions ) = @_;
#    return $self->get( "regions.json", $conditions );
#}

#sub find {

#    my ( $self, $id ) = @_;
#    return $self->get( sprintf( "regions/%s.json", $id ) );
#}

1;

__END__

=head1 NAME

WWW::Giraffi::API::Region - Giraffi API Region Method Region Module

=head1 VERSION

0.13_02

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all region data
  my $arrayref = $g->region->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Region is Giraffi API Region Method Access Module

=head1 METHOD

=head2 all

Get All Region Setting

Example:

  $ create region object
  my $region = $g->region;
  my $arrayref = $region->all;

Return Array Reference:

  [
    {
      region => {
           id => 1,
		   code => "JP"
       }
    }
  ]

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

