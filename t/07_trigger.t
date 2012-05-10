use strict;
use WWW::Giraffi::API;
use HTTP::Response;
use JSON::Any;
use Test::More;

eval "use Test::Fake::HTTPD";
if($@) {
	plan skip_all => "Test::Fake::HTTPD required for testing http request/response";
} else {
	plan tests => 22;
}

my $test_trigger = {
	trigger => {
		axioninterval => 180,
		level         => 0,
		options       => { status => 200 },
		triggertype   => 'response',
		trigger_id    => 1,
		id            => 1
	}
};

my $test_axion = {
	axion => {
		options   => {},
		name      => 'Aborted Alert',
		axiontype => 'messaging',
		user_id   => 1639,
		id        => 1
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
						$response_ref = $test_trigger;
					} elsif ($req->uri->path =~ /\/triggers\/(\d+)\/axions.json$/ ) {
						$response_ref = [ $test_axion ];
					} elsif ($req->uri->query =~ /triggertype=/) {
						my %query = $req->uri->query_form;
						if( $query{triggertype} eq $test_trigger->{trigger}->{triggertype}) {
							$response_ref = [ $test_trigger ];
						} else {
							$response_ref = [];
						}
					} else {
						# all
						$response_ref = [ $test_trigger ];
					}
				} elsif ($req->method eq "POST") {

					if ($req->uri->path =~ /\/triggers\/(\d+)\/axions\/execute\.json$/) {
						$response_ref = [ $test_axion->{axion}->{id} ];
					}

				} elsif ($req->method eq "PUT") {

					if ($req->uri->path =~ /\/triggers\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/triggers\/(\d+)\/axions\/(\d+)\.json$/) {
						$response_ref = {};
					}
				} elsif ($req->method eq "DELETE") {

					if ($req->uri->path =~ /\/triggers\/(\d+)\/axions\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/triggers\/(\d+)\.json$/) {
						$response_ref = {};
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $trigger_id = 1;
my $axion_id   = 1;
my $axion_kind = "problem";
my $conditions = { triggertype => "response" };
my $trigger = {
		axioninterval => 180,
		level         => 0,
		options       => { status => 200 },
		triggertype   => 'response',
		trigger_id    => 1,
	};

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->trigger->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{trigger}->{id}, 1, "all return id test");

my $search_arrayref = $g->trigger->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{trigger}->{id}, 1, "search return id test");

my $find_ref = $g->trigger->find($trigger_id);
is(ref($find_ref), "HASH", "find return reftype test");
is(keys($find_ref), 1, "find return num test");
is($find_ref->{trigger}->{id}, 1, "find return id test");

my $update_ref = $g->trigger->update($trigger_id, $trigger);
is(ref($update_ref), "HASH", "update return reftype test");
is(keys(%{$update_ref}), 0, "trigger update test");

my $destroy_ref = $g->trigger->destroy($trigger_id);
is(ref($destroy_ref), "HASH", "destroy return reftype test");
is(keys(%{$destroy_ref}), 0, "trigger destory test");

my $axion_arrayref = $g->trigger->find_axion($trigger_id);
is(ref($axion_arrayref), "ARRAY", "find_axion return reftype test");
is(scalar(@{$axion_arrayref}), 1, "find_axion return num test");
is($axion_arrayref->[0]->{axion}->{id}, 1, "find_axion return id test");

my $update_axion_ref = $g->trigger->update_axion($trigger_id, $axion_id, $axion_kind);
is(ref($update_axion_ref), "HASH", "update_axion return reftype test");
is(keys(%{$update_axion_ref}), 0, "trigger destory test");

my $remove_axion_ref = $g->trigger->remove_axion($trigger_id, $axion_id, $axion_kind);
is(ref($remove_axion_ref), "HASH", "remove_axion return reftype test");
is(keys(%{$remove_axion_ref}), 0, "trigger destory test");

my $exec_axion_arrayref = $g->trigger->exec_axion($trigger_id);
is(ref($exec_axion_arrayref), "ARRAY", "exec_axion return reftype test");
is(scalar(@{$exec_axion_arrayref}), 1, "exec_axion return num test");
