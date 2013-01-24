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

__END__
=head1 NAME

Lazy::Bool::Cached - Boolean wrapper lazy with memoize

=head1 SYNOPSIS

  use Lazy::Bool::Cached;

  my $result = Lazy::Bool::Cached->new(sub{  
  	# complex boolean expression
  });

  ...
  if($result) { # now we evaluate the expression
	
  }

  if($result) { # do not evaluate again. it is cached.

  }
Using this module you can play with lazy booleans. Using expressions &, | and ! you can delay the expression evaluation until necessary.

=head1 DESCRIPTION

This class extends Lazy::Bool
	
=head1 EXPORT

None 

=head1 SEE ALSO

L<Lazy::Bool>, L<Scalar::Lazy> and L<Scalar::Defer>

=head1 AUTHOR

Tiago Peczenyj, E<lt>tiago.peczenyj@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Tiago Peczenyj

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut