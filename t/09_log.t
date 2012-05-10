use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 11;
}


my $test_log =  {
           'executed_at' => 1332635474,
            'trigger_options' => {
                                   'time' => '3'
                                 },
            'threshold' => '3',
            'axion_name' => 'Aborted Alert',
            'service_options' => {},
            'ip' => '1.0.0.1',
            'checked_at' => 1332635456,
            '_id' => '4f6e67522325b433d4000021',
            'service_id' => 1,
            'created_at' => 1332635474,
            'axion_options' => {},
            'servicetype' => 'web_response_code',
            'job_id' => 'c0e9fed0-583f-012f-14d2-2e7d4013ef81',
            'value' => 'N/A',
            'region' => 'JP',
            'item_name' => 'Test Monitoring',
            'axionkind' => 'problem',
            'host' => 'test.priv',
            'medium_name' => [
                               'Alert Email'
                             ],
            'trigger_id' => 1,
            'axion_id' => 1,
            'user_id' => 1,
            'triggertype' => 'response',
            'customkey' => undef,
            'result' => "foo"
		};

my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					if ($req->uri->path =~ /\/logs\/axion\.json$/ ) {
						if ($req->uri->query =~ /triggertype=/) {
							# search
							my %query = $req->uri->query_form;
							if( $query{triggertype} eq $test_log->{triggertype}) {
								$response_ref = [ $test_log ];
							} else {
								$response_ref = [];
							}
						} else {
							# all
							$response_ref = [ $test_log ];
						}
					} elsif ($req->uri->path =~ /\/logs\/axion\/count\.json$/) {
						$response_ref = { content => 1 };
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $conditions = { triggertype => "response" };
my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->log->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{_id}, "4f6e67522325b433d4000021", "all return _id test");
isa_ok($all_arrayref->[0]->{executed_at}, "Time::Piece", "executed_at is Time::Piece object test");
isa_ok($all_arrayref->[0]->{created_at}, "Time::Piece", "created_at is Time::Piece object test");
isa_ok($all_arrayref->[0]->{checked_at}, "Time::Piece", "checked_at is Time::Piece object test");

my $search_arrayref = $g->log->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{_id}, "4f6e67522325b433d4000021", "search return _id test");

my $count_ref = $g->log->count;
is(ref($count_ref), "HASH", "count return reftype test");
is($count_ref->{content}, 1, "count return content test");
