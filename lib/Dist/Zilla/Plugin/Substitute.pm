package Dist::Zilla::Plugin::Substitute;

use Moose;
use Moose::Util::TypeConstraints;

with qw/Dist::Zilla::Role::FileMunger/;

has finders => (
	is  => 'ro',
	isa => 'ArrayRef',
	default => sub { [ qw/:InstallModules :ExecFiles/ ] },
);

subtype 'CodeLiteral', as 'CodeRef';
coerce 'CodeLiteral', from 'ArrayRef', via { eval sprintf "sub { %s } ", join "\n", @{ $_ } };

has code => (
	is       => 'ro',
	isa      => 'CodeLiteral',
	coerce   => 1,
	required => 1,
);

sub mvp_multivalue_args {
	return qw/finders code/;
}

sub files {
	my $self = shift;
	my @filesets = map { @{ $self->zilla->find_files($_) } } @{ $self->finders };
	my %files = map { $_->name => $_ } @filesets;
	return values %files;
}

sub munge_files {
	my $self = shift;
	$self->munge_file($_) for $self->files;
	return;
}

sub munge_file {
	my ($self, $file) = @_;
	my @content = split /\n/, $file->content;
	my $code = $self->code;
	$code->() for @content;
	$file->content(join "\n", @content);
	return;
}

1;

# ABSTRACT: Substitutions for files in dzil
