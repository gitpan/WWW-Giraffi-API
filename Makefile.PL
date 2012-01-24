use inc::Module::Install;
name 'WWW-Giraffi-API';
all_from 'lib/WWW/Giraffi/API.pm';

requires(
	"Class::XSAccessor"    => 0,
	"Crypt::SSLeay"        => 0,
	"JSON::Any"            => 0,
	"LWP::Protocol::https" => 0,
	"Module::Pluggable"    => 0,
	"Time::Piece"          => 0,
);

tests 't/*.t';
author_tests 'xt';

test_requires(
	"Test::More"        => 0,
	"Test::Fake::HTTPD" => 0,
);
auto_set_repository;
auto_include;
WriteAll;
