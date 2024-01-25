# Equivalence of Applicative Functors and Multifunctors

This note spells out the equivalence of Haskell's `Applicative` functors (lax monoidal functors) with multi-functors (Haskell's `liftA` function family, functors in multi-categories).

That is, the somewhat Baroque equations for `pure` and `<*>` can be replaced by a uniform equation scheme for the `liftA` family.

See the [PDF](https://andreasabel.github.io/applicative/).
