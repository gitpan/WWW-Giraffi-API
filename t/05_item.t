use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 24;
}

my $test_item = {
	item => {
		warninginterval => 60,
		warningretry    => 2,
		status          => 1,
		ip              => '1.0.0.1',
		name            => 'Test Monitoring',
		host            => 'test.priv',
		user_id         => 16,
		id              => 1,
		normalinterval  => 120,
	}
};

my $test_service = {
	service => {
		warninginterval => 60,
		options => {
			useragent => 'test UA/1.0',
			path => '/hello.html'
		},
		warningretry => 2,
		status       => 1,
		item_id      => 448,
		id           => 1,
		normalinterval => 120,
		servicetype    => 'web_response_code'
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
						$response_ref = $test_item;
					} elsif ($req->uri->path =~ /\/items\/(\d+)\/services.json$/ ) {
						$response_ref = [ $test_service ];
					} elsif ($req->uri->query =~ /name=/) {
						my %query = $req->uri->query_form;
						if( $query{name} eq $test_item->{item}->{name}) {
							$response_ref = [ $test_item ];
						} else {
							$response_ref = [];
						}
					} else {
						# all
						$response_ref = [ $test_item ];
					}
				} elsif ($req->method eq "POST") {

					if ($req->uri->path =~ /\/items\/(\d+)\/services\.json$/) {
						$ref->{service}->{id} = 2;
						$response_ref = $ref;
					} elsif ($req->uri->path =~ /\/items\.json$/) {
						$ref->{item}->{id} = 2;
						$response_ref = $ref;
					} elsif ($req->uri->path =~ /\/items\/reload\.json$/) {
						$response_ref = { content => "successfully reload" };
					}

				} elsif ($req->method eq "PUT") {

					if ($req->uri->path =~ /\/items\/(\d+)\.json$/) {
						$response_ref = {};
					}
				} elsif ($req->method eq "DELETE") {

					if ($req->uri->path =~ /\/items\/(\d+)\/services\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/items\/(\d+)\.json$/) {
						$response_ref = {};
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $item_id = 1;
my $service_id = 1;
my $conditions = { name => "Test Monitoring" };
my $item = {
		warninginterval => 60,
		warningretry    => 2,
		status          => 1,
		ip              => '1.0.0.1',
		name            => 'Test Monitoring',
		host            => 'test.priv',
		user_id         => 16,
		id              => 1,
		normalinterval  => 120,
	};

my $service = {
		warninginterval => 60,
		options => {
			useragent => 'test UA/1.0',
			path => '/hello.html'
		},
		warningretry => 2,
		status       => 1,
		item_id      => 448,
		id           => 1,
		normalinterval => 120,
		servicetype    => 'web_response_code'
	};

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->item->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{item}->{id}, 1, "all return id test");

my $search_arrayref = $g->item->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{item}->{id}, 1, "search return id test");

my $find_ref = $g->item->find($item_id);
is(ref($find_ref), "HASH", "find return reftype test");
is(keys($find_ref), 1, "find return num test");
is($find_ref->{item}->{id}, 1, "find return id test");

my $create_ref = $g->item->create($item);
is(ref($create_ref), "HASH", "create return reftype test");
is($create_ref->{item}->{id}, 2, "create return id test");

my $update_ref = $g->item->update($item_id, $item);
is(ref($update_ref), "HASH", "update return reftype test");
is(keys(%{$update_ref}), 0, "item update test");

my $destroy_ref = $g->item->destroy($item_id);
is(ref($destroy_ref), "HASH", "destroy return reftype test");
is(keys(%{$destroy_ref}), 0, "item destory test");

my $service_arrayref = $g->item->find_service($item_id);
is(ref($service_arrayref), "ARRAY", "find_service return reftype test");
is(scalar(@{$service_arrayref}), 1, "find_service return num test");
is($service_arrayref->[0]->{service}->{id}, 1, "find_service return id test");

my $add_service_ref = $g->item->add_service($item_id, $service);
is(ref($add_service_ref), "HASH", "add_service return reftype test");
is($add_service_ref->{service}->{id}, 2, "add_service return id test");

my $remove_service_ref = $g->item->remove_service($item_id, $service_id);
is(ref($remove_service_ref), "HASH", "remove_service return reftype test");
is(keys(%{$remove_service_ref}), 0, "remove_service return keys test");

my $reload_ref = $g->item->reload;
is(ref($reload_ref), "HASH", "reload return reftype test");
is(keys(%{$reload_ref}), 1, "reload return keys test");
