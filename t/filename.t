use strict;
use warnings;

use Test::More 0.88;

use Test::DZil;
use Path::Tiny;

my $tzil = Builder->from_config(
	{ dist_root => 'corpus/' },
	{
		add_files => {
			'source/dist.ini' => simple_ini(
				qw(@Basic PkgVersion),
				[ Substitute => { content_code => 's/Foo/Bar/g', filename_code => 's/Foo.pm/Bar.pm/g' } ],
			),
		},
	}
);

$tzil->build;

my $dir = path($tzil->tempdir)->child('build');

my $file = $dir->child('lib', 'Foo.pm');
ok !-e $file, 'original file does not exist';
$file = $dir->child('lib', 'Bar.pm');
ok -e $file, 'renamed file exists';

my $content = $file->slurp_utf8;
like $content, qr/Bar/, 'Content contains Bar';
unlike $content, qr/Foo/, 'Content contains no Foo';

done_testing;

# vim: ts=2 sts=2 sw=2 noet :
