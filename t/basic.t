#!perl
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
        [ Substitute => { code => 's/Foo/Bar/g' } ],
      ),
    },
  }
);

$tzil->build;

my $dir = dir($tzil->tempdir, 'build');

my $file = $dir->file('lib', 'Foo.pm');
ok -e $file;
my $content = $file->slurp;
like $content, qr/Bar/, 'Content contains Bar';
unlike $content, qr/Foo/, 'Content contains no Foo';

done_testing;

# vi:noet:sts=2:sw=2:ts=2
