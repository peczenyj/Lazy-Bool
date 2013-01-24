use Test::More tests => 11;

BEGIN { use_ok('Lazy::Bool::Cached') };

subtest "test package" => sub {
	plan tests => 3;
	
	require_ok('Lazy::Bool::Cached');
	new_ok('Lazy::Bool::Cached' => [ sub{} ]);
	isa_ok('Lazy::Bool::Cached', 'Lazy::Bool')  	
};

subtest "should be lazy" => sub {
	plan tests => 1;

	Lazy::Bool::Cached->new( sub{ 
		fail("should not be called"); 
	} );

	my $x = ! Lazy::Bool::Cached->new( sub{ 
		fail("should not be called"); 
	} );
	
	if (Lazy::Bool::Cached->new( sub{ 
		pass("should be called"); 
	} )) {}
};

subtest "should act as a boolean" => sub {
	plan tests => 6;
		
	ok(Lazy::Bool::Cached->new(sub{ 1 }),"should be true using sub");
	ok(Lazy::Bool::Cached->new( 1 ),     "should be true using literal");
	ok(Lazy::Bool::Cached->true,         "should be true using helper");
	
	ok(! Lazy::Bool::Cached->new(sub{ 0 }), "should be false using sub");
	ok(! Lazy::Bool::Cached->new( 0 ),      "should be false using literal");
	ok(! Lazy::Bool::Cached->false,         "should be false using helper");	
};

subtest "should be lazy in and/or operations" => sub {
	plan tests => 1;
		
	my $a = Lazy::Bool::Cached->new(sub{ fail("should not be called") });
	my $b = Lazy::Bool::Cached->new(sub{ fail("should not be called") });

	my $c = $a & $b; # operations using lazy - lazy
	my $d = $a | $b;
	
	my $e = $a & 1;  # operations using lazy - literal
	my $f = $a | 0;
	
	pass("ok");
};

subtest "should act as a boolean in and/or operations" => sub {
	plan tests => 10;
	my $true  = Lazy::Bool::Cached->new(sub{ 1 });
	my $false = Lazy::Bool::Cached->new(sub{ 0 });

	ok(   $true  & $true  ,"test -> true  & true");
	ok(! ($false & $true ),"test -> false & true");
	ok(! ($true  & $false),"test -> true  & false");
	ok(! ($false & $false),"test -> false & false");
	 
	ok(   $true  | $true  ,"test -> true  | true");
	ok(   $false | $true  ,"test -> false | true");
	ok(   $true  | $false ,"test -> true  | false");
	ok(! ($false | $false),"test -> false | false");
	
	my $a = Lazy::Bool::Cached->new(sub{ 1 });
	$a |= Lazy::Bool::Cached->new(sub{ 0 });
	
	ok($a, "test -> a |= false");
	
	my $b = Lazy::Bool::Cached->new(sub{ 1 });
	$b &= Lazy::Bool::Cached->new(sub{ 0 });
	
	ok(!$b, "test -> b &= false");	
};

subtest "should act as a boolean in and/or operations with non-lazy values" => sub {
	plan tests => 16;
	my $true  = Lazy::Bool::Cached->new(sub{ 1 });
	my $false = Lazy::Bool::Cached->new(sub{ 0 });

	ok(   $true  & 1 ,"test -> true  & 1");
	ok(! ($false & 1),"test -> false & 1");
	ok(! ($true  & 0),"test -> true  & 0");
	ok(! ($false & 0),"test -> false & 0");
	
	ok(   $true  | 1 ,"test -> true  | 1");
	ok(   $false | 1 ,"test -> false | 1");
	ok(   $true  | 0 ,"test -> true  | 0");
	ok(! ($false | 0),"test -> false | 0");	
	
	my $a = Lazy::Bool::Cached->new(sub{ 1 });
	$a |= 0;
	
	ok($a, "test -> a=true; a |= 0");
	isa_ok($a, 'Lazy::Bool::Cached'); 
	
	my $b = Lazy::Bool::Cached->new(sub{ 1 });
	
	$b &= 0;
	
	ok(!$b, "test -> b=true; b &= 0");
	isa_ok($b, 'Lazy::Bool::Cached'); 
		
	my $c = 1;
	
	$c |= Lazy::Bool::Cached->new(sub{ 0 });
	
	ok($c, "test -> c=1; c |= false");
	isa_ok($c, 'Lazy::Bool::Cached'); 
	
	my $d = 0;
	
	$d &= Lazy::Bool::Cached->new(sub{ 0 });
	
	ok(!$d, "test -> d=0; d |= false");
	isa_ok($d, 'Lazy::Bool::Cached'); 
};

subtest "complex test lazy" => sub {
	plan tests=> 1;
	my $true  = Lazy::Bool::Cached->new(sub{ fail("should be lazy") });
	my $false = Lazy::Bool::Cached->new(sub{ fail("should be lazy") });
	
	my $result1 = ($true | $false) & ( ! ( $false & ! $false ) );
	my $result2 = !! $true;
	my $result3 = !!! $false;
	pass("ok");
};

subtest "complex test" => sub {
	plan tests=> 3;
	my $true  = Lazy::Bool::Cached->new(sub{ 16 > 4 });
	my $false = Lazy::Bool::Cached->false;
	
	my $result = ($true | $false) & ( ! ( $false & ! $false ) );
	
	ok($result,    "complex expression should be true");
	ok(!! $true ,  "double negation of true value should be true");	
	ok(!!! $false, "truple negation of false value should be true");	
};

subtest "should not be short-circuit" => sub {
	plan tests => 2;
	
	ok(Lazy::Bool::Cached->true  | Lazy::Bool::Cached->new(sub{
		fail("should not be call"); 
		1 
	}) , "expression should be true");
	ok(! (Lazy::Bool::Cached->false & Lazy::Bool::Cached->new(sub{
		fail("should not be call"); 
		1 
	})), "expression should be true");
};

subtest "test NOT caching" => sub {
  plan tests => 1;
  my $i = 0;
  my $x = Lazy::Bool::Cached->new(sub { 
    $i++;
  });
    
  if($x){ }
  if($x){ }
  
  is($i,1 , "should call once");
}
