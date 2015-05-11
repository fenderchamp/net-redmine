#!/usr/bin/env perl -w

use strict;

use Test::Project;
use Net::RedmineRest;
use Net::RedmineRest::Ticket;
use Test::More;

require 't/net_redmine_rest_test.pl';
my ( $identifier, $name, $description, $homepage ) = project_test_data();
my $test_project = Test::Project->new(
    r           => new_net_redmine(),
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage,
    initialize  => 1
);

my ($ticket) = new_tickets( $test_project->r, 1 );
my $id = $ticket->id;

my $rr = new_net_redmine();

  my $ticket2 =
  Net::RedmineRest::Ticket->load( connection => $rr->connection, id => $id );

$ticket->description("bleh bleh bleh");
$ticket->save;

$ticket2->refresh;

is( $ticket2->description, $ticket->description,
    "ticket content is refreshed" );

