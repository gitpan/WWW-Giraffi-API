use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(map { split /[\s\:\-]/ } <DATA>);
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');
__DATA__
holly
WWW::Giraffi::API
DateTime
Akira
Horimoto
axion
axions
MonitoringData
giraffi
apikey
AppLog
nd
timestamp
failure
average
unix
todo
json
id
applog
monitoringdata
