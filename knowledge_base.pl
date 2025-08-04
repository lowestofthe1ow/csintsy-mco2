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

% Case when asserting with a defined predicate and no contradictions (valid)

safe_assertz(Term) :-
     % "Extract" the functor name and arity from Term
    valid_fact(Term),
    functor(Term, Name, Arity),
    current_predicate(Name/Arity),
    \+ contradiction(Term),
    assertz(Term).

safe_assertz(Term) :-
    contradiction(Term),
    % Throw error
    throw(error(contradiction(Term), safe_assertz/1)).

% Case when asserting with an undefined predicate (invalid)
safe_assertz(Term) :-
    valid_fact(Term),
    functor(Term, Name, Arity),
    \+ current_predicate(Name/Arity),
    % Throw unknown predicate error
    throw(error(unknown_predicate(Term), safe_assertz/1)).
    
% VALID FACTS ==================================================================
valid_fact(fact_parent(A, _)) :-
    (
        atom(A)
    ;
        is_list(A),
        length(A, Len), Len =< 2,
        maplist(atom, A)
    ).

valid_fact(fact_mother(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_father(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_child(A,B)) :-   
    atom(A), 
    (is_list(B); atom(B)).

valid_fact(fact_daughter(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_son(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_sibling(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_sister(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_brother(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_grandparent(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_grandfather(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_grandmother(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_aunt(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_uncle(A,B)) :- 
    atom(A),
    atom(B).

valid_fact(fact_male(L)) :-
    (   atom(L)
    ;   is_list(L), maplist(atom, L)
    ).

valid_fact(fact_female(L)) :-
    (   atom(L)
    ;   is_list(L), maplist(atom, L)
    ).


% CONTRADICTION RULES ==========================================================

% Note: At the application level, we only assert "fact_" predicates

% Gender contradictions
contradiction(fact_female(X)) :- male(X).
contradiction(fact_male(X)) :- female(X).

% Sibling contradictions
contradiction(fact_sibling(X, X)) :- true.
contradiction(fact_sibling(L, X)) :- is_list(L), member(X, L).
contradiction(fact_sibling(X, L)) :- is_list(L), member(X, L).
contradiction(fact_sibling(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

contradiction(fact_sister(X, _)) :- male(X).
contradiction(fact_sister(X, X)) :- true.

contradiction(fact_brother(X, _)) :- female(X).
contradiction(fact_brother(X, X)) :- true.

% Parent contradictions
contradiction(fact_parent(_, Y)) :- parent(L, Y), is_list(L), \+ length(L, 1).
contradiction(fact_parent(L, Y)) :- is_list(L), length(L, S1), findall(X, parent(X, Y), L2), length(L2, S2), S1+S2>2.
contradiction(fact_parent(L, _)) :- is_list(L), member(X, L), member(Y, L), male(X), male(Y), X \= Y.
contradiction(fact_parent(X, Y)) :- male(X), parent(Z, Y), male(Z).
contradiction(fact_parent(L, _)) :- is_list(L), member(X, L), member(Y, L), female(X), female(Y), X \= Y.
contradiction(fact_parent(X, Y)) :- female(X), parent(Z, Y), female(Z).

contradiction(fact_parent(X, X)) :- true.
contradiction(fact_parent(_, Y)) :- parent(A, Y), parent(B, Y), A \= B.
contradiction(fact_parent(X, Y)) :- parent(Y, X).
contradiction(fact_parent(L, X)) :- is_list(L), member(X, L).
contradiction(fact_parent(X, L)) :- is_list(L), member(X, L).
contradiction(fact_parent(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

contradiction(fact_mother(X, _)) :- male(X).
contradiction(fact_mother(X, Y)) :- mother(Z, Y), X \= Z.
contradiction(fact_mother(X, Y)) :- mother(Y, X).
contradiction(fact_mother(X, X)) :- true.
contradiction(fact_mother(L, _)) :- is_list(L), length(L, S), S>1.

contradiction(fact_father(X, _)) :- female(X).
contradiction(fact_father(X, Y)) :- father(Z, Y), X \= Z.
contradiction(fact_father(X, Y)) :- father(Y, X).
contradiction(fact_father(X, X)) :- true.
contradiction(fact_father(L, _)) :- is_list(L), length(L, S), S>1.

% Child contradictions
contradiction(fact_child(X, X)) :- true.
contradiction(fact_child(Y, _)) :- parent(A, Y), parent(B, Y), A \= B.
contradiction(fact_child(X, Y)) :- child(Y, X).


% Grandparent contradictions

contradiction(fact_grandparent(L, Y)) :- is_list(L), length(L, S1), findall(X, grandparent(X, Y), L2), length(L2, S2), S1+S2>4.
contradiction(fact_grandparent(_, Y)) :- findall(X, grandparent(X, Y), L), length(L, S), S>=4.
contradiction(fact_grandparent(X, Y)) :- grandparent(Y, X).
contradiction(fact_grandparent(X, X)) :- true.
contradiction(fact_grandparent(L, X)) :- is_list(L), member(X, L).
contradiction(fact_grandparent(X, L)) :- is_list(L), member(X, L).
contradiction(fact_grandparent(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

contradiction(fact_grandfather(X, _)) :- female(X).
contradiction(fact_grandfather(X, X)) :- true.
contradiction(fact_grandfather(X, Y)) :- grandfather(Y, X).
contradiction(fact_grandfather(_, Y)) :- grandfather(L, Y), is_list(L), \+ length(L, 1).
contradiction(fact_grandfather(_, Y)) :- grandfather(X, Y), grandfather(Z, Y), X \= Z.
contradiction(fact_grandfather(L, Y)) :- is_list(L), length(L, S1), findall(X, grandfather(X, Y), L2), length(L2, S2), S1+S2>2.

contradiction(fact_grandfather(X, X)) :- true.
contradiction(fact_grandfather(L, X)) :- is_list(L), member(X, L).
contradiction(fact_grandfather(X, L)) :- is_list(L), member(X, L).
contradiction(fact_grandfather(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

contradiction(fact_grandmother(X, _)) :- male(X).
contradiction(fact_grandmother(X, X)) :- true.
contradiction(fact_grandmother(X, Y)) :- grandmother(Y, X).
contradiction(fact_grandmother(_, Y)) :- grandmother(L, Y), is_list(L), \+ length(L, 1).
contradiction(fact_grandmother(L, Y)) :- is_list(L), length(L, S1), findall(X, grandmother(X, Y), L2), length(L2, S2), S1+S2>2.

contradiction(fact_grandmother(X, X)) :- true.
contradiction(fact_grandmother(L, X)) :- is_list(L), member(X, L).
contradiction(fact_grandmother(X, L)) :- is_list(L), member(X, L).
contradiction(fact_grandmother(_, Y)) :- grandmother(X, Y), grandmother(Z, Y), X \= Z.
contradiction(fact_grandmother(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

% Child/Daughter/Son contradictions
contradiction(fact_child(X, X)) :- true.
contradiction(fact_child(L, X)) :- is_list(L), member(X, L).
contradiction(fact_child(X, L)) :- is_list(L), member(X, L).
contradiction(fact_child(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).
contradiction(fact_child(_, L)) :- is_list(L), length(L, S), S>2.

contradiction(fact_daughter(X, _)) :- male(X).
contradiction(fact_daughter(X, X)) :- true.

contradiction(fact_daughter(X, X)) :- true.
contradiction(fact_daughter(X, Y)) :- daughter(Y, X).
contradiction(fact_daughter(L, X)) :- is_list(L), member(X, L).
contradiction(fact_daughter(X, L)) :- is_list(L), member(X, L).
contradiction(fact_daughter(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).
contradiction(fact_daughter(_, L)) :- is_list(L), length(L, S), S>2.

contradiction(fact_son(X, _)) :- female(X).
contradiction(fact_son(X, X)) :- true.

contradiction(fact_son(X, X)) :- true.
contradiction(fact_son(X, Y)) :- son(Y, X).
contradiction(fact_son(L, X)) :- is_list(L), member(X, L).
contradiction(fact_son(X, L)) :- is_list(L), member(X, L).
contradiction(fact_son(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).
contradiction(fact_son(_, L)) :- is_list(L), length(L, S), S>2.

% Aunt/Uncle contradictions
contradiction(fact_aunt(X, _)) :- male(X).
contradiction(fact_aunt(X, X)) :- true.
contradiction(fact_aunt(L, X)) :- is_list(L), member(X, L).
contradiction(fact_aunt(X, L)) :- is_list(L), member(X, L).
contradiction(fact_aunt(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

contradiction(fact_uncle(X, _)) :- female(X).
contradiction(fact_uncle(X, X)) :- true.
contradiction(fact_uncle(L, X)) :- is_list(L), member(X, L).
contradiction(fact_uncle(X, L)) :- is_list(L), member(X, L).
contradiction(fact_uncle(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

% General catch: no one can be related to themselves
contradiction(fact_related(X, X)) :- true.
contradiction(fact_related(L, X)) :- is_list(L), member(X, L).
contradiction(fact_related(X, L)) :- is_list(L), member(X, L).
contradiction(fact_related(L1, L2)) :- is_list(L1), is_list(L2), member(X, L1), member(X, L2).

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

male(List) :-
    is_list(List),
    forall(member(X, List), male(X)).

female(X) :- fact_female(X).

female(X) :- mother(X, _).

female(List) :-
    is_list(List),
    forall(member(X, List), female(X)).

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

%mother(X, Y) :- 
%    parent(Z, Y),
%    fact_father(X, Y),
%    X \= Z.

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

%father(X, Y) :- 
%    parent(Z, Y),
%    fact_mother(X, Y),
%    X \= Z.

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

sibling(X, Z) :-
    sibling(X, Y),
    sibling(Y, Z),
    X \= Z,
    ((father(FX, X), father(FY, Y), father(FZ, Z),
    FX \= FY, FX \= FZ, FY \= FZ) ;
    (mother(MX, X), mother(MY, Y), mother(MZ, Z),
    MX \= MY, MX \= MZ, MY \= MZ)).
   

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

grandparent(X, Y) :- fact_grandfather(X, Y).

grandparent(X, Y) :- fact_grandmother(X, Y).

grandparent(X, Y) :-
    parent(X, Z),
    parent(Z, Y).

grandparent(X, Y) :-
    fact_grandparent(X, L),
    is_list(L),
    member(Y, L).

grandparent(X, Y) :-
    fact_grandmother(X, L),
    is_list(L),
    member(Y, L).

grandparent(X, Y) :-
    fact_grandfather(X, L),
    is_list(L),
    member(Y, L).

grandparent(X, L) :-
    is_list(L),
    forall(member(Z, L), grandparent(X, Z)).

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
