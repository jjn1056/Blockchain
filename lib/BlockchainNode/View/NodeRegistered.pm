package BlockchainNode::View::NodeRegistered;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has message => (is=>'ro', required=>1);
has total_nodes => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    message => $self->message,
    total_nodes => $self->total_nodes,
  };
}

__PACKAGE__->config( returns_status => [201] );
