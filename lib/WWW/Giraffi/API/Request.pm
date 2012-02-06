package WWW::Giraffi::API::Request;

use strict;
use warnings;
use 5.10.0;
use Class::XSAccessor
  constructor => "new",
  accessors   => {
    apikey                  => "apikey",
    agent                   => "agent",
    ssl_verify_hostname     => "ssl_verify_hostname",
    use_time_piece          => "use_time_piece",
    timeout                 => "timeout",
    default_endpoint        => "default_endpoint",
    applogs_endpoint        => "applogs_endpoint",
    monitoringdata_endpoint => "monitoringdata_endpoint",
    verbose                 => "verbose",
	last_request            => "last_request",
	last_response           => "last_response",
  },
  #true    => [qw(verbose)],
  replace => 1;
use JSON::Any;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI;

our $VERSION         = '0.13_01';
our %REQUEST_HEADERS = (
    "Accept"       => "application/json",
    "Content-Type" => "application/json"
);
our $CLIENT_TIMEOUT_DELAY = 2;
our $CLIENT_TIMEOUT_CODE  = 408;

#has apikey               => ( is => "rw", isa => "Str" );
#has agent                => ( is => "rw", isa => "Str" );
#has ssl_verify_hostname  => ( is => "rw", isa => "Num");
#has timeout              => ( is => "rw", isa => "Num" );
#has default_endpoint     => ( is => "rw", isa => "Str" );
#has applogs_endpoint     => ( is => "rw", isa => "Str" );
#has monitoringdata_endpoint  => ( is => "rw", isa => "Str" );
#has verbose              => ( is => "rw", isa => "Num" );

sub get {

    my ( $self, $path_or_uri, $queryref ) = @_;
    my $res = $self->request( "GET", $path_or_uri, $queryref );
	#return $self->_json2ref( $res->content );
    return $self->_response2ref( $res );
}

sub post {

    my ( $self, $path_or_uri, $queryref, $contentref ) = @_;
    my $res = $self->request( "POST", $path_or_uri, $queryref, $contentref );
	#return $self->_json2ref( $res->content );
    return $self->_response2ref( $res );
}

sub put {

    my ( $self, $path_or_uri, $queryref, $contentref ) = @_;
    my $res = $self->request( "PUT", $path_or_uri, $queryref, $contentref );
	#return $self->_json2ref( $res->content );
    return $self->_response2ref( $res );
}

sub delete {

    my ( $self, $path_or_uri, $queryref, $contentref ) = @_;
    my $res = $self->request( "DELETE", $path_or_uri, $queryref, $contentref );
	#return $self->_json2ref( $res->content );
    return $self->_response2ref( $res );
}

sub request {

    my ( $self, $method, $path_or_uri, $queryref, $contentref ) = @_;

    my $ua = LWP::UserAgent->new( agent => $self->agent, timeout => $self->timeout );
    if ( !$self->ssl_verify_hostname ) {
        $ua->ssl_opts( verify_hostname => 0 );
    }
    my $req = $self->make_request( $method, $path_or_uri, $queryref, $contentref );
    $self->_verbose( sprintf "request request_line %s => %s", $req->method, $req->uri );
	if ($req->content) {
	   $self->_verbose( sprintf "request content => %s", $req->content );
	}

    my $res;
    my $is_client_timeout;
    eval {
        local $SIG{ALRM} = sub { $is_client_timeout = 1 };
        alarm $self->timeout + $CLIENT_TIMEOUT_DELAY;
		$self->last_request($req);
        $res = $ua->request($req);
        alarm 0;
    };
    if ($is_client_timeout) {
        $res = $self->make_response( $CLIENT_TIMEOUT_CODE, { error => "alarm timeout" } );
    }
	$self->last_response($res);

    $self->_verbose( sprintf "response status_line => %s", $res->status_line );

    return $res;
}

sub make_request {

    my($self, $method, $path_or_uri, $queryref, $contentref) = @_;
    my $req = HTTP::Request->new( $method => $self->_make_uri( $path_or_uri, $queryref ) );
    if ( $req->method =~ /^(POST|PUT|DELETE)$/ && ref($contentref) =~ /^(ARRAY|HASH)$/ ) {
        $req->header(%REQUEST_HEADERS);
        $req->content( $self->_ref2json($contentref) );
    }
    return $req;
}

sub make_response {

    my ( $self, $code, $message, $json ) = @_;
    $json //= $self->_ref2json($message);
    return HTTP::Response->new( $code, $message,
        [ "Content-Type" => "application/json" ], $json );
}

sub _json2ref {

    my ( $self, $json ) = @_;
	#my $ref;
	#eval {
	#	$ref = JSON::Any->new->decode($json);
	#};
	#if ($@) {
	#	$ref = JSON::Any->new->decode("{'error':'$json'}");
	#}
	#return $ref;
	return JSON::Any->new->decode($json);
}

sub _ref2json {

    my ( $self, $ref ) = @_;
	#my $json;
	#eval {
	#	$json = JSON::Any->new->encode($ref);
	#};
	#if ($@) {
	#	$json = JSON::Any->new->encode({ error => $ref });
	#}
	#return $json;
	return JSON::Any->new->encode($ref);
}

sub _response2ref {

	my( $self, $res ) = @_;
	my $ref;
	if ($self->_is_json($res->content)) {
		$ref = $self->_json2ref($res->content);
	} else {
		if ($res->code =~ /^2\d{2}$/) { # if  normal http success code
			$ref = { content => $res->content };
		} else {
			$ref = { error => $res->status_line };
		}
	}

	return $ref;
}

sub _is_json {

	my($self, $json) = @_;
	return ($json =~ /^\{.*\}$/ or $json =~ /^\[.*\]$/) ? 1 : 0;
}

sub _verbose {

    my ( $self, $message ) = @_;
    return if !$self->verbose;
    warn "VERBOSE: $message\n";
}

sub _make_uri {

    my ( $self, $path_or_uri, $queryref ) = @_;

    $queryref //= {};
    if ( $path_or_uri !~ /^https?:\/\// ) {
        $path_or_uri = sprintf "%s/%s", $self->default_endpoint, $path_or_uri;
    }

    my $uri = URI->new($path_or_uri);
    $uri->query_form( [ apikey => $self->apikey, %{$queryref} ] );
    return $uri;
}

1;
__END__

=head1 NAME

WWW::Giraffi::API::Request - Giraffi API Access Request Base Module

=head1 VERSION

0.13_01

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API::Request;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all media data
  my $arrayref = $g->media->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Request is Giraffi API Access Request Base Module

Axion/Item/Media/Service/Trigger Base Module

=head1 GLOBAL VARIABLE

=head2 %REQUEST_HEADERS 

request headers hash

  (
    "Accept"       => "application/json",
    "Content-Type" => "application/json"
  )

=head2 $CLIENT_TIMEOUT_DELAY

2;

=head2 $CLIENT_TIMEOUT_CODE

408;

=head1 ACCESSOR METHOD

=head2 apikey

=head2 agent

=head2 ssl_verify_hostname

=head2 timeout

=head2 default_endpoint

=head2 applogs_endpoint

=head2 monitoringdata_endpoint

=head2 last_request

=head2 last_response

=head2 verbose

=head1 METHOD

=head2 get

Request GET method. request method wrapper

Example:

  # $ref is hash or array reference
  my $path_or_uri = "media.json";
  my $queryref = { name => "Alert Email" };
  my $ref = $req->get($path_or_uri, $queryref);

=head2 post

Request POST method. request method wrapper

Example:

  # $ref is hash or array reference
  my $path_or_uri = "media.json";
  my $queryref = {};
  my $contentref = { 
              options' => { address => "me@domain" },
              mediumtype => 'email',
              name => 'Alert Email',
           };
  my $ref = $req->post($path_or_uri, $queryref, $contentref);

=head2 put

Request PUT method. request method wrapper

Example:

  # $ref is hash or array reference
  my $path_or_uri = "media/1.json";
  my $queryref = {};
  my $contentref = { 
              mediumtype => 'twitter',
              name => 'Emergency Email',
           };
  my $ref = $req->put($path_or_uri, $queryref, $contentref);

=head2 delete

Request DELETE method. request method wrapper

Example:

  # $ref is hash or array reference
  my $path_or_uri = "media/1.json";
  my $queryref = {};
  my $contentref = {};
  my $ref = $req->delete($path_or_uri, $queryref, $contentref);

=head2 request

GET/POST/PUT/DELETE low layer request method

Example:

  my $path_or_uri = "media/1.json";
  my $queryref = {};
  my $contentref = { 
              mediumtype => 'twitter',
              name => 'Emergency Email',
           };
  # $res is HTTP::Response Object
  my $res = $req->request("PUT", $path_or_uri, $queryref, $contentref);


=head2 make_request

Create HTTP::Request Object. using internal request method

Example:

  my $path_or_uri = "media.json";
  my $queryref = { name => "Alert Email" };
  my $contentref = {};
  # $req is HTTP::Request Object
  my $res = $req->make_request("GET", $path_or_uri, $queryref, $contentref);

=head2 make_response

Create HTTP::Response Object. using internal request method

Example:

  # $res is HTTP::Response Object
  my $code = 500;
  my $message = "internal server error";
  my $json = JSON::Any->new->encode({ error => $message });
  my $res = $req->make_response($code, $message, $json);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 SEE ALSO

L<Class::XSAccessor> L<Crypt::SSLeay> L<JSON::Any> L<LWP::Protocol::https>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
