module util_collections_sets_i {

lemma ThingsIKnowAboutSubset<T>(x:set<T>, y:set<T>)
    requires x<y;
    ensures |x|<|y|;
{
    if (x!={}) {
        var e :| e in x;
        ThingsIKnowAboutSubset(x-{e}, y-{e});
    }
}

lemma SubsetCardinality<T>(x:set<T>, y:set<T>)
    ensures x<y ==> |x|<|y|;
    ensures x<=y ==> |x|<=|y|;
{
    if (x<y) {
        ThingsIKnowAboutSubset(x, y);
    }
    if (x==y) { // OBSERVE the other case
    }
}

lemma ItIsASingletonSet<T>(foo:set<T>, x:T)
    requires foo=={x};
    ensures |foo|==1;
{
}

lemma ThingsIKnowAboutASingletonSet<T>(foo:set<T>, x:T, y:T)
    requires |foo|==1;
    requires x in foo;
    requires y in foo;
    ensures x==y;
{
    if (x!=y) {
        assert {x} < foo;
        ThingsIKnowAboutSubset({x}, foo);
        assert |{x}| < |foo|;
        assert |foo|>1;
        assert false;
    }
}

predicate Injective<X(!new), Y>(f:X->Y)
{
  forall x1, x2 :: f(x1) == f(x2) ==> x1 == x2
}

predicate InjectiveOver<X, Y>(xs:set<X>, ys:set<Y>, f:X->Y)
{
  forall x1, x2 :: x1 in xs && x2 in xs && f(x1) in ys && f(x2) in ys && f(x1) == f(x2) ==> x1 == x2
}

predicate InjectiveOverSeq<X, Y>(xs:seq<X>, ys:set<Y>, f:X->Y)
{
  forall x1, x2 :: x1 in xs && x2 in xs && f(x1) in ys && f(x2) in ys && f(x1) == f(x2) ==> x1 == x2
}

predicate Inverses<X(!new), Y(!new)>(f1:X->Y, f2:Y->X)
{
    && forall x :: f2(f1(x)) == x
    && forall y :: f1(f2(y)) == y
}

lemma lemma_MapSetCardinality<X, Y>(xs:set<X>, ys:set<Y>, f:X->Y)
  requires Injective(f);
  requires forall x :: x in xs <==> f(x) in ys;
  requires forall y :: y in ys ==> exists x :: x in xs && y == f(x);
  ensures  |xs| == |ys|;
{
  if (xs != {})
  {
    var x :| x in xs;
    var xs' := xs - {x};
    var ys' := ys - {f(x)};
    lemma_MapSetCardinality(xs', ys', f);
  }
}

lemma lemma_MapSetCardinalityOver<X, Y>(xs:set<X>, ys:set<Y>, f:X->Y)
  requires InjectiveOver(xs, ys, f);
  requires forall x :: x in xs ==> f(x) in ys;
  requires forall y :: y in ys ==> exists x :: x in xs && y == f(x);
  ensures  |xs| == |ys|;
{
  if (xs != {})
  {
    var x :| x in xs;
    var xs' := xs - {x};
    var ys' := ys - {f(x)};
    lemma_MapSetCardinalityOver(xs', ys', f);
  }
}

lemma lemma_MapSubsetCardinalityOver<X, Y>(xs:set<X>, ys:set<Y>, f:X->Y)
  requires InjectiveOver(xs, ys, f);
  requires forall x :: x in xs ==> f(x) in ys;
  ensures  |xs| <= |ys|;
{
  if (xs != {})
  {
    var x :| x in xs;
    var xs' := xs - {x};
    var ys' := ys - {f(x)};
    lemma_MapSubsetCardinalityOver(xs', ys', f);
  }
}

lemma lemma_MapSubseqCardinalityOver<X, Y>(xs:seq<X>, ys:set<Y>, f:X->Y)
  requires forall i, j :: 0 <= i < |xs| && 0 <= j < |xs| && i != j ==> xs[i] != xs[j];
  requires InjectiveOverSeq(xs, ys, f);
  requires forall x :: x in xs ==> f(x) in ys;
  ensures  |xs| <= |ys|;
{
  if (xs != [])
  {
    var x := xs[0];
    var xs' := xs[1..];
    var ys' := ys - {f(x)};
    forall x' | x' in xs'
        ensures f(x') in ys';
    {
        assert x' in xs;
        assert f(x') in ys;
        if f(x') == f(x)
        {
            assert x in xs && x' in xs && f(x) in ys && f(x') in ys && f(x') == f(x);
            assert x' == x;
        }
    }
    forall x1, x2 | x1 in xs' && x2 in xs' && f(x1) in ys' && f(x2) in ys' && f(x1) == f(x2)
        ensures x1 == x2;
    {
        assert x1 in xs && x2 in xs && f(x1) in ys && f(x2) in ys';
    }
    lemma_MapSubseqCardinalityOver(xs', ys', f);
  }
}

function MapSetToSet<X(!new), Y>(xs:set<X>, f:X->Y) : (ys:set<Y>)
  requires Injective(f);
  ensures  forall x :: x in xs <==> f(x) in ys;
  ensures  |xs| == |ys|;
{
  var ys := set x | x in xs :: f(x); 
  lemma_MapSetCardinality(xs, ys, f);
  ys
}

function MapSetToSetBijective<X(!new), Y(!new)>(xs:set<X>, f:X->Y, f_inv:Y->X):(ys:set<Y>)
  requires Inverses(f, f_inv)
  ensures  forall x :: x in xs <==> f(x) in ys
  ensures  forall y :: y in ys <==> f_inv(y) in xs
  ensures  |xs| == |ys|
{
  var ys := set x | x in xs :: f(x); 
  lemma_MapSetCardinality(xs, ys, f);
  ys
}

function MapSetToSetOver<X, Y>(xs:set<X>, f:X->Y):set<Y>
  requires InjectiveOver(xs, set x | x in xs :: f(x), f);
  ensures  forall x :: x in xs ==> f(x) in MapSetToSetOver(xs, f);
  ensures  |xs| == |MapSetToSetOver(xs, f)|;
{
  var ys := set x | x in xs :: f(x); 
  lemma_MapSetCardinalityOver(xs, ys, f);
  ys
}

function MapSeqToSet<X(!new), Y>(xs:seq<X>, f:X->Y):set<Y>
  requires Injective(f);
  ensures  forall x :: x in xs <==> f(x) in MapSeqToSet(xs, f);
{
  set x | x in xs :: f(x)
}

lemma lemma_SubsetCardinality<X>(xs:set<X>, ys:set<X>, f:X->bool)
  requires forall x :: x in ys ==> x in xs && f(x);
  ensures  |ys| <= |xs|;
{
  if (ys != {})
  {
    var y :| y in ys;
    var xs' := xs - {y};
    var ys' := ys - {y};
    lemma_SubsetCardinality(xs', ys', f);
  }
}

function/*TODO:{:opaque}*/ MakeSubset<X(!new)>(xs:set<X>, f:X->bool):set<X>
  ensures  forall x :: x in MakeSubset(xs, f) <==> x in xs && f(x);
  ensures  |MakeSubset(xs, f)| <= |xs|;
{
  var ys := set x | x in xs && f(x);
  lemma_SubsetCardinality(xs, ys, f);
  ys
}

/* examples:
function{:opaque} setAdd1(xs:set<int>):set<int>
  ensures forall x :: x in xs <==> x + 1 in setAdd1(xs);
  ensures |xs| == |setAdd1(xs)|;
{
  MapSetToSet(xs, x => x + 1)
}

function{:opaque} setPos(xs:set<int>):set<int>
  ensures forall x :: x in setPos(xs) <==> x in xs && x > 0;
{
  MakeSubset(xs, x => x > 0)
}
*/

lemma lemma_UnionCardinality<X>(xs:set<X>, ys:set<X>, us:set<X>)
    requires us==xs+ys;
    ensures |us| >= |xs|;
    decreases ys;
{
    if (ys=={}) {
    } else {
        var y :| y in ys;
        if (y in xs) {
            var xr := xs - {y};
            var yr := ys - {y};
            var ur := us - {y};
            lemma_UnionCardinality(xr, yr, ur);
        } else {
            var ur := us - {y};
            var yr := ys - {y};
            lemma_UnionCardinality(xs, yr, ur);
        }
    }
}

function SetOfNumbersInRightExclusiveRange(a:int, b:int):set<int>
    requires a <= b;
    ensures forall opn :: a <= opn < b ==> opn in SetOfNumbersInRightExclusiveRange(a, b);
    ensures forall opn :: opn in SetOfNumbersInRightExclusiveRange(a, b) ==> a <= opn < b;
    ensures |SetOfNumbersInRightExclusiveRange(a, b)| == b-a;
    decreases b-a;
{
    if a == b then {} else {a} + SetOfNumbersInRightExclusiveRange(a+1, b)
}

lemma lemma_CardinalityOfBoundedSet(s:set<int>, a:int, b:int)
    requires forall opn :: opn in s ==> a <= opn < b;
    requires a <= b;
    ensures  |s| <= b-a;
{
    var range := SetOfNumbersInRightExclusiveRange(a, b);
    forall i | i in s
        ensures i in range;
    {
    }
    assert s <= range;
    SubsetCardinality(s, range);
}

function intsetmax(s:set<int>):int
    requires |s| > 0;
    ensures  var m := intsetmax(s);
             m in s && forall i :: i in s ==> m >= i;
{
    var x :| x in s;
    if |s| == 1 then
        assert |s - {x}| == 0;
        x
    else
        var sy := s - {x};
        var y := intsetmax(sy);
        assert forall i :: i in s ==> i in sy || i == x;
        if x > y then x else y
}

} 
