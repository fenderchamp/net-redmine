package Test::Project;

use strict;
use Test::More qw(no_plan);
use Net::Redmine;
use Net::Redmine::Project;
use Moo;

has r           => ( is       => 'rw',
);

has identifier  => ( is => 'rw' );
has name        => ( is => 'rw' );
has description => ( is => 'rw' );
has homepage    => ( is => 'rw' );
has initialize  => ( is =>'ro');
has id           => ( is =>'rw');

sub BUILD {
    my $self = shift;
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

__PACKAGE__->meta->make_immutable;
1;
