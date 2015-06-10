#!/usr/bin/env perl -w

use strict;

use Net::Redmine;
use Net::Redmine::Ticket;
use Test::More;

use lib 't/lib';
use Test::Project;

my $test_project = Test::Project->new(
    initialize  => 1
);

my ($ticket) = $test_project->new_tickets( 1 );
my $id = $ticket->id;

my $test_project2 = Test::Project->new();

my $ticket2 =
  Net::Redmine::Ticket->load( connection => $test_project2->r->connection, id => $id );

$ticket->description("bleh bleh bleh");
$ticket->save;

$ticket2->refresh;

is( $ticket2->description, $ticket->description,
    "ticket content is refreshed" );

$test_project->scrub_project_if_exists;
