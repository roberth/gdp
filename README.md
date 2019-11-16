# gdp: Ghosts of Departed Proofs


This package implements the [Ghosts of Departed Proofs](https://kataskeue.com/gdp.pdf) paper, with some changes.


### Operator mnemonics

General patterns:

 - `^` types and operations that include a type-level name for a value
    - `^__` operator on the value (think left side of `::`)
    - `__^` operator on the proof
 - `?` like `^`, but the type level name is hidden in the constructor (existential type)
 - `^|`, `?|`, `.|` all construct/deconstruct a proof

Operators


### Operator overview


| Location                               | Level  | Operator          | Meaning 
| -------------------------------------- | :----: | :---------------: | -------
| [Theory.Named](src/Theory/Named.hs)    | type   | `name ^:: a`      | A value of type `a` which is identified by the type level name `name`.
| [Data.Refined](src/Data/Refined.hs)    | type   | `a ^| p`          | A value of type `a` and a claim of proof `p`
| [Data.Refined](src/Data/Refined.hs)    | value  | `a ^| p`          | A value of type `a` forgetting any value for proof `p`
| [Data.Refined](src/Data/Refined.hs)    | value  | `f ^$ (a ^| p)`   | Apply a function to `a`, like `$`
| [Data.Refined](src/Data/Refined.hs)    | value  | `f >>=^ (a ^| p)` | Apply an implication to `p`, `>>=` on the proof
| [Data.Refined](src/Data/Refined.hs)    | value  | `f .| g`          | A function on `?|`s, constructed from a function and implication from pre- to postcondition
