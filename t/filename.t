use strict;
use warnings;

use Test::More 0.88;

use Test::DZil;
use Path::Class;

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

my $dir = dir($tzil->tempdir, 'build');

my $file = $dir->file('lib', 'Foo.pm');
ok !-e $file, 'original file does not exist';
$file = $dir->file('lib', 'Bar.pm');
ok -e $file, 'renamed file exists';

my $content = $file->slurp;
like $content, qr/Bar/, 'Content contains Bar';
unlike $content, qr/Foo/, 'Content contains no Foo';

done_testing;

# vi:noet:sts=2:sw=2:ts=2
