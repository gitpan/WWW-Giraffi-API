use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 12;
}


my $test_monitoringdata =  {
	alert       => 0,
	job_id      => 'b0994f80-7c76-012f-14e7-2e7d4013ef81',
	compared_at => 1336617311,
	threshold   => [ 3 ],
	value       => 1,
	checked_at  => 1336617301,
	_id         => "4fab295f2325b4731b00d933",
	region      => "JP",
	service_id  => 1,
	tags        => [
					'1.0.0.1',
					'00:00:00:00:00:00',
					'test.priv'
					],
	created_at  => 1336617311,
	user_id     => 180,
	servicetype => 'web_response_time',
	customkey   => undef,
};

my $monitoringdata_id = "4fab295f2325b4731b00d939";
my $monitoringdata_job_id = "b0994f80-7c76-012f-14e7-2e7d4013ef82";


my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					if ($req->uri->path =~ /\/monitoringdata\.json$/ ) {
						if ($req->uri->query =~ /service_id=/) {
							my %query = $req->uri->query_form;
							if( $query{service_id} eq $test_monitoringdata->{service_id}) {
								$response_ref = [ $test_monitoringdata ];
							} else {
								$response_ref = [ ];
							}
						} else {
							$response_ref = [ $test_monitoringdata ];
						}
					}
				} elsif ($req->method eq "POST") {

					if ($req->uri->path =~ /\/internal\/nodelayed$/ ) {

						$ref->{_id} = $monitoringdata_id;
						$ref->{alert} = 1;
						$ref->{job_id} = $monitoringdata_job_id;
						$ref->{compared_at} = time;
						$ref->{created_at} = time;
						$ref->{service_id} = 1;
						$ref->{user_id} = 1;
						$response_ref = $ref;
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint,
						monitoringdata_endpoint => $httpd->endpoint,
					);

my $all_arrayref = $g->monitoringdata->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{value}, "1", "all return value test");
isa_ok($all_arrayref->[0]->{checked_at}, "Time::Piece", "all return checked_at is Time::Piece object test");
isa_ok($all_arrayref->[0]->{created_at}, "Time::Piece", "all return created_at is Time::Piece object test");
isa_ok($all_arrayref->[0]->{compared_at}, "Time::Piece", "all return compared_at is Time::Piece object test");

my $conditions = { service_id => 1 };
my $search_arrayref = $g->monitoringdata->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{value}, "1", "search return value test");

my $monitoringdata = {
	servicetype  => "load_average",
	value        => "5.11",
	customkey   => "00:00:00:00:00:00",
	ck_init      => "00:00:00:00:00:00",
	tags         => ["1.0.0.1","00:00:00:00:00:00","test.priv"],
	checked_at   => time
	
};
my $create_ref = $g->monitoringdata->create($monitoringdata);
is(ref($create_ref), "HASH", "create return reftype test");
is($create_ref->{_id}, $monitoringdata_id, "create return _id test");
is($create_ref->{job_id}, $monitoringdata_job_id, "create return job_id test");
