use Test::More;
use Cwd 'getcwd';

use Net::Redmine;


END {
    # system "kill -9 $REDMINE_SERVER_PID" if $REDMINE_SERVER_PID
}

sub new_net_redmine {

   my ($server, $user, $password, $apikey);

   $server    = $ENV{REDMINE_TEST_SERVER};  
   $user      = $ENV{REDMINE_TEST_USER};  
   $password  = $ENV{REDMINE_TEST_PASSWORD};  
   $apikey    = $ENV{REDMINE_TEST_APIKEY};  

   return Net::Redmine->new(url => $server,user => $user, password => $password, apikey => $apikey);

}

sub project_test_data {

    my $u=$_[1];
    my $unique;
    while ( !($unique) ) {
      my $pid=$$;
      my $r = int(rand()*100);
      $unique="${pid}${r}";
      last unless ( $u && $unique == $u );
    };

    my $identifier='test'. $unique;
    my $name='testing' .$unique;
    my $description='test'.$unique.' project';
    my $homepage='http://www.test'.$unique.'testing'.$unique.'.nz';
    return ($identifier, $name ,$description, $homepage);
}

use Text::Greeking;

sub new_tickets {
    my ($r, $n) = @_;
    $n ||= 1;
    my $g = Text::Greeking->new;
    $g->paragraphs(1,1);
    $g->sentences(1,1);
    $g->words(8,24);

    my (undef, $filename, $line) = caller;

    return map {
        $r->create(
            ticket => {
                subject => "$filename, line $line " . $g->generate,
                description => $g->generate
            }
        );
    } (1..$n);
}

1;
