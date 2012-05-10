package WWW::Giraffi::API::AppLog;

use strict;
use warnings;
use Time::Piece;

use parent qw(WWW::Giraffi::API::Request);

our $VERSION = '0.2_02';

# this method has not been tested
sub all {

    my ( $self, $other_options ) = @_;
	return $self->search(undef, $other_options);
}

# this method has not been tested
sub search {
	# no test
    my ( $self, $conditions, $other_options ) = @_;
    my $arrayref = $self->get( "applogs.json", $conditions, $other_options );
    if ($self->use_time_piece) {
        my $tmp_arrayref = [];
        foreach my $ref(@{$arrayref}) {
            $ref->{applog}->{time} = localtime($ref->{applog}->{time});
            push @{$tmp_arrayref}, $ref;
        }
        $arrayref = $tmp_arrayref;
    }
	return $arrayref;
}

# this method has not been tested
sub create {

    my ( $self, $conditions, $other_options ) = @_;
    return $self->post( sprintf("%s/applogs.json", $self->applogs_endpoint), undef, { applog => $conditions }, $other_options );
}

1;

__END__

=head1 NAME

WWW::Giraffi::API::AppLog - Giraffi API AppLog Method Module

=head1 VERSION

0.2_02

=head1 SYNOPSIS

  use strict;
  use warnings;
  use WWW::Giraffi::API;
  
  my $apikey = "ilovenirvana_ilovekurtcobain";
  my $g = WWW::Giraffi::API->new(apikey => $apikey);
  # get applog
  my $conditions = { type => "app" };
  my $arrayref = $g->applog->search($conditions);
  foreach $ref(@{$arrayref}) {
      ## anything to do...
  }

=head1 DESCRIPTION

WWW::Giraffi::API::AppLog - Giraffi API AppLog Method Module

=head1 METHOD

=head2 all

Get All AppLog 

Example:

  $ create applog object
  my $applog = $g->applog;
  my $arrayref = $applog->all;

Return Array Reference:

  [
    applog => {
            'level' => 'info',
            'time' => '1326942906',
            'type' => 'app',
            'id' => '4f178abb2325b42dc7000002',
            'message' => 'hello world'
     }
  ]

unix timestamp will be changed into Time::Piece Object.

Example:

  $applog->use_time_piece(1);
  my $arrayref = $applog->all;
  # time is Time::Piece Object
  [
    {
      applog => {
                    'level' => 'info',
                    'time' => bless( [
                                           32,
                                           16,
                                           12,
                                           19,
                                           0,
                                           '112',
                                           4,
                                           18,
                                           0,
                                           '1326942992',
                                           1
                                         ], 'Time::Piece' ),
                      'type' => 'app',
                      'id' => '4f178b122325b42dd9000001',
                      'message' => 'hello world yaho'
                    }
        }
  ]


=head2 search

Get AppLog by conditions

Example:

  my $moniringdata = $g->applog;
  my $contidions = { level => "info" };
  my $arrayref = $applog->search($conditions);

Return Array Reference:

  [
    applog => {
            'level' => 'info',
            'time' => '1326942906',
            'type' => 'app',
            'id' => '4f178abb2325b42dc7000002',
            'message' => 'hello world'
     }
  ]

unix timestamp will be changed into Time::Piece Object.

Example:

  $applog->use_time_piece(1);
  my $arrayref = $applog->search($conditions);

=head2 create

Post AppLog

Example:

  my $conditions = {
        type => "poppo",
        level => "info",
        time => time,
        message => "poppoppo",
     };
  $g->applog->create($conditions);


=head1 AUTHOR

Akira Horimoto E<lt>emperor@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
