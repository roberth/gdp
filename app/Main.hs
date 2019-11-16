{-# LANGUAGE GADTs           #-}
{-# LANGUAGE RoleAnnotations #-}
{-# LANGUAGE TypeOperators   #-}

module Main where

import           GDP

import qualified Data.List as L
import           Data.Ord

-- An unsafe merge. This relies on the user remembering to
-- sort both of the inputs using the same comparator passed
-- as the first argument to `unsafeMergeBy`. Otherwise, it
-- will produce nonsense.
unsafeMergeBy :: (a -> a -> Ordering) -> [a] -> [a] -> [a]
unsafeMergeBy comp xs ys = go xs ys
  where
    go [] ys' = ys'
    go xs' [] = xs'
    go (x:xs') (y:ys') = case comp x y of
      GT -> y : go (x:xs') ys'
      _  -> x : go xs' (y:ys')


-- Introduce a predicate `SortedBy comp`, indicating that
-- the value has been sorted by the comparator named `comp`.
newtype SortedBy comp name = SortedBy Defn
type role SortedBy nominal nominal

-- Sort a value using the comparator named `comp`. The
-- resulting value will satisfy `SortedBy comp`.
sortBy :: (comp ^:: (a -> a -> Ordering))
       -> [a]
       -> ([a] ?| SortedBy comp)
sortBy (The comp) xs = assert (L.sortBy comp xs)

-- Merge the two lists using the comparator named `comp`. The lists must
-- have already been sorted using `comp`, and the result will also be
-- sorted with respect to `comp`.
mergeBy :: (comp ^:: (a -> a -> Ordering))
        -> ([a] ?| SortedBy comp)
        -> ([a] ?| SortedBy comp)
        -> ([a] ?| SortedBy comp)
mergeBy (The comp) (The xs) (The ys) = assert (unsafeMergeBy comp xs ys)

newtype Opposite comp = Opposite Defn
type role Opposite nominal

-- A named version of the opposite ordering.
opposite :: (comp ^:: (a -> a -> Ordering))
         -> (Opposite comp ^:: (a -> a -> Ordering))
opposite (The comp) = defn $ \x y -> case comp x y of
  GT -> LT
  EQ -> EQ
  LT -> GT

newtype Reverse xs = Reverse Defn
type role Reverse nominal

-- A named version of Prelude's 'reverse'.
rev :: (xs ^:: [a]) -> (Reverse xs ^:: [a])
rev (The xs) = defn (reverse xs)

-- A lemma about reversing sorted lists.
rev_ord_lemma :: SortedBy comp xs -> Proof (SortedBy (Opposite comp) (Reverse xs))
rev_ord_lemma _ = axiom

-- Usage example.
main :: IO ()
main = do
  name compare $ \up -> do

    -- Read two lists and sort them in ascending order, then
    -- merge them and print the result.
    xs <- sortBy up <$> (readLn :: IO [Int])
    ys <- sortBy up <$> readLn
    let ans1 = mergeBy up xs ys
    print (the ans1)

    -- Now reverse the two lists and merge them using the
    -- descending comparator. This requires a proof that
    -- the reversed lists are sorted by the opposite of `up`,
    -- which we provide using (.|).
    let down = opposite up
        ans2 = mergeBy down (rev' xs) (rev' ys)
        rev' = rev .| rev_ord_lemma
    print (the ans2)
