package Test::Project;

use strict;
use Test::More qw(no_plan);
use Net::Redmine;
use Net::Redmine::Project;
use Moo;
use Text::Greeking;

has r           => ( is => 'rw',lazy=>1,builder=>1);
has identifier  => ( is => 'rw' );
has name        => ( is => 'rw' );
has description => ( is => 'rw' );
has homepage    => ( is => 'rw' );
has initialize  => ( is =>'ro');
has id           => ( is =>'rw');

sub BUILD {
    my $self = shift;

    my ( $identifier, $name, $description, $homepage ) = $self->project_test_data;
    $self->identifier($identifier);
    $self->name($name);
    $self->description($description);
    $self->homepage($homepage);

    if ( $self->initialize ) {
      $self->data_initialize();
    }
}



sub scrub_project_if_exists {

    my ($self) = @_;
    note 'delete the project if it exists (it probably shouldnt but whattever)';
    my $project = Net::Redmine::Project->load(
        connection => $self->r->connection,
        identifier => $self->identifier,
    );
    $project->destroy() if ( $project && $project->id );

    note 'confirm that it be gone';
    undef($project);

    $project = Net::Redmine::Project->load(
        connection => $self->r->connection,
        identifier => $self->identifier
    );
    ok( !$project, "no actual ".$self->name." project was found" );

}

sub create_project_and_verify_its_there {

    my ($self) = @_;
    note 'create it';
    my $project = Net::Redmine::Project->create(
        connection  => $self->r->connection,
        identifier  => $self->identifier,
        name        => $self->name,
        description => $self->description,
        homepage    => $self->homepage,
        tracker_ids => [1,2,3]
    );

    my $tag = ' created';
    $self->regular_tests( $project, $tag );

    my $id = $project->id;
    undef($project);
    note 'confirm that it be there load it by id';
    $project = Net::Redmine::Project->load(
        connection => $self->r->connection,
        id         => $id
    );

    $tag = ' loaded by id';
    $self->regular_tests( $project, $tag );
    undef($project);

    note 'confirm that it be there';
    $project = Net::Redmine::Project->load(
        connection => $self->r->connection,
        identifier => $self->identifier
    );

    $tag = ' loaded by identifier';
    $self->regular_tests( $project, $tag );
    return $project;
}

sub regular_tests {
    my ( $self, $project, $tag ) = @_;
    ok( $project, '$project found' . $tag );
    is( $project->name, $self->name, "name is ".$self->name." ".$tag );
    is( $project->identifier, $self->identifier,
        "identifier is ".$self->identifier." ". $tag );
    is( $project->description, $self->description,
        "description ".$self->description." project ". $tag );
    is( $project->homepage, $self->homepage,
        "homepage ".$self->homepage." ".$tag );
    my $id = $project->id;
    ok( $id, "project $id" );
}

sub data_initialize {
   my ( $self ) = @_;
	$self->scrub_project_if_exists();
	my $p=$self->create_project_and_verify_its_there();		
	my $url=$self->r->connection->{url}.'/projects/'.$self->identifier;
   $self->r->reset_connection(url=>$url);
   $self->id($p->id);

}

sub _build_r {

   my ($self)=@_;
   my ($server, $user, $password, $apikey);

   $server    = $ENV{REDMINE_TEST_SERVER};  
   $user      = $ENV{REDMINE_TEST_USER};  
   $password  = $ENV{REDMINE_TEST_PASSWORD};  
   $apikey    = $ENV{REDMINE_TEST_APIKEY};  

   return Net::Redmine->new(url => $server,user => $user, password => $password, apikey => $apikey);

}

sub project_test_data {

    my ($self,$u)=@_;
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


sub new_tickets {
    my ($self,$n) = @_;
    my $r=$self->r;
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


__PACKAGE__->meta->make_immutable;
1;
