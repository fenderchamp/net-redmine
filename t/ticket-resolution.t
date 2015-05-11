#!/usr/bin/env perl -w
use strict;
use Test::More;
use Net::RedmineRest;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my ( $identifier, $name, $description, $homepage ) = project_test_data();

$test_project = Test::Project->new(
    r           => new_net_redmine(),
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage,
    initialize  => 1
);

my $id;
{
    my $t1 = $r->create(
        ticket => {
            subject     => __FILE__ . " $$ @{[time]}",
            description => __FILE__ . "$$ @{[time]}"
        }
    );

    is $t1->status(), "New", "The default state of a new ticket";

    $t1->status("Closed");
    $t1->save;

    $id = $t1->id;
    diag "The newly created ticket id = $id";
}
{
    my $t =
      Net::Redmine::Ticket->load( connection => $r->connection, id => $id );

    is $t->status(), "Closed";
}

$test_project->scrub_project_if_exists;
