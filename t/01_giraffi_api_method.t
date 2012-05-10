use strict;
use Test::More tests => 11;

use WWW::Giraffi::API;

my $g = new_ok("WWW::Giraffi::API");

my $media = $g->media;
isa_ok($media, "WWW::Giraffi::API::Media");

my $axion = $g->axion;
isa_ok($axion, "WWW::Giraffi::API::Axion");

my $item = $g->item;
isa_ok($item, "WWW::Giraffi::API::Item");

my $service = $g->service;
isa_ok($service, "WWW::Giraffi::API::Service");

my $trigger = $g->trigger;
isa_ok($trigger, "WWW::Giraffi::API::Trigger");

my $log = $g->log;
isa_ok($log, "WWW::Giraffi::API::Log");

my $applog = $g->applog;
isa_ok($applog, "WWW::Giraffi::API::AppLog");

my $trend = $g->trend;
isa_ok($trend, "WWW::Giraffi::API::Trend");

my $region = $g->region;
isa_ok($region, "WWW::Giraffi::API::Region");

my $monitoringdata = $g->monitoringdata;
isa_ok($monitoringdata, "WWW::Giraffi::API::MonitoringData");
