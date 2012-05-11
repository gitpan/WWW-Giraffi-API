package WWW::Giraffi::API::Log;

use strict;
use warnings;
use Time::Piece;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.2_04';

sub all {

    my ( $self, $other_options ) = @_;
    return $self->search(undef, $other_options);
}

sub search {

    my ( $self, $conditions, $other_options ) = @_;
    my $arrayref = $self->get( "logs/axion.json", $conditions, $other_options );
	if ($self->use_time_piece) {
		my $tmp_arrayref = [];
		foreach my $ref(@{$arrayref}) {
			$ref->{executed_at} = localtime($ref->{executed_at});
			$ref->{created_at}  = localtime($ref->{created_at});
			$ref->{checked_at}  = localtime($ref->{checked_at});
			push @{$tmp_arrayref}, $ref;
		}
		$arrayref = $tmp_arrayref;
	}
	return $arrayref;
}

sub count {

    my ( $self, $conditions, $other_options ) = @_;
    return $self->get( "logs/axion/count.json", $conditions, $other_options );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::Log - Giraffi API Axion Log Method Module

=head1 VERSION

0.2_04

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get all log data
  my $arrayref = $g->log->all;
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::Log - Giraffi API Axion Log Method Module

=head1 METHOD

=head2 all

Get All Log 

Example:

  $ create axion log object
  my $log = $g->log;
  my $contidions = {};
  my $arrayref = $log->all;

Return Array Reference:

  [
          {
            'executed_at' => 1326874892,
            'trigger_options' => {
                                   'time' => '3'
                                 },
            'threshold' => '3',
            'axion_name' => 'Aborted Alert',
            'service_options' => {},
            'ip' => '203.145.238.196',
            'checked_at' => 1326874875,
            '_id' => '4f16810c63051f2d4b0000b2',
            'service_id' => 9,
            'created_at' => 1326874892,
            'axion_options' => {},
            'servicetype' => 'web_response_time',
            'job_id' => '5a2645b0-23db-012f-534e-425df6515049',
            'value' => 'N/A',
            'region' => 'JP',
            'item_name' => 'Test Monitoring',
            'axionkind' => 'problem',
            'host' => 'f00-196.238.145.203.fs-user.net',
            'medium_name' => [
                               'Alert Email'
                             ],
            'trigger_id' => 6,
            'axion_id' => 4,
            'user_id' => 16,
            'triggertype' => 'timeout',
            'customkey' => undef,
            'result' => $VAR1->[0]{'result'}
          }
  ]

unix timestamp will be changed into Time::Piece Object.

Example:

  $log->use_time_piece(1);
  my $arrayref = $log->all;
  # created_at/checked_at/executed_at is Time::Piece Object
  [
          {
            'medium_name' => [
                               'Alert Email',
                               'Alert Email',
                               'Alert Email'
                             ],
            'executed_at' => bless( [
                                      44,
                                      4,
                                      22,
                                      13,
                                      0,
                                      '112',
                                      5,
                                      12,
                                      0,
                                      1326459884,
                                      1
                                    ], 'Time::Piece' ),
            'created_at' => bless( [
                                     44,
                                     4,
                                     22,
                                     13,
                                     0,
                                     '112',
                                     5,
                                     12,
                                     0,
                                     1326459884,
                                     1
                                   ], 'Time::Piece' ),
            'axion_name' => 'Aborted Alert',
            'checked_at' => bless( [
                                     44,
                                     4,
                                     22,
                                     13,
                                     0,
                                     '112',
                                     5,
                                     12,
                                     0,
                                     1326459884,
                                     1
                                   ], 'Time::Piece' ),
            'axion_id' => 4,
            '_id' => '4f102bec63051f2d48000004',
            'axion_options' => {},
            'user_id' => 16,
            'result' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' )
          },

  ]


=head2 search

Get Log Setting by conditions

Example:

  $ create axion log object
  my $log = $g->log;
  my $contidions = { job_id => "5a2645b0-23db-012f-534e-425df6515049" };
  my $arrayref = $log->search($conditions);

Return Array Reference:

  [
          {
            'executed_at' => 1326874892,
            'trigger_options' => {
                                   'time' => '3'
                                 },
            'threshold' => '3',
            'axion_name' => 'Aborted Alert',
            'service_options' => {},
            'ip' => '203.145.238.196',
            'checked_at' => 1326874875,
            '_id' => '4f16810c63051f2d4b0000b2',
            'service_id' => 9,
            'created_at' => 1326874892,
            'axion_options' => {},
            'servicetype' => 'web_response_time',
            'job_id' => '5a2645b0-23db-012f-534e-425df6515049',
            'value' => 'N/A',
            'region' => 'JP',
            'item_name' => 'Test Monitoring',
            'axionkind' => 'problem',
            'host' => 'f00-196.238.145.203.fs-user.net',
            'medium_name' => [
                               'Alert Email'
                             ],
            'trigger_id' => 6,
            'axion_id' => 4,
            'user_id' => 16,
            'triggertype' => 'timeout',
            'customkey' => undef,
            'result' => $VAR1->[0]{'result'}
          }
  ]

unix timestamp will be changed into Time::Piece Object.
convert field is same as all method result 

Example:

  $log->use_time_piece(1);
  my $arrayref = $log->search($conditions);

=head2 count

Get Log Setting count by conditions

Example:

  $ create axion log object
  my $log = $g->log;
  my $contidions = { job_id => "5a2645b0-23db-012f-534e-425df6515049" };
  my $ref = $log->count($conditions);


Return Array Reference:

  {
    content => 20
  }

=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

