-- Workaround for codim bug
--codim Ideal := (I) -> (
--     mi := monomialIdeal leadTerm I;
--     sendgg(ggPush mi, ggcodim);
--     eePopInt())

-- gcd extended work around:
-- the ring R should have a single variable, otherwise this will
-- not be correct...
gcdExtended = (f,g) -> (
     sendgg(ggPush f, ggPush g, gggcdextended);
     v := new ring f;
     u := new ring f;
     {new ring f, u, v})

-- Check whether the homogeneous ideal I
-- is a complete intersection.
isCompleteIntersection = method()
isCompleteIntersection Ideal := (I) -> (
     -- 
     R := ring I;
     n := numgens I;
     n === 0 or (
     m := map(R^1, n, (i,j) -> R_j^((degree I_j)#0));
     (coker gens I).cache.poincare = poincare coker m;
     gb (gens I, Strategy=>LongPolynomial, Hilbert => poincare coker m);
     --OLD: remove(coker gens I, symbol poincare);
     codim I === n
     ))

-- Take n random combinations of the columns of M
randomColumns = (M,n) -> (
     d := numgens source M;
     R := ring M;
     ran := random(R^d, R^n);
     map(target M, , M * ran))

-- Random permutation
randomPermutation = (n) -> (
     m := new MutableList from toList (0..n-1);
     scan(1..n-1, i -> (
	       j := random i;
	       x := m#i;
	       m#i = m#j;
	       m#j = x;));
     new List from m)
     


-- Given a set of homogeneous elements p1, ..., pr, and
-- a degree d, find the subvector space of forms of degree d
-- generated by the subalgebra generated by p1..pr
subAlgebraBasis = (m,d) -> (
     R := ring m;
     n := numgens source m;
     k := coefficientRing R;
     M := monoid [Variables=>n,Degrees => degrees source m];
     R1 := k M;
     m1 := basis(d,R1);
     ideal substitute(m1, m))

expandPowerSeries = (a,n) -> (
     num := numerator a;
     den := denominator a;
     A := ring num;
     z := A_0;
     -- use extended gcd algorithm in A:
     ret := gcdCoefficients(den, z^n);
     --ret := gcdExtended(den, z^n);
     (num * (ret#1)) % z^n)

-- New simplify routine
simplify = method()
simplify (Matrix, ZZ) := (m,n) -> (
     sendgg(ggPush m, ggPush n, ggsimplify);
     getMatrix ring m)

-- Cyclotomic polynomials
cyclotomic = method()
cyclotomic (Ring, ZZ) := (R,n) -> (
     if numgens R === 0 then
         error "need a variable for cyclotomic polynomial!";
     cyclo := (d) -> (
	  F := R_0^d-1;
	  scan(1..d//2, i -> (
		    if d % i === 0 then (
		        G := cyclo(i);
			F = F//G)));
	  F);
     cyclo n)

///
R = ZZ/101[z]
scan(1..10, d -> print cyclotomic(R,d))

R = QQ[z]
scan(1..10, d -> print cyclotomic(R,d))

R = QQ[i]/(i^2+1)[a]
scan(1..10, d -> print cyclotomic(R,d))

///
///
size = method()
size Matrix := (m) -> (
     n := 0;
     scan(numgens target m, i ->
	  scan(numgens source m, j -> 
	       n = n + length(m_(i,j))));
     n)
///

     