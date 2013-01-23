package Lazy::Bool;

use 5.010000;
use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my $klass = shift;
	my $code  = shift;
	
	my $ref = (ref($code) eq 'CODE')? $code : sub { $code };
	
	bless $ref, $klass;
}

sub true {
	Lazy::Bool->new( 1 )
}

sub false {
	Lazy::Bool->new( 0 )
}

use overload 
	'bool' => \&_to_bool,
	'&'    => \&_and,
	'|'    => \&_or, 
	'!'    => \&_neg;

sub _to_bool {
	shift->()
}	

sub _and {
	my $a = shift;
	my $b = shift;
	
	Lazy::Bool->new(sub {
		$a->_to_bool & $b
	})
}

sub _or {
	my $a = shift;
	my $b = shift;
	
	Lazy::Bool->new(sub { 
		$a->_to_bool | $b
	})
}

sub _neg {
	my $a  = shift;
	Lazy::Bool->new(sub { 
			! $a->_to_bool
	})
}
1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Lazy::Bool - Boolean wrapper lazy

=head1 SYNOPSIS

  use Lazy::Bool;
  
  my $result = Lazy::Bool->new(sub{  
		# complex boolean expression
	});
	
	...
	if($result) { # now we evaluate the expression
		
	}

Using this module you can play with lazy booleans. Using expressions &, | and ! you can delay the expression evaluation until necessary.

=head1 DESCRIPTION

This is a proof-of-concept for a boolean wrapper using lazy initialization using pure perl.

The expression will be evaluated in boolean context, like

	if($lazy_boolean) { }
	unless($lazy_boolean) { }
	
	$lazy_boolean && $other  # for a lazy operation use the &
	$lazy_boolean || $other  # for a lazy operation use the | 

=head1 METHODS
	
=head2 new

The constructor, can receive one expression or a subroutine reference.

	use Lazy::Bool;

	my $result1 = Lazy::Bool->new( 1 );
	
	my $result2 = Lazy::Bool->new(sub{ 
		$a > $b && $valid 
	});

=head2 true

Returns a lazy true value

	use Lazy::Bool;
	
	my $true = Lazy::Bool::true;

=head2 false

Returns a lazy false value

	use Lazy::Bool;
	
	my $false = Lazy::Bool::false;

=head2 Overloaded Operators

=head3 Bit and '&'

Used as a logical and (&&), you can create operations between lazy booleans and scalars (will be changed to lazy).

	use Lazy::Bool;

	my $true = Lazy::Bool::true;
	my $false = Lazy::Bool::false;

	my $result = $true & $false;
	
  print "success" unless $result; # now will be evaluated!
	
Important: There is no shortcut if the first value is "false"
	
=head3 Bit or '|'

Used as a logical or (||), you can create operations between lazy booleans and scalars (will be changed to lazy).

	use Lazy::Bool;

	my $true = Lazy::Bool::true;
	my $false = Lazy::Bool::false;

	my $result = $true | $false;

  print "success" if $result; # now will be evaluated!

Important: There is no shortcut if the first value is "true"

=head3 Negation (!)

Used as a logical negation (not), you can create a lazy negation.

	use Lazy::Bool;

	my $false = Lazy::Bool::false;

	my $result = ! $false;

	print "success" if $result; # now will be evaluated!

=head2 EXAMPLES

A complex example:

	use Lazy::Bool;
	use Test::More tests=> 3;
	my $a = 6;
	my $b = 4;
	my $x  = Lazy::Bool->new(sub{ $a > $b });
	my $false = Lazy::Bool::false;
	
	my $result = ($x | $false) & ( ! ( $false & ! $false ) );
	
	# now the expressions will be evaluate
	ok($result,    "complex expression should be true");
	ok(!! $x ,  "double negation of true value should be true");	
	ok(!!! $false, "truple negation of false value should be true");	

=head2 TODO

There are lots of things to do. Please send me feedback! It is justa a P.O.C. but it can be useful in some situation.

For example, how we can add support to shortcut operations? or support && and || ?

And how about avoid evaluate the same boolean twice?
	
=head1 EXPORT

None 

=head1 SEE ALSO

 L<Scalar::Lazy> and L<Scalar::Defer>

=head1 AUTHOR

Tiago Peczenyj, E<lt>tiago.peczenyj@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Tiago Peczenyj

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
