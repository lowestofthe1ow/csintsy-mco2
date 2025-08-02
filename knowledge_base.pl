% Define these predicates as dynamic
% current_predicate/1 will be true for these predicates.

:- dynamic fact_male     /1.
:- dynamic fact_female   /1.

:- dynamic fact_parent   /2.
:- dynamic fact_mother   /2.
:- dynamic fact_father   /2.

:- dynamic fact_child    /2.
:- dynamic fact_daughter /2.
:- dynamic fact_son     /2.

:- dynamic fact_sibling  /1.
:- dynamic fact_sibling  /2.
:- dynamic fact_sister   /2.
:- dynamic fact_brother  /2.

:- dynamic fact_grandparent /2.
:- dynamic fact_grandfather /2.
:- dynamic fact_grandmother /2.

:- dynamic fact_aunt    /2.
:- dynamic fact_uncle   /2.

% Define a wrapper procedure around assertz()

% Case when asserting with a defined predicate and no contradictions (valid)
safe_assertz(Term) :-
     % "Extract" the functor name and arity from Term
    functor(Term, Name, Arity),
    current_predicate(Name/Arity),
    \+ contradiction(Term),
    assertz(Term).

% Case when asserting with an undefined predicate (invalid)
safe_assertz(Term) :-
    functor(Term, Name, Arity),
    \+ current_predicate(Name/Arity),
    % Throw unknown predicate error
    throw(error(unknown_predicate(Term), safe_assertz/1)).

% Case when asserting with a contradiction (invalid)
safe_assertz(Term) :-
    contradiction(Term),
    % Throw error
    throw(error(contradiction(Term), safe_assertz/1)).

% CONTRADICTION RULES ==========================================================

% Note: At the application level, we only assert "fact_" predicates

% Gender contradictions
contradiction(fact_female(X)) :- male(X).
contradiction(fact_male(X)) :- female(X).

% Sibling contradictions
contradiction(fact_sibling(X, X)) :- true.

contradiction(fact_sister(X, _)) :- male(X).
contradiction(fact_sister(X, X)) :- true.

contradiction(fact_brother(X, _)) :- female(X).
contradiction(fact_brother(X, X)) :- true.

% Parent contradictions
contradiction(fact_parent(X, X)) :- true.
contradiction(fact_parent(_, Y)) :- parent(A, Y), parent(B, Y), A \= B.

contradiction(fact_mother(X, _)) :- male(X).
contradiction(fact_mother(X, Y)) :- mother(Z, Y), X \= Z.
contradiction(fact_mother(X, X)) :- true.

contradiction(fact_father(X, _)) :- female(X).
contradiction(fact_father(X, Y)) :- father(Z, Y), X \= Z.
contradiction(fact_father(X, X)) :- true.

% Child contradictions
contradiction(fact_child(X, X)) :- true.

% Grandparent contradictions
contradiction(fact_grandfather(X, _)) :- female(X).
contradiction(fact_grandfather(X, X)) :- true.

contradiction(fact_grandmother(X, _)) :- male(X).
contradiction(fact_grandmother(X, X)) :- true.

% Daughter/Son contradictions
contradiction(fact_daughter(X, _)) :- male(X).
contradiction(fact_daughter(X, X)) :- true.

contradiction(fact_son(X, _)) :- female(X).
contradiction(fact_son(X, X)) :- true.

% Aunt/Uncle contradictions
contradiction(fact_aunt(X, _)) :- male(X).
contradiction(fact_aunt(X, X)) :- true.

contradiction(fact_uncle(X, _)) :- female(X).
contradiction(fact_uncle(X, X)) :- true.

% General catch: no one can be related to themselves
contradiction(fact_related(X, X)) :- true.

% Prevent someone from being both parent and sibling of same person
contradiction(fact_parent(X, Y)) :-
    sibling(X, Y).

% Prevent someone from being their own ancestor
contradiction(fact_parent(X, Y)) :-
    parent(Y, X).  % cycle: Y is also parent of X

% RULES ========================================================================

% Notation: parent(X, Y) should mean "X is a parent of Y"


fact_female(X) :- fact_daughter(X, _).

fact_female(X) :- fact_sister(X, _).

fact_female(X) :- fact_mother(X, _).

fact_female(X) :- fact_aunt(X, _).

fact_female(X) :- fact_grandmother(X, _).

fact_male(X) :- fact_son(X, _).

fact_male(X) :- fact_brother(X, _).

fact_male(X) :- fact_father(X, _).

fact_male(X) :- fact_uncle(X, _).

fact_male(X) :- fact_grandfather(X, _).

male(X) :- fact_male(X).

male(X) :- father(X, _).

female(X) :- fact_female(X).

female(X) :- mother(X, _).

% Parent -----------------------------------------------------------------------

parent(X, Y) :- fact_parent(X, Y).

parent(X, Y) :- fact_mother(X, Y).

parent(X, Y) :- fact_father(X, Y).

parent(X, Y) :- fact_child(Y, X).

parent(X, Y) :- fact_son(Y, X).

parent(X, Y) :- fact_daughter(Y, X).

parent(X, Y) :-
    fact_parent(X, L),
    is_list(L),
    member(Y, L).

parent(X, Y) :-
    fact_mother(X, L),
    is_list(L),
    member(Y, L).

parent(X, Y) :-
    fact_father(X, L),
    is_list(L),
    member(Y, L).

parent(X, Y) :-
    fact_child(L, X),
    is_list(L),
    member(Y, L).

parent(X, Y) :-
    fact_son(L, X),
    is_list(L),
    member(Y, L).

parent(X, Y) :-
    fact_daughter(L, X),
    is_list(L),
    member(Y, L).

parent(X, L) :-
    is_list(L),
    forall(member(Z, L), parent(X, Z)).

% Mother -----------------------------------------------------------------------

mother(X, Y) :- fact_mother(X, Y).

mother(X, Y) :- 
    parent(X, Y),
    parent(Z, Y),
    X \= Z,
    fact_male(Z).

mother(X, Y) :-
    parent(X, Y),
    fact_female(X).

% Father -----------------------------------------------------------------------

father(X, Y) :- fact_father(X, Y).

father(X, Y) :- 
    parent(X, Y),
    parent(Z, Y),
    X \= Z,
    fact_female(Z).

father(X, Y) :-
    parent(X, Y),
    fact_male(X).

% Child ------------------------------------------------------------------------

child(X, Y) :- parent(Y, X).

% Daughter ---------------------------------------------------------------------

daughter(X, Y) :- fact_daughter(X, Y).

daughter(X, Y) :-
    child(X, Y),
    female(X).

% Son --------------------------------------------------------------------------

son(X, Y) :- fact_son(X, Y).

son(X, Y) :-
    child(X, Y),
    male(X).

% Sibling ----------------------------------------------------------------------

% sibling/1 undefined for non-lists
sibling(X) :-
    \+ is_list(X),
    throw(error(_, safe_assertz/1)).

% Simple case: sibling/1 can directly map to sibling/2
sibling([X, Y]) :- sibling(X, Y).

% sibling/1 for a list: for all X and Y in list, X and Y are siblings
sibling(L) :-
    is_list(L),
    forall(member(X, L), forall((member(Y, L), X \== Y), sibling(X, Y))).

% sibling/2 for a list and an atom: for all X in list, X and Y are siblings
sibling(L, Y) :-
    is_list(L),
    \+ is_list(Y),
    forall(member(X, L), sibling(X, Y)).

sibling(Y, L) :-
    is_list(L),
    \+ is_list(Y),
    forall(member(X, L), sibling(X, Y)).

% sibling/2 for two lists: combine into a single list
sibling(L1, L2) :-
    is_list(L1),
    is_list(L2),
    append(L1, L2, L),
    sibling(L).

% sibling/2 for X and Y being part of the same list
sibling(X, Y) :- 
    fact_sibling(L),
    is_list(L),
    member(X, L),
    member(Y, L),
    X \== Y.

% sibling/2 for direct assertions with X and Y

% sibling/2 is commutative 
sibling(X, Y) :-
    fact_sibling(X, Y);
    fact_sibling(Y, X).

% sibling/2 should be inferrable from sibling/1
sibling(X, Y) :-
    fact_sibling([Y, X]);
    fact_sibling([X, Y]).

sibling(X, Y) :-
    fact_sister(X, Y);
    fact_sister(Y, X).

sibling(X, Y) :-
    fact_brother(X, Y);
    fact_brother(Y, X).

% Main definition
% Already commutative by definition
sibling(X, Y) :-
    \+ is_list(X),
    \+ is_list(Y),
    parent(Z, X),
    parent(Z, Y),
    X \== Y.

% Sister -----------------------------------------------------------------------

% TODO: Support for statements like "X and Y are sisters"

sister(X, Y) :- fact_sister(X, Y).

sister(X, Y) :-
    sibling(X, Y),
    female(X).

% Brother ----------------------------------------------------------------------

% TODO: Support for statements like "X and Y are brothers"

brother(X, Y) :-
    fact_brother(X, Y).

brother(X, Y) :-
    sibling(X, Y),
    male(X).

% Grandparent ------------------------------------------------------------------

grandparent(X, Y) :-
    fact_grandparent(X, Y).

grandparent(X, Y) :-
    parent(X, Z),
    parent(Z, Y).

% Grandfather ------------------------------------------------------------------

grandfather(X, Y) :-
    fact_grandfather(X, Y).

grandfather(X, Y) :-
    grandparent(X, Y),
    male(X).

% Grandmother ------------------------------------------------------------------

grandmother(X, Y) :-
    fact_grandmother(X, Y).

grandmother(X, Y) :-
    grandparent(X, Y),
    female(X).

% Aunt -------------------------------------------------------------------------

aunt(X, Y) :-
    fact_aunt(X, Y).

aunt(X, Y) :-
    sibling(X, Z),
    parent(Z, Y),
    female(X).

% Uncle ------------------------------------------------------------------------

uncle(X, Y) :-
    fact_uncle(X, Y).

uncle(X, Y) :-
    sibling(X, Z),
    parent(Z, Y),
    male(X).

% Related ----------------------------------------------------------------------

related(X, Y) :-
    parent(X, Y);
    parent(Y, X).

related(X, Y) :-
    sibling(X, Y).

% ancestor
related(X, Y) :-
    parent(P, Y),
    related(X, P).

% descendant
related(X, Y) :-
    parent(P, X),
    related(P, Y).

% X is a sibling of an ancestor of Y
related(X, Y) :-
    parent(P, Y),
    sibling(X, P).

% Y is a sibling of an ancestor of X
related(X, Y) :-
    parent(P, X),
    sibling(Y, P).
