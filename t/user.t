#!/usr/bin/env perl -w
use strict;
use Net::RedmineRest;
use Net::RedmineRest::User;
use Test::More qw(no_plan);

require 't/net_redmine_rest_test.pl';

my $r = new_net_redmine();
my $current_user = Net::RedmineRest::User->load(
    connection => $r->connection,
    id => 'current'
);

ok($current_user,'current user is def');
ok($current_user->firstname,'current has firsname');
ok($current_user->lastname,'current has lastname');
ok($current_user->login,'current has login');
ok($current_user->mail,'current has mail');

my $new_user = Net::RedmineRest::User->create(
    connection => $r->connection,
    firstname => 'firstname',
    lastname => 'lastname',
    login => 'login',
    mail => 'mail@mail.net',
    password => 'testpassword'
);

ok($new_user,'new user is def');
ok($new_user->firstname,'new has firstname');
ok($new_user->lastname,'new has lastname');
ok($new_user->login,'new has login');
ok($new_user->mail,'new has mail');
ok($new_user->id,'new has id');

my $loaded_user = Net::RedmineRest::User->load(
    connection => $r->connection,
    id => $new_user->id
);

ok($loaded_user,'loaded user is def');
ok($loaded_user->firstname,'loaded has firstname');
ok($loaded_user->lastname,'loaded has lastname');
ok($loaded_user->login,'loaded has login');
ok($loaded_user->mail,'loaded has mail');
ok($loaded_user->id,'loaded has id');

is($new_user->firstname, $loaded_user->firstname, 'match firtsname');
is($new_user->lastname, $loaded_user->lastname, 'match lastname');
is($new_user->login, $loaded_user->login, 'match login');
is($new_user->mail, $loaded_user->mail, 'match mail');
is($new_user->id, $loaded_user->id,'match id');

$loaded_user->destroy();
undef($loaded_user);

$loaded_user = Net::RedmineRest::User->load(
    connection => $r->connection,
    id => $new_user->id
);

ok(!$loaded_user,'user is no more');

