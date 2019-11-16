{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE RankNTypes            #-}
{-# LANGUAGE ConstraintKinds       #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds             #-}
{-# LANGUAGE RoleAnnotations       #-}
{-# LANGUAGE ViewPatterns          #-}
{-# LANGUAGE PatternSynonyms       #-}
{-# LANGUAGE ExistentialQuantification #-}

{-|
  Module      :  Theory.Named
  Copyright   :  (c) Matt Noonan 2018
  License     :  BSD-style
  Maintainer  :  matt.noonan@gmail.com
  Portability :  portable
-}

module Theory.Named
  ( -- * Named values
    Named, type (^::)
  , name
  , name2, name3
  , pattern New

  -- ** Definitions
  , Defining
  , Defn
  , defn
  ) where

import Data.The
import Data.Coerce

{--------------------------------------------------
  Named values
--------------------------------------------------}

-- | A value of type @name ^:: a@ has the same runtime
--   representation as a value of type @a@, with a
--   phantom "name" attached.
newtype Named a name = Named a
type role Named nominal nominal

-- | An infix alias for 'Named'.
type name ^:: a = Named a name

instance The (Named a name) a

-- Existential for the purpose of unceremoniously defining pattern 'New'.
-- If you need existentials in your own code, use 'Data.Refined.?|'.
data SomeNamed k a = forall (name :: k). SomeNamed (name ^:: a)
someNamed :: a -> SomeNamed k a
someNamed x = SomeNamed (Named x)

pattern New :: forall a k. () => forall (name :: k). (name ^:: a) -> a
pattern New t <- (someNamed -> SomeNamed t)

-- | Introduce a name for the argument, and pass the
--   named argument into the given function.
name :: a -> (forall name. name ^:: a -> t) -> t
name x k = k (coerce x)

-- | Same as 'name', but names two values at once.
name2 :: a -> b -> (forall name1 name2. (name1 ^:: a) -> (name2 ^:: b) -> t) -> t
name2 x y k = k (coerce x) (coerce y)

-- | Same as 'name', but names three values at once.
name3 :: a -> b -> c -> (forall name1 name2 name3. (name1 ^:: a) -> (name2 ^:: b) -> (name3 ^:: c) -> t) -> t
name3 x y z k = k (coerce x) (coerce y) (coerce z)


{--------------------------------------------------
  Definitions
--------------------------------------------------}

{-| Library authors can introduce new names in a controlled way
    by creating @newtype@ wrappers of @Defn@. The constructor of
    the @newtype@ should *not* be exported, so that the library
    can retain control of how the name is introduced. If a newtype
    wrapper of @Defn@ contains phantom parameters, these parameters
    should be given the @nominal@ type role; otherwise, library users
    may be able to use coercions to manipulate library-specific names
    in a manner not blessed by the library author.

@
newtype Bob = Bob Defn

bob :: Bob ^:: Int
bob = defn 42

newtype FooOf name = FooOf Defn
type role FooOf nominal -- disallow coerce :: FooOf name1 -> FooOf name2

fooOf :: (name ^:: Int) -> (FooOf name ^:: Int)
fooOf x = defn (the x)
@
-}
data Defn = Defn

-- | The @Defining P@ constraint holds in any module where @P@
--   has been defined as a @newtype@ wrapper of @Defn@. It
--   holds /only/ in that module, if the constructor of @P@
--   is not exported.
type Defining p = (Coercible p Defn, Coercible Defn p)

-- | In the module where the name @f@ is defined, attach the
--   name @f@ to a value.
defn :: Defining f => a -> (f ^:: a)
defn = coerce
