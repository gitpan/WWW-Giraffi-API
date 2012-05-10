use inc::Module::Install;
name 'WWW-Giraffi-API';
all_from 'lib/WWW/Giraffi/API.pm';

requires
	"Class::XSAccessor"    => '1.13',
	"Crypt::SSLeay"        => '0.58',
	"JSON::Any"            => '1.29',
	"LWP::Protocol::https" => '6.03',
	"Module::Pluggable"    => '4.0',
	"Time::Piece"          => '1.20_01',
;

tests 't/*.t';
author_tests 'xt';

test_requires
	"Test::More"        => '0.98',
;
auto_set_repository;
auto_include;
WriteAll;
