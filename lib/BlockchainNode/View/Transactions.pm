package BlockchainNode::View::Transactions;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has transactions => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    transactions => $self->transactions,
  };
}

__PACKAGE__->config( returns_status => [200] );
