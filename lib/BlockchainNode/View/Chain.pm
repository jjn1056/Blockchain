package BlockchainNode::View::Chain;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has chain => (is=>'ro', required=>1);
has length => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    chain => $self->chain,
    length => $self->length,
  };
}

__PACKAGE__->config( returns_status => [200] );
