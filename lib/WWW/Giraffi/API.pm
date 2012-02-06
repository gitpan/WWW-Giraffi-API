package WWW::Giraffi::API;
use strict;
use warnings;
use Class::XSAccessor
  constructor => "new",
  accessors   => {
    apikey                  => "apikey",
    timeout                 => "timeout",
    default_endpoint        => "default_endpoint",
    applogs_endpoint        => "applogs_endpoint",
    monitoringdata_endpoint => "monitoringdata_endpoint",
    verbose                 => "verbose",
    ssl_verify_hostname     => "ssl_verify_hostname",
    use_time_piece          => "use_time_piece",
  },
  #true    => [qw(verbose)],
  replace => 1;

#has apikey => ( is => "rw", isa => "Str" );
#has timeout => ( is => "rw", isa => "Num" );
#has verbose => ( is => "rw", isa => "Num" );
#has ssl_verify_hostname => ( is => "rw", isa => "Num");
use Module::Pluggable search_path => [__PACKAGE__];

our $VERSION                 = '0.13_02';
our $AGENT                   = sprintf "%s/%s", __PACKAGE__, $VERSION;
our $SSL_VERIFY_HOSTNAME     = 1;
our $TIMEOUT                 = 30;
our $USE_TIME_PIECE          = 1;
our $DEFAULT_ENDPOINT        = "https://papi.giraffi.jp";
our $MONITORINGDATA_ENDPOINT = "https://okapi.giraffi.jp:3007";
our $APPLOGS_ENDPOINT        = "https://lapi.giraffi.jp:3443";

sub import {

    my $class = shift;
    foreach my $pkg ( $class->plugins ) {
        next if $pkg eq "${class}::Request";
        $pkg =~ /^${class}::([a-zA-Z]+)$/;
        my $method = lc $1;

        no strict "refs";    ## no critic
        *{ __PACKAGE__ . "::$method" } = sub {
            my $self    = shift;
            my %options = (
                apikey                   => $self->apikey,
                agent                    => $AGENT,
                ssl_verify_hostname      => $self->ssl_verify_hostname // $SSL_VERIFY_HOSTNAME,
                use_time_piece           => $self->use_time_piece // $USE_TIME_PIECE,
                timeout                  => $self->timeout // $TIMEOUT,
                default_endpoint         => $self->default_endpoint // $DEFAULT_ENDPOINT,
                monitoringdata_endpoint  => $self->monitoringdata_endpoint // $MONITORINGDATA_ENDPOINT,
                applogs_endpoint         => $self->applogs_endpoint //$APPLOGS_ENDPOINT,
                verbose                  => $self->verbose,
            );
            return $self->_require_request_method( $pkg, %options );
        };
    }
}

{
    my %cached;    ## static hash

    sub _require_request_method {

        my ( $self, $pkg, %options ) = @_;
        ( my $file = $pkg ) =~ s/::/\//g;
        if ( !exists $cached{$pkg} ) {
            eval "require '$file.pm'" or die $@;    ## no critic
            $pkg->import;
            $cached{$pkg} = $pkg->new(%options);
        }
        return $cached{$pkg};
    }
}

1;
__END__

=head1 NAME

WWW::Giraffi::API - Giraffi API Access Module

=head1 VERSION

0.13_02

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all media data
  my $arrayref = $g->media->find;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API is Giraffi API Access Module

ruby giraffi https://github.com/giraffi/giraffi perl binding

=head1 GLOBAL VARIABLE

=head2 $AGENT

WWW::Giraffi::API/$VERSION

=head2 $SSL_VERIFY_HOSTNAME

for LWP::UserAgent ssl_opts(verify_hostname => $this_value). 1

=head2 $TIMEOUT

for LWP::UserAgent timeout. 30

=head2 $USE_TIME_PIECE

convert unix timestamp fields in json response to Time::Piece Object. default 1

=head2 $DEFAULT_ENDPOINT

https://papi.giraffi.jp

=head2 $MONITORINGDATA_ENDPOINT

https://okapi.giraffi.jp:3007

=head2 $APPLOGS_ENDPOINT

https://lapi.giraffi.jp:3443"

=head1 ACCESSOR METHOD

=head2 apikey

=head2 timeout

=head2 default_endpoint

=head2 applogs_endpoint

=head2 monitoringdata_endpoint

=head2 verbose

=head2 ssl_verify_hostname

=head2 use_time_piece

=head1 METHOD

=head2 new

Create WWW::Giraffi::API Object

Example:

  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);

Options

  apikey                    giraffi apikey
  timeout                   connection timeout. default 30sec 
  default_endpoint          default_endpoint. default $DEFAULT_ENDPOINT
  applogs_endpoint          applogs_endpoint. default $APPLOGS_ENDPOINT
  monitoringdata_endpoint   monitoringdata_endpoint. default $MONITORINGDATA_ENDPOINT
  verbose                   verbose output. default 0
  ssl_verify_hostname       ssl_verify_hostname(for LWP::UserAgent). default 1
  use_time_piece            use_time_piece. default $USE_TIME_PIECE

=head2 media

Create WWW::Giraffi::API::Media Object

Example:

  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  my $media = $g->media;

=head2 axion

Create WWW::Giraffi::API::Axion Object

Example:

  my $axion = $g->axion;

=head2 item

Create WWW::Giraffi::API::Item Object

Example:

  my $item = $g->item;

=head2 service

Create WWW::Giraffi::API::Service Object

Example:

  my $service = $g->service;

=head2 trigger

Create WWW::Giraffi::API::Trigger Object

Example:

  my $trigger = $g->trigger;

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 API REFERENCE

L<https://github.com/giraffi/giraffi/wiki>

=head1 SEE ALSO

L<Class::XSAccessor> L<Module::Pluggable>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
