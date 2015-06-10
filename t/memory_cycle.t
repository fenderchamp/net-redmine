#!/usr/bin/env perl -w
use strict;
use Net::Redmine;

use lib 't/lib';
use Test::Project;

use Test::Memory::Cycle;

my $test_project = Test::Project->new(
    initialize  => 1
);
my $r = $test_project->r;

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
