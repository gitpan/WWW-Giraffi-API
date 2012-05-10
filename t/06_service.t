use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 25;
}

my $test_service = {
	service => {
		warninginterval => 60,
		options => {
			useragent => 'test UA/1.0',
			path => '/hello.html'
		},
		warningretry => 2,
		status       => 1,
		service_id   => 1,
		id           => 1,
		normalinterval => 120,
		servicetype    => 'web_response_code'
	}
};

my $test_region = {
	region => {
		id   => 1,
		code => "JP"
	}
};

my $test_trigger = {
	trigger => {
		axioninterval => 180,
		level         => 0,
		options       => { status => 200 },
		triggertype   => 'response',
		service_id    => 1,
		id            => 1
	}
};

my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref = $req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					# print "#" . $req->uri->path . "\n";
					if ($req->uri->path =~ /\/(\d+)\.json$/ ) {
						# find
						$response_ref = $test_service;
					} elsif ($req->uri->path =~ /\/services\/(\d+)\/regions.json?$/ ) {
							$response_ref = [ $test_region ];
					} elsif ($req->uri->path =~ /\/services\/(\d+)\/triggers.json$/ ) {
						$response_ref = [ $test_trigger ];
					} elsif ($req->uri->query =~ /servicetype=/) {
						my %query = $req->uri->query_form;
						if( $query{servicetype} eq $test_service->{service}->{servicetype}) {
							$response_ref = [ $test_service ];
						} else {
							$response_ref = [];
						}
					} else {
						# all
						$response_ref = [ $test_service ];
					}
				} elsif ($req->method eq "POST") {

					if ($req->uri->path =~ /\/services\/(\d+)\/triggers\.json$/) {
						$ref->{trigger}->{id} = 2;
						$response_ref = $ref;
					} elsif ($req->uri->path =~ /\/services\.json$/) {
						$ref->{service}->{id} = 2;
						$response_ref = $ref;
					}

				} elsif ($req->method eq "PUT") {

					if ($req->uri->path =~ /\/services\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/services\/(\d+)\/regions\/([a-zA-Z]+)\.json$/) {
						$response_ref = {};
					}
				} elsif ($req->method eq "DELETE") {

					if ($req->uri->path =~ /\/services\/(\d+)\/triggers\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/services\/(\d+)\.json$/) {
						$response_ref = {};
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $service_id = 1;
my $trigger_id = 1;
my $conditions = { servicetype => "web_response_code" };
my $service = {
		warninginterval => 60,
		options => {
			useragent => 'test UA/1.0',
			path => '/hello.html'
		},
		warningretry => 2,
		status       => 1,
		service_id      => 448,
		id           => 1,
		normalinterval => 120,
		servicetype    => 'web_response_code'
	};

my $region_code = "JP";

my $trigger = {
		axioninterval => 180,
		level         => 0,
		options       => { status => 200 },
		triggertype   => 'response',
		service_id    => 1,
	};

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->service->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{service}->{id}, 1, "all return id test");

my $search_arrayref = $g->service->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{service}->{id}, 1, "search return id test");

my $find_ref = $g->service->find($service_id);
is(ref($find_ref), "HASH", "find return reftype test");
is(keys($find_ref), 1, "find return num test");
is($find_ref->{service}->{id}, 1, "find return id test");

my $update_ref = $g->service->update($service_id, $service);
is(ref($update_ref), "HASH", "update return reftype test");
is(keys(%{$update_ref}), 0, "service update test");

my $destroy_ref = $g->service->destroy($service_id);
is(ref($destroy_ref), "HASH", "destroy return reftype test");
is(keys(%{$destroy_ref}), 0, "service destory test");

my $region_arrayref = $g->service->find_region($service_id);
is(ref($region_arrayref), "ARRAY", "find_region return reftype test");
is(scalar(@{$region_arrayref}), 1, "find_region return num test");
is($region_arrayref->[0]->{region}->{id}, 1, "find_region return id test");

my $update_region_ref = $g->service->update_region($service_id, $region_code);
is(ref($update_region_ref), "HASH", "update_region return reftype test");
is(keys(%{$update_region_ref}), 0, "service destory test");

my $trigger_arrayref = $g->service->find_trigger($trigger_id);
is(ref($trigger_arrayref), "ARRAY", "find_trigger return reftype test");
is(scalar(@{$trigger_arrayref}), 1, "find_trigger return num test");
is($trigger_arrayref->[0]->{trigger}->{id}, 1, "find_trigger return id test");

my $add_trigger_ref = $g->service->add_trigger($service_id, $trigger);
is(ref($add_trigger_ref), "HASH", "add_trigger return reftype test");
is($add_trigger_ref->{trigger}->{id}, 2, "add_trigger return id test");

my $remove_trigger_ref = $g->service->remove_trigger($service_id, $trigger_id);
is(ref($remove_trigger_ref), "HASH", "remove_trigger return reftype test");
is(keys(%{$remove_trigger_ref}), 0, "remove_trigger return keys test");
