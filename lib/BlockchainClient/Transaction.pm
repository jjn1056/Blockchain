package BlockchainClient::Transaction;

use JSON::MaybeXS;
use Crypt::Misc 'decode_b32b', 'encode_b32b';
use Crypt::Digest::SHA1 'sha1';
use Crypt::PK::RSA;
use Data::Dumper;
use signatures;
use Moo;

# This creates a JSON encoder that forces keys to be
# alphabetically ordered.  Necessary because for the hashes
# to be correct the underlying string can't change.
my $JSON = JSON::MaybeXS->new(utf8 => 1, canonical=>1);

has [qw/sender_address
  sender_private_key
  recipient_address
  amount/] => (is=>'ro', required=>1);

sub transaction_body($self) {
  return +{
    sender_address => $self->sender_address,
    recipient_address => $self->recipient_address,
    value => $self->amount,
  };
}

sub sign_transaction($self) {
  my $sender_private_key = decode_b32b($self->sender_private_key);
  my $private_key = Crypt::PK::RSA->new(\$sender_private_key);
  my $hash = sha1($JSON->encode($self->transaction_body));
  return encode_b32b($private_key->sign_message($hash));
}

1;
