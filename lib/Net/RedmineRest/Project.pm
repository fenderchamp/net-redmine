package Net::RedmineRest::Project;
use Moo;

my $SERVICE_NAME='projects';

has connection => (
    is => "rw",
    required => 1,
    weak_ref => 1,
);
has service       => (is => "rw", default=>$SERVICE_NAME);
has response_code  => (is => "rw");

has  name => ( is=>"rw" );  #the project name
has  identifier => ( is=>"rw" ); #the project identifier
has  description => ( is=>"rw" );
has  homepage => ( is=>"rw" );
has  is_public => ( is=>"rw" ); #true or false
has  parent_id => ( is=>"rw" ); #the parent project number
has  created_on => ( is=>"rw" ); 
has  updated_on => ( is=>"rw" ); 
has  status => ( is=>"rw" ); 

has  inherit_members => ( is=>"rw" ); #true or false
has  tracker_ids => ( is=>"rw" ); #(repeatable element) the tracker id: 1 for Bug, etc.
has  enabled_module_names => ( is=>"rw" ); #(repeatable element) the module name: boards, calendar, documents, files, gantt, issue_tracking, news, repository, time_tracking, wiki.
  
has id          => (is => "rw");
has json        => (is => "rw");


sub _build_project {
   my ($self)=@_;
   return $self->connection->project() 
       if $self->connection() && $self->connection->project_name(); 
}

sub create {
    my ($class, %attr) = @_;

    my $self = $class->new(%attr);
    my $c=$self->connection;

    my $project;  
    $project->{created_on}=$self->created_on if (defined($self->created_on) );
    $project->{description}=$self->description if (defined($self->description) );
    $project->{homepage}=$self->homepage if (defined($self->homepage) );
    $project->{id}=$self->id if (defined($self->id) );
    $project->{identifier}=$self->identifier if (defined($self->identifier) );
    $project->{name}=$self->name if (defined($self->name) );
    $project->{status}=$self->status if (defined($self->status) );
    $project->{updated_on}=$self->udpated_on if (defined($self->updated_on) );

    my $content;
    $content->{project}=$project;
    my ($code,$response) = $c->POST(
         service=>$self->service,
         content=>$content
    );

    $self->response_code($code);
    if ($code == 201 ) { 
$DB::single=1;
      $self->json($response->{project});
      $self->refresh();
      return $self;
    }  

}

sub load {
    my ($class, %attr) = @_;
    die "need specify project:id or project:identifier when loading it." unless defined $attr{id} || $attr{identifier};
    die "need connection object when loading projects." unless defined $attr{connection};
    my $id = ($attr{id} || $attr{identifier});

    my $self = $class->new(%attr);

    my $c=$self->connection;
    my $service_url=$self->_service_url($id);
    my ($code,$content)=$c->GET($service_url);
    $self->response_code($code);
    if ( $code == 200 ) {
      $self->json($content->{project});
      $self->refresh();
      return $self;
    }
}

sub refresh {

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

sub save {
    my ($self) = @_;
}

sub destroy {
    my ($self, %attr) = @_;
    $self->response_code(0);
    die "Cannot delete the project without id.\n" unless $self->id;
    my $service_url=$self->_service_url();
    my $c = $self->connection;
    my ($code,$content)=$c->DELETE($service_url);
    $self->response_code($code);
    if ( $code == 200 ) {
      $self->status('DELETED');
    } 
}

sub _service_url {
    my ($self,$id)=@_;
    $id = $self->id unless ($id); 

    my $c = $self->connection;
    my $uri = URI->new($c->base_url);

    my $path='/'.$self->service;
    $path.='/'.$id if($id);
    $path.='.json';

    $uri->path($path);
    return $uri->as_string;
}


__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

Net::RedmineRest::Project - Represents a project.

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
