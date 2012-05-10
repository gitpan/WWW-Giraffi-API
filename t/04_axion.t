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

my $test_medium = {
		medium => {
			options    => { address => 'me@domain' },
			mediumtype => 'email',
			name       => 'Alert Email',
			user_id    => 1639,
			id         => 1
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
				my $ref =$req->content ? JSON::Any->new->decode($req->content) : undef;

				my $response_ref = {};

				if ($req->method eq "GET") {

					# print "#" . $req->uri->path . "\n";
					if ($req->uri->path =~ /\/(\d+)\.json$/ ) {
						# find
						$response_ref = $test_axion;
					} elsif ($req->uri->path =~ /\/axions\/(\d+)\/media.json$/ ) {
						$response_ref = [ $test_medium ];
					} elsif ($req->uri->query =~ /name=/) {
						my %query = $req->uri->query_form;
						if( $query{name} eq $test_axion->{axion}->{name}) {
							$response_ref = [ $test_axion ];
						} else {
							$response_ref = [];
						}
					} else {
						# all
						$response_ref = [ $test_axion ];
					}
				} elsif ($req->method eq "POST") {

					#printf("#%s\n", $req->uri->path);
					if ($req->uri->path =~ /\/axions\/(\d+)\/execute\.json$/) {
						$response_ref = { content => "ok" };
					} elsif ($req->uri->path =~ /\/axions\.json$/) {
						$ref->{axion}->{id} = 2;
						$response_ref = $ref;
					}

				} elsif ($req->method eq "PUT") {
					if ($req->uri->path =~ /\/axions\/(\d+)\/media\/(\d+)\.json$/) {
						$response_ref = {};
					} elsif ($req->uri->path =~ /\/axions\/(\d+)\.json$/) {
						$response_ref = {};
					}

				} elsif ($req->method eq "DELETE") {
					if ($req->uri->path =~ /\/axions\/(\d+)\/media\/(\d+)\.json$/) {
						$response_ref = { content => "ok" };
					} elsif ($req->uri->path =~ /\/axions\/(\d+)\.json$/) {
						my $axion_id = $1;
						delete $test_axion->{axion} if exists $test_axion->{axion}->{$axion_id};
					}
				}

				return [ 200, [ "Content-Type" => "application/json" ], [ JSON::Any->new->encode($response_ref) ] ];
		});

my $media_id = 1;
my $axion_id = 1;
my $conditions = { name => "Aborted Alert"};
my $axion = {
			options   => {},
			name      => 'Aborted Alert',
			axiontype => 'messaging',
		};

my $apikey = "ilovenirvana_ilovemelvins";
my $g = WWW::Giraffi::API->new(
						apikey => $apikey,
						default_endpoint => $httpd->endpoint
					);

my $all_arrayref = $g->axion->all;
is(ref($all_arrayref), "ARRAY", "all return reftype test");
is(scalar(@{$all_arrayref}), 1, "all return num test");
is($all_arrayref->[0]->{axion}->{id}, 1, "all return id test");

my $search_arrayref = $g->axion->search($conditions);
is(ref($search_arrayref), "ARRAY", "search return reftype test");
is(scalar(@{$search_arrayref}), 1, "search return num test");
is($search_arrayref->[0]->{axion}->{id}, 1, "search return id test");

my $find_ref = $g->axion->find($axion_id);
is(ref($find_ref), "HASH", "find return reftype test");
is(keys($find_ref), 1, "find return num test");
is($find_ref->{axion}->{id}, 1, "find return id test");

my $create_ref = $g->axion->create($axion);
is(ref($create_ref), "HASH", "create return reftype test");
is($create_ref->{axion}->{id}, 2, "create return id test");

my $update_ref = $g->axion->update($axion_id, $axion);
is(ref($update_ref), "HASH", "update return reftype test");
is(keys(%{$update_ref}), 0, "axion update hash test");

my $destroy_ref = $g->axion->destroy($axion_id);
is(ref($destroy_ref), "HASH", "destroy return reftype test");
is(keys(%{$destroy_ref}), 0, "axion destory test");

my $media_arrayref = $g->axion->find_media($axion_id);
is(ref($media_arrayref), "ARRAY", "find_media return reftype test");
is(scalar(@{$media_arrayref}), 1, "find_media return num test");
is($media_arrayref->[0]->{medium}->{id}, 1, "find_media return id test");

my $add_media_ref = $g->axion->add_media($axion_id, $media_id);
is(ref($add_media_ref), "HASH", "add_media return reftype test");
is(keys(%{$add_media_ref}), 0, "add_media return hash test");

my $remove_media_ref = $g->axion->remove_media($axion_id, $media_id);
is(ref($remove_media_ref), "HASH", "remove_media return reftype test");
is($remove_media_ref->{content}, "ok", "remove_media return content test");

my $exec_ref = $g->axion->exec($axion_id);
is(ref($exec_ref), "HASH", "exec return reftype test");
is($exec_ref->{content}, "ok", "exec return content test");
