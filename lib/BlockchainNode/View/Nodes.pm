package BlockchainNode::View::Nodes;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has nodes => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    nodes => $self->nodes,
  };
}

__PACKAGE__->config( returns_status => [200] );
