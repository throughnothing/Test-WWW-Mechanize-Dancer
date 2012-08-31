package Test::WWW::Mechanize::Dancer;
use strict;
use warnings;
use Cwd;
use Dancer qw(:tests :moose);
use Moose;
use Test::WWW::Mechanize::PSGI;

# VERSION

has appdir      => (is => 'ro', default => getcwd );
has envdir      => (is => 'ro');
has agent       => (is => 'ro', default => 'Dancer Tests');
has confdir     => (is => 'ro');
has environment => (is => 'ro', default => 'test');
has public      => (is => 'ro');
has views       => (is => 'ro');

has mech        => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;

        my $m = Test::WWW::Mechanize::PSGI->new(
            app => sub {
                my $env = shift;
                set (
                    appdir => $self->appdir,
                    envdir => $self->envdir || path($self->appdir, 'environments'),
                    confdir => $self->confdir || $self->appdir,
                    public => $self->public || $self->appdir . '/public',
                    views => $self->views || $self->appdir . '/views',
                    environment => $self->environment,
                );
                my $request = Dancer::Request->new( env => $env );
                Dancer->dance( $request );
            }
        );
        $m->agent($self->agent);
        return $m;
    },
);

# ABSTRACT: Wrapper to easily use Test::WWW::Mechanize with your Dancer apps

=pod

=head1 SYNOPSIS

    use MyDancerApp;
    use Test::WWW::Mechanize::Dancer;

    # Get your standard Test::WWW::Mechanize object
    my $mech = Test::WWW::Mechanize::Dancer->new(
        # settings here if required
    )->mech;
    # Run standard Test::WWW::Mechanize tests
    $mech->get_ok('/');

=head1 DESCRIPTION

This is a simple wrapper that lets you test your Dancer apps using
Test::WWW::Mechanize.

=head1 SETTINGS

=head2 appdir

Probably the main thing you will want to set, C<appdir> sets the base
directory for the app.  C<confdir>, C<views>, and C<public>, will be 
set to C<appdir>, C<appdir>/views, and C<appdir>/public
respectively if not set explicitly.

The C<appdir> defaults to the current working directory, which works
in most testing cases.

=head2 agent

Allows you to set the user agent of the Mechanizer.

=head2 confdir

Set the dancer confdir.  Will default to appdir if unspecified.

=head2 envdir

Allows you to set the directory where Dancer should look for the config files
for each environment.  Defaults to 'environments' under appdir.  Note if your
app uses $ENV{DANCER_ENVDIR} you should explicitly pass that value using this
option.

=head2 environment

Allows you to set the Dancer environment to run your app in.  Defaults to
'test'

=head2 public

Set the public directory for your dancer app.  Defaults to C<appdir>/public

=head2 views

Set the views directory for your dancer app.  Defaults to C<appdir>/views

=cut

1;

