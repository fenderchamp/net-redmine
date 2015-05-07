#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Test::Project;
use Test::More;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();

my ($identifier, $name, $description, $homepage ) = project_test_data();


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

note "Testing the top-level Net::Redmine object API";

my $t1 = $r->create(
    ticket => {
        subject => __FILE__ . " $$ @{[time]}",
        description => __FILE__ . "$$ @{[time]}"
    }
);

like($t1->id, qr/^[0-9]+$/s, "The ID of created tickets should be an Integer.");

my $t2 = $r->lookup(
    ticket => {
        id => $t1->id
    }
);

is($t2->id, $t1->id, "The loaded ticket should have correct ID.");

use Scalar::Util qw(refaddr);

is refaddr($t2), refaddr($t1), 
	"ticket objects with the same ID should be identical."; 


$test_project->scrub_project_if_exists;



