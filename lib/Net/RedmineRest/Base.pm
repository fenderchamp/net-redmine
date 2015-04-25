package Net::RedmineRest::Base;
use Moo;

has response_code  => (is => "rw");
has service => ( is=>"rw",lazy=>1,builder=>1);

has connection => (
    is => "rw",
    required => 1,
    weak_ref => 1,
);
has json        => (is => "rw");

sub _build_service {
    my ($self) = @_;
    return $self->entity.'s';  #the project name
}


sub create {
    my ($class, %attr) = @_;

    my $self = $class->new(%attr);
    my $c=$self->connection;

    my $json_hashref=$self->_provide_data;

    my ($code,$response) = $c->POST(
         service=>$self->service,
         content=>$json_hashref
    );

    $self->response_code($code);
    if ($code == 201 ) { 
      $self->json($response->{$self->entity});
      $self->refresh();
      return $self;
    }  

}


sub load {
    my ($class, %attr) = @_;
    die "need specify project:id or project:identifier when loading it." unless defined $attr{id} || $attr{identifier};
    my $id = ($attr{id} || $attr{identifier});

    my $self = $class->new(%attr);

    my $c=$self->connection;
    my $service_url=$self->_service_url($id);
    my ($code,$content)=$c->GET($service_url);
    $self->response_code($code);
    
    if ( $code == 200 ) {
      $self->json($content->{$self->entity});
      $self->refresh();
      return $self;
    }
}


sub save {
    my ($self) = @_;
}

sub destroy {
    my ($self) = @_;
    $self->response_code(0);
    die "Cannot delete the ". $self->service() ." without id.\n" unless $self->id;
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
