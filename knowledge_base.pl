test :-
    assertz(fact_sibling(riku, amane)),
    assertz(fact_child(riku, misaki)),
    assertz(fact_female(misaki)),
    assertz(fact_child(amane, asuka)),
    assertz(fact_female(asuka)),
    assertz(fact_sibling(noa, amane)),
    assertz(fact_child(noa, mashiro)),
    sibling(riku, noa),
    assertz(fact_female(mashiro)),
    sibling(riku, noa).

test2 :-
    assertz(fact_aunt(x, z)),
    related(x, z).

% Define these predicates as dynamic
% current_predicate/1 will be true for these predicates.

:- dynamic fact_male     /1.
:- dynamic fact_female   /1.

:- dynamic fact_parent   /2.
:- dynamic fact_grandparent /2.

:- dynamic fact_grandfather /2.
:- dynamic fact_grandmother /2.

:- dynamic fact_mother   /2.
:- dynamic fact_father   /2.

:- dynamic fact_sibling  /1.
:- dynamic fact_sibling  /2.

:- dynamic fact_aunt    /2.
:- dynamic fact_uncle   /2.

:- dynamic fact_sister   /1.
:- dynamic fact_sister   /2.

:- dynamic fact_brother  /1.
:- dynamic fact_brother  /2.

:- dynamic fact_child    /2.

:- dynamic fact_daughter /2.
:- dynamic fact_son     /2.

% Define a wrapper procedure around assertz()
% TODO: Combine into a single procedure instead of splitting into 3

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

% TODO: Nicole

contradiction(fact_female(X)) :- male(X).

contradiction(fact_male(X)) :- female(X).

contradiction(fact_sister(X, X)) :- true.

contradiction(fact_sister(X, _)) :- male(X).

contradiction(fact_brother(X, X)) :- true.

contradiction(fact_brother(X, _)) :- female(X).

contradiction(fact_mother(X, X)) :- true.

contradiction(fact_mother(X, _)) :- male(X).

contradiction(fact_father(X, X)) :- true.

contradiction(fact_father(X, _)) :- female(X).

contradiction(fact_child(X, X)) :- true.

contradiction(fact_child(X, Y)) :- 
    \+ is_list(X), 
    parent(X, Y).

% RULES ========================================================================

% Notation: parent(X, Y) should mean "X is a parent of Y"

female(X) :- fact_female(X).

female(X) :- fact_daughter(X, _).

female(X) :- fact_sister(X, _).

female(X) :- fact_mother(X, _).

female(X) :- fact_aunt(X, _).

female(X) :- fact_grandmother(X, _).

male(X) :- fact_male(X).

male(X) :- fact_son(X, _).

male(X) :- 
    fact_son(L, _),
    is_list(L),
    member(X, L).

male(X) :- fact_brother(X, _).

male(X) :- fact_father(X, _).

male(X) :- fact_uncle(X, _).

male(X) :- fact_grandfather(X, _).

% Parent -----------------------------------------------------------------------

parent(X, X) :- !, false.

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
    female(X).

% Father -----------------------------------------------------------------------

father(X, Y) :- fact_father(X, Y).

father(X, Y) :-
    parent(X, Y),
    male(X).

% Child ------------------------------------------------------------------------

child(X, Y) :- fact_child(X, Y).

child(X, Y) :- parent(Y, X).

% Son --------------------------------------------------------------------------

son(X, Y) :- fact_son(X, Y).

son(X, Y) :-
    child(X, Y),
    male(X).

% Sibling ----------------------------------------------------------------------

sibling(X) :-
    \+ is_list(X),
    throw(error(Term, safe_assertz/1)).

sibling([X, Y]) :- sibling(X, Y).

sibling(L) :-
    is_list(L),
    forall(member(X, L), forall((member(Y, L), X \== Y), sibling(X, Y))).

sibling(X, X) :- false.

sibling(X, Y) :-
    is_list(X),
    is_list(Y),
    append(X, Y, L),
    sibling(L).

sibling(X, Y) :- 
    fact_sibling(L),
    is_list(L),
    member(X, L),
    member(Y, L),
    X \== Y.

sibling(X, Y) :- 
    fact_brother(L),
    is_list(L),
    member(X, L),
    member(Y, L),
    X \== Y.

sibling(X, Y) :- 
    fact_sister(L),
    is_list(L),
    member(X, L),
    member(Y, L),
    X \== Y.

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

sister(X, Y) :- fact_sister(X, Y).

sister(X, Y) :-
    sibling(X, Y),
    female(X).

% Brother ----------------------------------------------------------------------

brother(X, Y) :-
    fact_brother(X, Y).

brother(X, Y) :-
    sibling(X, Y),
    male(X).

/* TODO: Red
   - grandfather
   - grandmother
   - daughter
   - son
   - aunt
   - uncle
   - related
 */

 % Grandparent
 grandparent(X, Y) :-
    fact_grandparent(X, Y).

grandparent(X, Y) :-
    parent(X, Z),
    parent(Z, Y).
    

% Grandfather 

grandfather(X, Y) :-
    fact_grandfather(X, Y).

grandfather(X, Y) :-
    grandparent(X, Y),
    male(X).

% Grandmother

grandmother(X, Y) :-
    fact_grandmother(X, Y).

grandmother(X, Y) :-
    grandparent(X, Y),
    female(X).
    
% Daughter

daughter(X, Y) :-
    fact_daughter(X, Y).

daughter(X, Y) :-
    parent(Y, X),
    female(X).

% Son
son(X, Y) :-
    fact_son(X, Y).

son(X, Y) :-
    parent(Y, X),
    male(X).

% Aunt   

aunt(X, Y) :-
    fact_aunt(X, Y).

aunt(X, Y) :-
    sibling(X, Z),
    parent(Z, Y),
    female(X).

% Uncle

uncle(X, Y) :-
    fact_uncle(X, Y).

uncle(X, Y) :-
    sibling(X, Z),
    parent(Z, Y),
    male(X).


related(X,Y) :-
    parent(X,Y),  !.
related(X,Y) :-
    parent(Y,X),  !.
related(X,Y) :-
    sibling(X,Y), !.
related(X,Y) :-
    grandparent(X,Y), !.
related(X,Y) :-
    grandparent(Y,X), !.
related(X,Y) :-
    aunt(X,Y), !.
related(X,Y) :-
    aunt(Y,X), !.
related(X,Y) :-
    uncle(X,Y), !.
related(X,Y) :-
    uncle(Y,X), !.
