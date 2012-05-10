use strict;
use WWW::Giraffi::API::Request;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD;";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 20;
}

my $ref = {message => "dummy"};

my $httpd = Test::Fake::HTTPD->new->run(sub {
				my $req = shift;
				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($ref) ] ];
			});

my $apikey = "ilovenirvana_ilovemelvins";
my $args = [
			apikey                 => $apikey,
			agent                   => "dummy agent",
			timeout                 => 30,
			default_endpoint        => $httpd->endpoint,
			monitoringdata_endpoint => $httpd->endpoint,
			applogs_endpoint        => $httpd->endpoint,
			verbose                 => 0,
		];
my $req = new_ok("WWW::Giraffi::API::Request", $args);

# make request test
my $http_req = $req->make_request("POST", "/helloworld", undef, $ref);
isa_ok($http_req, "HTTP::Request");
is($http_req->method, "POST", "request method equal test");
is($http_req->content, JSON::Any->new->encode($ref), "request content equal test");

# make response test
my $http_res = $req->make_response(500, { error => "error message" });
isa_ok($http_res, "HTTP::Response");
is($http_res->code, 500, "response code equal test");
is($http_res->content, JSON::Any->new->encode({ error => "error message" }), "response content equal test");


# _json2ref/_ref2json test
my $json = JSON::Any->new->encode($ref);
is($req->_ref2json($ref), $json, "_ref2json and json string equal test");
is($req->_json2ref($json)->{message}, $ref->{message}, "_json2ref and reference equal test");

# _make_uri test
my $path     = "hello";
my $queryref = { foo => "bar" };
my $uri = $req->_make_uri($path, $queryref);
isa_ok($uri, "URI");
is($uri, sprintf("%s/%s?apikey=%s&%s", $req->default_endpoint, $path, $apikey, "foo=bar"), "URI overload string test");

# _is_json test
ok($req->_is_json("['apple','melon']"));
ok($req->_is_json("{'apple':'ringo'}"));

# request test
my $res = $req->request("GET", $path, $queryref);
isa_ok($res, "HTTP::Response");
is($res->code, 200, "dummy GET request code test");
is($res->content, JSON::Any->new->encode($ref), "dummy GET request content test");

# get/post/pub/delete test
is($req->get($path, $queryref)->{message}, $ref->{message});
is($req->post($path, $queryref, $ref)->{message}, $ref->{message});
is($req->put($path, $queryref, $ref)->{message}, $ref->{message});
is($req->delete($path, $queryref)->{message}, $ref->{message});
