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

% Define these predicates as dynamic
% current_predicate/1 will be true for these predicates.

:- dynamic fact_male     /1.
:- dynamic fact_female   /1.

:- dynamic fact_parent   /2.

:- dynamic fact_mother   /2.
:- dynamic fact_father   /2.

:- dynamic fact_sibling  /1.
:- dynamic fact_sibling  /2.

:- dynamic fact_sister   /2.
:- dynamic fact_brother  /2.

:- dynamic fact_child    /2.

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

female(X) :- fact_sister(X, _).

female(X) :- fact_mother(X, _).

male(X) :- fact_male(X).

male(X) :- fact_brother(X, _).

male(X) :- fact_father(X, _).

% Parent -----------------------------------------------------------------------

parent(X, Y) :- fact_parent(X, Y).

parent(X, Y) :- fact_mother(X, Y).

parent(X, Y) :- fact_father(X, Y).

parent(X, Y) :- fact_child(Y, X).

parent(X, Y) :-
    fact_child(L, X),
    is_list(L),
    member(Y, L).

parent(X, [Head | Tail]) :-
    parent(X, Head),
    parent(X, Tail).

% Sibling (recursion helper) ---------------------------------------------------

pairwise_sibling_HELPER(_, []).

pairwise_sibling_HELPER(X, [Head | Tail]) :-
    sibling(X, Head),
    pairwise_sibling_HELPER(X, Tail).

% Sibling ----------------------------------------------------------------------

sibling(X) :-
    \+ is_list(X),
    throw(error(Term, safe_assertz/1)).

sibling([X, Y]) :- sibling(X, Y).

sibling([Head | Tail]) :-
    write(Head),
    pairwise_sibling_HELPER(Head, Tail),
    sibling(Tail).

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

child(X, Y) :-
    fact_child(L, Y),
    is_list(L),
    member(X, L).

child(X, Y) :- parent(Y, X).

/* TODO: Red
   - grandfather
   - grandmother
   - daughter
   - son
   - aunt
   - uncle
   - related
 */