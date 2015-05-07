#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Test::Project;

use Test::Memory::Cycle;
require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my ( $identifier, $name, $description, $homepage ) = project_test_data();

my $test_project = Test::Project->new(
    r           => $r,
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage
);

my $url = $test_project->valid_project_url;

undef $r;
$r = new_net_redmine();
#create project url path
$r->connection->{url}=$url;

my $t1 = $r->create(
    ticket => {
        subject => __FILE__ . " $$ @{[time]}",
        description => __FILE__ . "$$ @{[time]}"
    }
);

memory_cycle_ok($r,'redmine object');
memory_cycle_ok($t1,'issue object');

my $t2 = $r->lookup(
    ticket => {
        id => $t1->id
    }
);

memory_cycle_ok($r,'redmind object');
memory_cycle_ok($t2,'ticket object');

$t1->destroy;
$test_project->scrub_project_if_exists;
