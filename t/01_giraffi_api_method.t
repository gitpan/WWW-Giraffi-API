use strict;
use Test::More tests => 11;

use WWW::Giraffi::API;

my $g = new_ok("WWW::Giraffi::API");

my $media = $g->media;
isa_ok($media, "WWW::Giraffi::API::Media");
is($media, $g->media);

my $axion = $g->axion;
isa_ok($axion, "WWW::Giraffi::API::Axion");
is($axion, $g->axion);

my $item = $g->item;
isa_ok($item, "WWW::Giraffi::API::Item");
is($item, $g->item);

my $service = $g->service;
isa_ok($service, "WWW::Giraffi::API::Service");
is($service, $g->service);

my $trigger = $g->trigger;
isa_ok($trigger, "WWW::Giraffi::API::Trigger");
is($trigger, $g->trigger);
