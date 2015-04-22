#!/usr/bin/env perl -w
use strict;
use Test::Cukes;
use Net::RedmineRest;
use URI;

my ($r, $c);

#admin account for
#http://netredmine.m.redmine.org
#'net-redmine-unit-tests-admin', 'net-redmine-unit-tests'

my ($user, $password, $apikey) = ('net-redmine-unit-tests', 'net-redmine-unit-tests','7b7ae7e9f9aed7ffed823f55701bf745c119338c');

Given qr/an redmine object with a clean url and a project/ => sub {
    my $url = "http://netredmine.m.redmine.org";
    $r = Net::RedmineRest->new(project=>'test', url => $url, user => $user, password => $password, apikey => $apikey);
    $c = $r->connection;
    assert $c->isa("Net::RedmineRest::Connection");
};

Given qr/an redmine object with a project bound url/ => sub {
    my $url = "http://netredmine.m.redmine.org/projects/test";
    $r = Net::RedmineRest->new(url => $url, user => $user, password => $password, apikey => $apikey);
    $c = $r->connection;
    assert $c->isa("Net::RedmineRest::Connection");
};

Given qr/an redmine wo apikey object with a plain url/ => sub {
    my $url = 'http://netredmine.m.redmine.org';
    $r = Net::RedmineRest->new(url => $url,user => $user, password => $password);
    $c = $r->connection;
    assert $c->isa("Net::RedmineRest::Connection");
};

Given qr/an redmine object with a plain url/ => sub {
    my $url = 'http://netredmine.m.redmine.org';
    $r = Net::RedmineRest->new(url => $url,user => $user, password => $password, apikey => $apikey);
    $c = $r->connection;
    assert $c->isa("Net::RedmineRest::Connection");
};

Given qr/an redmine object with a port too and project bound url/ => sub {
    my $url = "http://nonesuch.nothing.com:1234/projects/test";
    $r = Net::RedmineRest->new(url => $url, user => $user, password => $password, apikey => $apikey);
    $c = $r->connection;
    assert $c->isa("Net::RedmineRest::Connection");
};


When qr/invoke the "(.*)" method/ => sub {
    $c->$1;
};

Then qr/it should have set is_rest/ => sub {
    assert $c->is_rest;
};

Then qr/it shouldnt have set is_rest/ => sub {
    assert ! $c->is_rest;
};

Then qr/it should be logined/ => sub {
    assert $c->is_logined;
};

Then qr/it should have a redmine base_url attribute defined/ => sub {
    should ( $c->base_url, 'http://netredmine.m.redmine.org');
};

Then qr/it should have a project defined/ => sub { 
    should ( $c->project,  'test' );
};

Then qr/the url should be different than the base url/ => sub {
    shouldnt ( $c->url,      $c->base_url );
};

Then qr/the url should be the same as the base url/ => sub {
    should ( $c->url,      $c->base_url );
};

Then qr/it should have a base_url and port attribute defined without the projects path/ =>sub { 
    my $url = 'http://nonesuch.nothing.com:1234';
    should ( $c->base_url, $url );
};

$/ = undef;
feature(<DATA>);
runtests;

#  Scenario: test the connection info with project
#    Given an redmine object with a project bound url
#    When invoke the "assert_login" method
#    Then it should have set is_rest
#    And it should be logined

__END__
Feature: Net::RedmineRest::Connection class
  Describe the features provided by Net::RedmineRest::Connection class

  Scenario: test the connection info
    Given an redmine object with a plain url
    Then the url should be the same as the base url
    When invoke the "assert_login" method
    Then it should have set is_rest
    And it should be logined

  Scenario: test the connection info with project
    Given an redmine object with a project bound url
    Then it should have a redmine base_url attribute defined without the projects path 
    And it should have a project defined called test
    And the url should be different than the base url
    When invoke the "assert_login" method
    Then it should have set is_rest
    And it should be logined

  Scenario: test the connection info with port and project
    Given an redmine object with a port too and project bound url
    Then it should have a base_url and port attribute defined without the projects path 
    And it should have a project defined called test
    And the url should be different than the base url

  Scenario: test the connection info with username and password and mech
    Given an redmine wo apikey object with a plain url 
    Then the url should be the same as the base url
    When invoke the "assert_login" method
    Then it shouldnt have set is_rest
    And it should be logined

  Scenario: redmine object with a clean url and a project
    Given an redmine object with a clean url and a project
    Then it should have a redmine base_url attribute defined without the projects path 
    And the url should be the same as the base url
    And it should have a project defined called test
    When invoke the "assert_login" method
    Then it should have set is_rest
    And it should be logined

