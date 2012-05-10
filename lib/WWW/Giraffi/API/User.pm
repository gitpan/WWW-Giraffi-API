package WWW::Giraffi::API::User;

use strict;
use warnings;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.2_02';

sub create {

    my ( $self, $vendor_apikey ) = @_;
	### use low api ###
	# make request and replace apikey
	my $req = $self->make_request("POST", "users.json", undef, undef, { apikey => $vendor_apikey });
	#my %query_form = $req->uri->query_form;
	#$query_form{apikey} = $vendor_apikey;
	#$req->uri->query_form(%query_form);

	# return HTTP::Response
	my $res = $self->_request($req);
    return $self->_response2ref( $res );
}

sub update {

    my ( $self, $update_apikey ) = @_;
	my $req = $self->make_request("PUT", "users/apikey", undef, undef, { apikey => $update_apikey });
	my $res = $self->_request($req);
    return $self->_response2ref( $res );
}

sub destroy {

    my ( $self, $delete_apikey ) = @_;

	### use low api ###
	# make request and replace apikey
	my $req = $self->make_request("DELETE", "users.json", undef, undef, { apikey => $delete_apikey });
	#my %query_form = $req->uri->query_form;
	#$query_form{apikey} = $delete_apikey;
	#$req->uri->query_form(%query_form);

	# return HTTP::Response
	my $res = $self->_request($req);
    return $self->_response2ref( $res );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::User - Giraffi API User Method Access Module

=head1 VERSION

0.2_02

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);

  # create user
  my $my_vendor_apikey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  my $ref = $g->user->create($my_vendor_apikey);

=head1 DESCRIPTION

WWW::Giraffi::API::User is Giraffi API User Method Access Module

=head1 METHOD

=head2 create

Create User and Publish user apikey

Example:

  my $my_vendor_apikey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  $ create user object
  my $user = $g->user;
  my $ref = $user->create($my_vendor_apikey);

Return Reference:

  {
      'user' => {
                  'status' => 'enabled',
                  'permission' => 'wr',
                  'id' => 22,
                  'apikey' => 'new_user_apikey'
                }
    };

=head2 update

Update user apikey

Example:

  my $update_apikey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  $ create user object
  my $user = $g->user;
  $user->update($delete_apikey);

=head2 destroy

Delete user and apikey

Example:

  my $delete_apikey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  $ create user object
  my $user = $g->user;
  $user->destroy($delete_apikey);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
