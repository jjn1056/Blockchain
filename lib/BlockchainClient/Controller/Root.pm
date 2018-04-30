package BlockchainClient::Controller::Root;

use BlockchainClient::Controller;

sub root($self, $c) : At(/...) { }

  sub index($self, $c) : Via(root) At() {
    $c->serve_file('client/index.html');
  }

  sub make_transaction($self, $c) : Via(root) At('make/transaction') {
    $c->serve_file('client/make_transaction.html');
  }

  sub view_transaction($self, $c) : Via(root) At('view/transactions') {
    $c->serve_file('client/view_transactions.html');
  }

  sub static($self, $c, @args) : Via(root) At('static/{*}') {
    $c->serve_file('static', @args) || do {
      $c->res->status(404);
      $c->res->body('Not Found') };
  }

  sub new_wallet($self, $c) :GET Via(root) At('wallet/new') {
    my $pk = $c->model('KeyPair');
    return $c->view('WalletKey',
      private_key => $pk->export_private_key_b32b,
      public_key => $pk->export_public_key_b32b,
    )->http_ok;
  }

  sub generate_transaction($self, $c) :POST Via(root) At('generate/transaction') {
    my $transaction_form = $_->model('Form::Transaction');
    if($transaction_form->validated) {
      my $transaction = $c->model('Transaction', %{$transaction_form->fif});
      return $c->view('Transaction',
        signature => $transaction->sign_transaction,
        transaction_body => +{ $transaction->transaction_body },
      )->http_ok;
    } else {
      # TODO: return errors
    }
  }

__PACKAGE__->meta->make_immutable;
