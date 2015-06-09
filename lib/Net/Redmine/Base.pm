package Net::Redmine::Base;
use Moo;


has connection => (
    is => "rw",
    required => 1,
    weak_ref => 1
);

has json      => (is => "rw");
has mech_self => ( is=>"rw");
has response_code  => (is => "rw");
has service => ( is=>"rw",lazy=>1,builder=>1);

sub _build_service {
    my ($self) = @_;
    return $self->entity.'s';  #the project name
}

sub save {
    my ($self) = @_; 

    my $c=$self->connection;
    die "cannot save ".$self->entity." without id" unless ( $self->id );

    my $json_hashref=$self->_provide_data();
    $json_hashref=$self->_provide_update_data(content=>$json_hashref) 
       if ($self->can('_provide_update_data'));

    my $id=delete $json_hashref->{$self->entity}->{id};

    my ($code,$response) = $c->PUT(
         service=>$self->service,
         content=>$json_hashref,
         id=>$id
    );
    if ($code =~ /^2/ ) { 
      $self->_reload(id=>$id);
    } else {
      die $self->entity ." save failed (ticket id = @{[ $self->id ]})\n"
   }
}

sub create {
    my ($class,%attr) = @_; 
    my $self = $class->new(%attr);

    my $c=$self->connection;

    my $json_hashref=$self->_provide_data;

    my ($code,$response) = $c->POST(
         service=>$self->service,
         content=>$json_hashref
    );

    $self->response_code($code);
    if ($code =~ /^2/ ) { 
      $self->json($response->{$self->entity});
      $self->_refresh();
      return $self;
    }  
    return $self->mech_create(%attr) if ( $self->can('mech_class_name') );
}

sub mech_load {
   my ($self,%args)=@_;
   my $class_name  = $self->mech_class_name();
   my $class       = "Net::Redmine::Mech::${class_name}";
   my $mech_object = $class->load(%args);
   return unless ( $mech_object );
   $self->mech_self($mech_object);
   return $self->mech_self();
}

sub mech_create {
   my ($self,%args)=@_;
   my $class_name  = $self->mech_class_name();
   my $class       = "Net::Redmine::Mech::${class_name}";
   my $mech_object = $class->create(%args);
   return unless ( $mech_object );
   $self->mech_self($mech_object);
   return $self->mech_self();
}


sub load_from_json {
    my ($class, %attr) = @_;
    return unless ($attr{json} && $attr{connection} ); 
    my $self = $class->new(%attr);
    $self->refresh_from_json;
    return $self;
}

sub load {
    my ($class, %attr) = @_;

    my $args;
    if ( $class->can('has_required_load_args')) { 
      $args=$class->has_required_load_args(%attr);
    }
    if ( $class->can('fetch_cache') ) {
       my $o=$class->fetch_cache(%attr); 
	     return $o if ( $o );
    }	

    my $self = $class->new(%attr);
    return $self if ( $self->_process_response($self->_get(%$args)) );
    return if ( $self->connection->rest_works );

    return $self->mech_load(%attr) if ( $self->can('mech_class_name') );

}

sub refresh {
    my ($self)=@_;
    $self->_reload;
}

sub _reload {
    my ($self)=@_;
    my $id=$self->id;
    $self->_process_response($self->_get(id=>$id));
}

sub _refresh {
   my ($self) = @_;
   $self->refresh_from_json() if $self->can('refresh_from_json');
   $self->cache if ( $self->can('cache') );
}	

sub _process_response {
    my ($self,$code,$content)=@_;
    if ( $code == 200 ) {
      $self->json($content->{$self->entity});
      $self->_refresh();
      return 1;
    }
    return;
}

sub _get { 
    my ($self, %attr) = @_;
    my $c=$self->connection;
    my $service_url=$self->_service_url(%attr);

    if ( $self->can('additional_get_params')) {
       my $param_string=$self->additional_get_params;
       $service_url=$service_url.'?'.$param_string if ( $param_string );
    }

    my ($code,$content)=$c->GET($service_url);
    $self->response_code($code);
    return($code,$content);
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
      $self->clean_cache() if ($self->can('clean_cache') );
    } 
    return $self->mech_self->destroy() if ( $self->can('mech_self') && $self->mech_self );
}


sub _service_url {
    my ($self,%args)=@_;
    my $id=$args{id};
    unless ($id)  {
       $id = $self->id if $self->can('id');
    }

    my $c = $self->connection;
    my $uri = URI->new($c->base_url);

    my $path='/'.$self->service;
    $path.='/'.$id if(defined($id));
    $path.='.json';

    $uri->path($path);
    return $uri->as_string;
}


sub clean_data {
   my ($self,$data)=@_;
   return {} unless ( ref($data) eq 'HASH' );

   foreach my $key (keys(%$data)) {
      delete ($data->{$key}) unless defined ( $data->{$key} );
   }
   return  $data;
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
