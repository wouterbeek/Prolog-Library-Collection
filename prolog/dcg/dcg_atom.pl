:- module(
  dcg_atom,
  [
    atom_capitalize//0,
    atom_ci//1, % ?Atom:atom
    atom_ellipsis//2, % +Atom:atom
                      % +Ellipsis:positive_integer
    atom_lower//1, % ?Atom:atom
    atom_title//1, % ?Atom:atom
    atom_upper//1 % ?Atom:atom
  ]
).

/** <module> DCG atom

Grammar rules for processing atoms.

@author Wouter Beek
@version 2015/08
*/

:- use_module(library(atom_ext)).
:- use_module(library(dcg/basics)).
:- use_module(library(dcg/dcg_abnf)).
:- use_module(library(dcg/dcg_code)).
:- use_module(library(dcg/dcg_content)).
:- use_module(library(dcg/dcg_unicode)).
:- use_module(library(dcg/dcg_word)).





%! atom_capitalize// .

atom_capitalize, [Upper] -->
  [Lower],
  {code_type(Upper, to_upper(Lower))}, !,
  dcg_cp.
atom_capitalize --> [].



%! atom_ci(?Atom:atom)// .

atom_ci(A) -->
  dcg_atom('*'(code_ci, []), A).



%! atom_ellipsis(+Atom:atom, +Ellipsis:positive_integer)// .

atom_ellipsis(A, Ellipsis) -->
  {atom_truncate(A, Ellipsis, A0)},
  atom(A0).



%! atom_lower(?Atom:atom)// .

atom_lower(A) -->
  dcg_atom('*'(code_lower, []), A).



%! atom_title(?Atom:atom) // .

atom_title(A) -->
  {var(A)}, !,
  letter_uppercase(H),
  '*'(letter_lowercase, T, []),
  {atom_codes(A, [H|T])}.
atom_title('') --> "".
atom_title(A) -->
  {atom_codes(A, [H|T])},
  letter_uppercase(H),
  '*'(letter_lowercase, T, []).



%! atom_upper(?Atom:atom)// .

atom_upper(A) -->
  dcg_atom('*'(code_lower, []), A).