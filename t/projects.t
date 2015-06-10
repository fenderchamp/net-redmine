#!/usr/bin/env perl -w
use strict;

use lib 't/lib';
use Test::Project;

require 't/net_redmine_rest_test.pl';

my $t = Test::Project->new();

$t->scrub_project_if_exists();
$t->create_project_and_verify_its_there();
$t->scrub_project_if_exists();
