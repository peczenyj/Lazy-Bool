package Lazy::Bool::Cached;
use parent 'Lazy::Bool';

use overload 
	'bool' => \&_to_bool;
	
sub new {
  my ($type, $code) = @_;
	
	my $klass = ref($type) || $type;
	
	my $ref = (ref($code) eq 'CODE')? $code : sub { $code };
	
	bless { 
	  code => $ref, 
	  cached => undef
	} => $klass
}

sub _to_bool {
  my ($self) = @_;
  
  # Yes, we can use this:
  # $self->{cached} //= $self->{code}->()
  # but the // operator is only supported from Perl 5.10.0
  # And this module will be compatible with old versions
  
  $self->{cached} = (defined $self->{cached})? $self->{cached} : $self->{code}->()
}

1;