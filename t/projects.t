#!/usr/bin/env perl -w
use strict;
use Test::Project;

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();
my ( $identifier, $name, $description, $homepage ) = project_test_data();

my $t = Test::Project->new(
    r           => $r,
    identifier  => $identifier,
    name        => $name,
    description => $description,
    homepage    => $homepage
);

$t->scrub_project_if_exists();
$t->create_project_and_verify_its_there();
$t->scrub_project_if_exists();
