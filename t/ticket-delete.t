#!/usr/bin/env perl -w
use strict;
use Net::Redmine;

use lib 't/lib';
use Test::Project;
use Test::More;

my $test_project = Test::Project->new(
    initialize  => 1
);

my $r = $test_project->r;

### Prepare new tickets
my ($ticket) = $test_project->new_tickets(1);
my $id = $ticket->id;

$ticket->destroy;

my $t2 = Net::Redmine::Issue->load(connection => $r->connection, id => $id);

is($t2, undef, "loading a deleted ticket should return undef.");
$test_project->scrub_project_if_exists;
