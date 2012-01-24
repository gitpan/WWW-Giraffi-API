package WWW::Giraffi::API::MonitoringData;

use strict;
use warnings;
use Time::Piece;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.13';


sub search {
	# no test
    my ( $self, $conditions, $convert_time_piece ) = @_;
    my $arrayref = $self->get( "monitoringdata.json", $conditions );
	if ($convert_time_piece) {
		my $tmp_arrayref = [];
		foreach my $ref(@{$arrayref}) {
			$ref->{checked_at} = localtime($ref->{checked_at});
			$ref->{created_at} = localtime($ref->{created_at});
			push @{$tmp_arrayref}, $ref;
		}
		$arrayref = $tmp_arrayref;
	}
	return $arrayref;
}

sub create {
	# no test
    my ( $self, $conditions ) = @_;
    return $self->post( sprintf("%s/internal/nodelayed", $self->monitoringdata_endpoint), undef, { internal => $conditions } );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::MonitoringData - Giraffi API MonitoringData Method Module

=head1 VERSION

0.13

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get monitoringdata
  my $conditions = {};
  my $arrayref = $g->monitoringdata->search($conditions);
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::MonitoringData - Giraffi API MonitoringData Method Module

=head1 METHOD

=head2 search

Get MonitoringData Setting by conditions

Example:

  $ create monitoringdata object
  my $moniringdata = $g->monitoringdata;
  my $contidions = { service_id => 10 };
  my $arrayref = $moniringdata->search($conditions);

Return Array Reference:

  [
         {
            'alert' => $VAR1->[0]{'alert'},
            'job_id' => '6dbdd3b0-23fd-012f-14c4-2e7d4013ef81',
            'threshold' => [],
            'value' => '200',
            'checked_at' => 1326889516,
            '_id' => '4f16ba382325b42fa6007b80',
            'region' => 'JP',
            'service_id' => 10,
            'created_at' => 1326889528,
            'user_id' => 16,
            'servicetype' => 'web_response_code',
            'customkey' => undef
          }
  ]

unix timestamp will be changed into Time::Piece Object if 1 is passed to the 2nd argument. 

Example:

  my $convert_time_piece = 1;
  my $arrayref = $monitoring->search($conditions,$convert_time_piece);
  # created_at/checked_at is Time::Piece Object
  [
         {
            'alert' => $VAR1->[21]{'alert'},
            'job_id' => '8b5c4030-23fe-012f-14c4-2e7d4013ef81',
            'threshold' => [],
            'value' => '404',
            'checked_at' => bless( [
                                     16,
                                     32,
                                     21,
                                     18,
                                     0,
                                     '112',
                                     3,
                                     17,
                                     0,
                                     1326889936,
                                     1
                                   ], 'Time::Piece' ),
            '_id' => '4f16bc172325b42fa6007b8f',
            'region' => 'JP',
            'service_id' => 10,
            'created_at' => bless( [
                                     27,
                                     33,
                                     21,
                                     18,
                                     0,
                                     '112',
                                     3,
                                     17,
                                     0,
                                     1326890007,
                                     1
                                   ], 'Time::Piece' ),
            'user_id' => 16,
            'servicetype' => 'web_response_code',
            'customkey' => undef
          }
  ]

=head2 create

no test

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
