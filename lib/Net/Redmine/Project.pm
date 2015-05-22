package Net::Redmine::Project;
use Moo;
use Net::Redmine::IssueList;
use Net::Redmine::Base;
extends 'Net::Redmine::Base';

my $SERVICE_NAME='project';
has  entity => ( is=>"rw",default=>${SERVICE_NAME});

has  name => ( is=>"rw" );  #the project name
has  identifier => ( is=>"rw" ); #the project identifier
has  description => ( is=>"rw" );
has  homepage => ( is=>"rw" );
has  is_public => ( is=>"rw" ); #true or false
has  parent_id => ( is=>"rw" ); #the parent project number
has  created_on => ( is=>"rw" ); 
has  updated_on => ( is=>"rw" ); 
has  status => ( is=>"rw" ); 
has  issues => ( is=>"rw",lazy=>1,builder=>1 ); 
has  _issue_list => ( is=>"rw",lazy=>1,builder=>1 ); 

has  inherit_members => ( is=>"rw" ); #true or false
has  tracker_ids => ( is=>"rw",default => sub { return [] } ); #(repeatable element) the tracker id: 1 for Bug, etc.
has  enabled_module_names => ( is=>"rw" ); #(repeatable element) the module name: boards, calendar, documents, files, gantt, issue_tracking, news, repository, time_tracking, wiki.
  
has id          => (is => "rw");
has json        => (is => "rw");

sub _provide_data {

   my ($self)=@_;
    my $project;  
    $project->{created_on}=$self->created_on if (defined($self->created_on) );
    $project->{description}=$self->description if (defined($self->description) );
    $project->{homepage}=$self->homepage if (defined($self->homepage) );
    $project->{id}=$self->id if (defined($self->id) );
    $project->{identifier}=$self->identifier if (defined($self->identifier) );
    $project->{name}=$self->name if (defined($self->name) );
    $project->{status}=$self->status if (defined($self->status) );
    $project->{updated_on}=$self->udpated_on if (defined($self->updated_on) );
    foreach my $tracker_id (@{$self->tracker_ids}) {
       push @{$project->{tracker_ids}} ,$tracker_id;
    }


    my $content;
    $content->{project}=$project;
    return $content;

}

sub _build__issue_list {
   my ($self,%args)=@_;
   return Net::Redmine::IssueList->load(
        project_id=>$self->id,
        connection=>$self->connection
   );
}

sub _build_issues {
   my ($self,%args)=@_;
   return $self->_issue_list->issues();
}


sub refresh_from_json {

   my ($self,%args)=@_;
   my $json=$self->json;
   if ( $json ) {
      $self->created_on($json->{created_on});
      $self->description($json->{description});
      $self->homepage($json->{homepage});
      $self->id($json->{id});
      $self->identifier($json->{identifier});
      $self->name($json->{name});
      $self->status($json->{status});
      $self->updated_on($json->{created_on});
   } 
}

sub has_required_load_args {
   my ($self, %attr) = @_;
   my $id = ($attr{id} || $attr{identifier});
   unless ( $id ) {
      if ( $attr{connection} ) {
         $id=$attr{connection}->project;  
      }
    }  
    die "need id or identifier, or set project on connection when loading project." unless $id;
    return {id=>$id};
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::Redmine::Project - Represents a project.

=head1 SYNOPSIS

Creating a project
POST /projects.json
Parameters:

project (required): a hash of the project attributes, including:
  name (required): the project name
  identifier (required): the project identifier
  description
  homepage
  is_public: true or false
  parent_id: the parent project number
  inherit_members: true or false
  tracker_ids: (repeatable element) the tracker id: 1 for Bug, etc.
  enabled_module_names: (repeatable element) the module name: boards, calendar, documents, files, gantt, issue_tracking, news, repository, time_tracking, wiki.
  


=head1 DESCRIPTION



=cut
