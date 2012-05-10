use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 6;
}

my $new_apikey = "new_user_apikey";
my $update_apikey = "update_user_apikey";

my $test_user =  {
		user => {
				status     => "enabled",
				permission => 'wr',
				id         => 2,
				apikey     => $new_apikey
		}
	};

my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "POST") {
					$response_ref = $test_user;
				} elsif ($req->method eq "PUT") {
					$test_user->{user}->{apikey} = $update_apikey;
					$response_ref = $test_user;
				} elsif ($req->method eq "DELETE") {
					$response_ref = {};
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $vendor_apikey = "vendor_apikey";
my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $create_ref = $g->user->create($vendor_apikey);
is(ref($create_ref), "HASH", "create return reftype test");
is_deeply($create_ref, $test_user, "create return struct test");

my $update_ref = $g->user->update($create_ref->{apikey});
is(ref($update_ref), "HASH", "update return reftype test");
is($update_ref->{user}->{apikey}, $update_apikey, "update return apikey test");

my $delete_ref = $g->user->delete($update_ref->{apikey});
is(ref($delete_ref), "HASH", "delete return reftype test");
is(keys(%{$delete_ref}), 0, "delete return key num test");
