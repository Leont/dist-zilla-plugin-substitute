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

=head1 SYNOPSIS

 [Substitute]
 finder = :ExecFiles
 code = s/Foo/Bar/g

=head1 DESCRIPTION

This module performs substitutions on files in Dist::Zilla.

=attr code

An array-ref of lines of code. This is converted into a sub that's called for each line, with C<$_> containing that line. Alternatively, it may be a sub-ref if passed from for example a pluginbundle. Mandatory.

=attr finders

The finders to use for the substitutions. Defaults to C<:InstallModules, :ExecFiles>.

