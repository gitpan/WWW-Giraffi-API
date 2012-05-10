use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 3;
}

my $test_region = {
	region => {
		id   => 1,
		code => "JP"
	}
};

my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref = $req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					if ($req->uri->path =~ /\/regions\.json$/ ) {
						# find
						$response_ref = [ $test_region ];
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->region->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{region}->{id}, 1, "all return id test");
