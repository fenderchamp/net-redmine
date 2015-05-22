#!/usr/bin/env perl -w
use strict;
use Net::Redmine;
use Test::Project;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my ( $identifier, $name, $description, $homepage ) = project_test_data();

my $test_project = Test::Project->new(
    r           => $r,
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage,
    initialize  => 1
);

### Prepare new tickets
my ($ticket) = new_tickets($r, 1);
my $id = $ticket->id;

$ticket->destroy;

my $t2 = Net::Redmine::Issue->load(connection => $r->connection, id => $id);

is($t2, undef, "loading a deleted ticket should return undef.");
$test_project->scrub_project_if_exists;
