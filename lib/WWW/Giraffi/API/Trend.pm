package WWW::Giraffi::API::Trend;

use strict;
use warnings;
use Time::Piece;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.2_04';

sub search_average {

    my ( $self, $conditions, $other_options ) = @_;
    my $arrayref = $self->get( "trends/average.json", $conditions, $other_options );
	if ($self->use_time_piece) {
		my $tmp_arrayref = [];
		foreach my $ref(@{$arrayref}) {
			$ref->{checked_at} = localtime($ref->{checked_at});
			push @{$tmp_arrayref}, $ref;
		}
		$arrayref = $tmp_arrayref;
	}
	return $arrayref;
}

sub search_failure {

    my ( $self, $conditions, $other_options ) = @_;
    my $arrayref = $self->get( "trends/failure.json", $conditions, $other_options );
	if ($self->use_time_piece) {
		my $tmp_arrayref = [];
		foreach my $ref(@{$arrayref}) {
			$ref->{failed_start_at} = localtime($ref->{failed_start_at});
			$ref->{failed_end_at}   = localtime($ref->{failed_end_at});
			push @{$tmp_arrayref}, $ref;
		}
		$arrayref = $tmp_arrayref;
	}
	return $arrayref;
}


1;

__END__

=head1 NAME

WWW::Giraffi::API::Trend - Giraffi API Axion Trend Method Module

=head1 VERSION

0.2_04

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all trend data

  my $service_id = 9;
  my $service_type = "web_response_time";
  my $region   = "JP";
  my $interval = 600;
  my $conditions = {
      service_id => $service_id,
      servicetype => $service_type,
      region => "JP",
	  interval => $interval
  };
  my $arrayref = $g->trend->search_average($conditions);
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Trend - Giraffi API Trend Method Module

=head1 METHOD

=head2 search_average

Get average trend

Example:

  $ create trend object
  my $trend = $g->trend;
  my $service_id = 9;
  my $service_type = "web_response_time";
  my $region   = "JP";
  my $interval = 600; 600(10min)/1800(30min)/10800(3hour)/86400(1day)/259200(30day)
  my $conditions = {
    service_id         => $service_id,
    servicetype        => $service_type,
    # customekey       => $custome_key,
    region             => "JP",
    interval           => $interval,
    # from             => $from_timestamp,
    # to               => $to_timestamp,
  };
  my $arrayref = $trend->search_average($conditions);

Return Array Reference:

  [
     {
       min        => '0',
       value      => '0.00107158333333333',
       checked_at => '1326872400',
       max        => '0.002623'
     },
     {
       min        => '0',
       value      => '0.000458363636363636',
       checked_at => '1326873000',
       max        => '0.002521'
     }
  ]

unix timestamp will be changed into Time::Piece Object

Example:

  $trend->use_time_piece(1);
  my $arrayref = $trend->search_average($conditions);
  # checked_at is Time::Piece Object
  [
     {
       min        => '0',
       value      => '0.00107158333333333',
       checked_at => bless( [
                            15,
                            23,
                            17,
                            18,
                            0,
                            '112',
                            3,
                            17,
                            0,
                            1326874995,
                          1
                      ], 'Time::Piece' ),
       max        => '0.002623'
     },
  ]

=head2 search_failure

Get failure trend

Example:

  $ create trend object
  my $trend = $g->trend;
  my $service_id = 9;
  my $service_type = "web_response_time";
  my $region   = "JP";
  my $interval = 600; 600(10min)/1800(30min)/10800(3hour)/86400(1day)/259200(30day)
  my $conditions = {
    service_id         => $service_id,
    servicetype        => $service_type,
    # customekey       => $custome_key,
    region             => "JP",
    interval           => $interval,
    # from             => $from_timestamp,
    # to               => $to_timestamp,
  };
  my $arrayref = $trend->search_failure($conditions);

Return Array Reference:

  [
    {
      'failed_start_at' => 1326872055,
      '_id' => '4f16911a2325b41b8f000002',
      'region' => 'JP',
      'service_id' => 9,
      'tags' => [],
      'failed_time' => 780,
      'failed_end_at' => 1326872835,
      'user_id' => 16,
      'servicetype' => 'web_response_time',
      'customkey' => undef
    },
  ]

unix timestamp(failed_start_at/failed_end_at key) will be changed into Time::Piece Object. 

Example:

  $trend->use_time_piece(1);
  my $arrayref = $trend->search_failure($conditions);

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
