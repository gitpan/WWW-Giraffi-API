use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
#use Test::More tests => 13;
use Test::More;

eval "use Test::Fake::HTTPD";
plan skip_all => "Test::Fake::HTTPD required for testing http request/response" if $@;


my $test_medium =  {
			medium => {
				options => { address => 'me@domain' },
				mediumtype => 'email',
				name => 'Alert Email',
				user_id => 1639,
				id => 1
			}
		};

my $a = 1;

my $httpd = run_http_server {
				my $req = shift;
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					if ($req->uri->path =~ /\/(\d+)\.json$/ ) {
						# find
						$response_ref = $test_medium;
					} elsif ($req->uri->query =~ /name=/) {
						my %query = $req->uri->query_form;
						if( $query{name} eq $test_medium->{medium}->{name}) {
							$response_ref = [ $test_medium ];
						} else {
							$response_ref = [];
						}
					} else {
						# all
						$response_ref = [ $test_medium ];
					}

				} elsif ($req->method eq "POST") {

					$ref->{medium}->{id} = 2;
					$response_ref = $ref;

				} elsif ($req->method eq "PUT") {

					$test_medium->{medium}->{name} = $ref->{medium}->{name};

				} elsif ($req->method eq "DELETE") {
					$req->uri->path =~ /\/(\d+)\.json$/;
					my $media_id = $1;
					delete $test_medium->{medium} if exists $test_medium->{medium}->{$media_id};
				}

				return HTTP::Response->new( 200, "ok", [ "Content-Type" => "application/json" ], JSON::Any->new->encode($response_ref) )};

my $apikey = "ilovenirvana_ilovemelvins";
$WWW::Giraffi::API::DEFAULT_ENDPOINT = $httpd->endpoint;

my $media_id = 1;
my $conditions = { name => "Alert Email" };
my $medium = {
		options => { address => 'me@domain' },
		mediumtype => 'email',
		name => 'Alert Email',
	};

my $g = WWW::Giraffi::API->new(apikey => $apikey);

my $all_arrayref = $g->media->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{medium}->{id}, 1, "all return id test");

my $search_arrayref = $g->media->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{medium}->{id}, 1, "search return id test");

my $find_ref = $g->media->find($media_id);
is(ref($find_ref), "HASH", "find return reftype test");
cmp_ok(keys($find_ref), "==", 1, "find return num test");
is($find_ref->{medium}->{id}, 1, "find return id test");


my $create_ref = $g->media->create($medium);
is(ref($create_ref), "HASH", "create return reftype test");
is($create_ref->{medium}->{id}, 2, "create return id test");

my $update_ref = $g->media->update($media_id, $medium);
is(ref($update_ref), "HASH", "update return reftype test");
#is($test_medium->{medium}->{name}, $medium->{name}, "media update name value test");

my $destroy_ref = $g->media->destroy($media_id);
is(ref($destroy_ref), "HASH", "destroy return reftype test");
#ok(!defined $test_medium, "media destory test");

