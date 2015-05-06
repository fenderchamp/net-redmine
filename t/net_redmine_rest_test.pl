use Test::More;
use Cwd 'getcwd';


END {
    # system "kill -9 $REDMINE_SERVER_PID" if $REDMINE_SERVER_PID
}

sub net_redmine_test {
    return ("http://demo.redmin.org", "admin", "admin");
}

sub new_net_redmine {

   #$my ($server, $user, $password, $apikey) = ("http://netredmine.m.redmine.org", "net-redmine-unit-tests-admin", "net-redmine-unit-tests","e366da4adfe8d242891c59cbd70a912d8d875d88");
   my ($server, $user, $password, $apikey) = ("http://netredmine.m.redmine.org", "net-redmine-unit-tests", "net-redmine-unit-tests","7b7ae7e9f9aed7ffed823f55701bf745c119338c");
   return Net::RedmineRest->new(url => $server,user => $user, password => $password, apikey => $apikey);

}

sub new_net_redmine_project {
   my ($server, $user, $password, $apikey) = (
       "http://netredmine.m.redmine.org/projects/test", 
       "net-redmine-unit-tests", 
       "net-redmine-unit-tests",
       "7b7ae7e9f9aed7ffed823f55701bf745c119338c");
   return Net::RedmineRest->new(url => $server,user => $user, password => $password, apikey => $apikey);
}

sub project_test_data {
    my $identifier='test'. $$;
    my $name='testing' .$$;
    my $description='test'.$$.' project';
    my $homepage='http://www.test'.$$.'testing'.$$.'.nz';
    return ($identifier, $name ,$description, $homepage) 
}

use Text::Greeking;

sub new_tickets {
    my ($r, $n, $p) = @_;
    $n ||= 1;
    my $project_id;
    if ($p) {
       $project=$p;
    } elsif ( $r->project ){
      $project = $r->project;
    } 

    my $g = Text::Greeking->new;
    $g->paragraphs(1,1);
    $g->sentences(1,1);
    $g->words(8,24);

    my (undef, $filename, $line) = caller;

    return map {
        $r->create(
            ticket => {
                subject => "$filename, line $line " . $g->generate,
                project => $project,
                description => $g->generate
            }
        );
    } (1..$n);
}

1;
