use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 8;
}


my $test_average =  {
	min        => '0.004585',
	value      => '0.00505966666666667',
	checked_at => 1336604400,
	max        => '0.00557'
};

my $test_failure = {
	failed_start_at  => 1336245901,
	_id              => '4fa59bf52325b41f760000af',
	region           => 'JP',
	service_id       => 1,
	tags => [
		'202.218.236.65',
		'f00-065.236.218.202.fs-user.net'
	],
	failed_time      => 1201,
	failed_end_at    => 1336247102,
	user_id          => 1,
	servicetype      => 'web_reponse_code',
	customkey        => undef
};

my $httpd = Test::Fake::HTTPD->new->run(sub {

				my $req = shift;
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					if ($req->uri->path =~ /\/trends\/average\.json$/ ) {
						# all
						$response_ref = [ $test_average ];
					} elsif ($req->uri->path =~ /\/trends\/failure\.json$/) {
						$response_ref = [ $test_failure ];
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $average_arrayref = $g->trend->search_average;
is(ref($average_arrayref), "ARRAY", "average return reftype test");
is(scalar(@{$average_arrayref}), 1, "average return num test");
is($average_arrayref->[0]->{value}, "0.00505966666666667", "average return value test");
isa_ok($average_arrayref->[0]->{checked_at}, "Time::Piece", "checked_at is Time::Piece object test");

my $failure_arrayref = $g->trend->search_failure;
is(ref($failure_arrayref), "ARRAY", "failure return reftype test");
is(scalar(@{$failure_arrayref}), 1, "failure return num test");
isa_ok($failure_arrayref->[0]->{failed_start_at}, "Time::Piece", "failed_start_at is Time::Piece object test");
isa_ok($failure_arrayref->[0]->{failed_end_at}, "Time::Piece", "failed_end_at is Time::Piece object test");
