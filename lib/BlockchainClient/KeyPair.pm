package BlockchainClient::KeyPair;

use Crypt::Misc 'encode_b32b';
use Crypt::PK::RSA;
use Moo;

has key_pair => (
  is=>'ro',
  required=>1,
  handles=>['export_key_der'],
  builder=>'_build_key_pair');

  sub _build_key_pair {
    my $pk = Crypt::PK::RSA->new;
    return $pk->generate_key;
  }

sub export_private_key_b32b {
  return encode_b32b(shift->export_key_der('private'));
}

sub export_public_key_b32b {
  return encode_b32b(shift->export_key_der('public'));
}

1;
