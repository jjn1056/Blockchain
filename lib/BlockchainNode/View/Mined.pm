package BlockchainNode::View::Mined;
 
use signatures;
use Moo;
 
extends 'Catalyst::View::Base::JSON';

has message => (is=>'ro', required=>1);
has block_number => (is=>'ro', required=>1);
has transactions => (is=>'ro', required=>1);
has nonce => (is=>'ro', required=>1);
has previous_hash => (is=>'ro', required=>1);

sub TO_JSON($self) {
  return +{
    message => $self->message,
    block_number => $self->block_number,
    transactions => $self->transactions,
    nonce => $self->nonce,
    previous_hash => $self->previous_hash,
  };
}

__PACKAGE__->config( returns_status => [200] );
