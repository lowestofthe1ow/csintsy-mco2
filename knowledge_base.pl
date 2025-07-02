% Define these predicates as dynamic
% current_predicate/1 will be true only for these predicates.

:- dynamic fact_male     /1.
:- dynamic fact_female   /1.

:- dynamic fact_parent   /2.

:- dynamic fact_mother   /2.
:- dynamic fact_father   /2.

:- dynamic fact_sibling  /1.
:- dynamic fact_sibling  /2.

:- dynamic fact_sister   /2.
:- dynamic fact_brother  /2.

% Define a wrapper procedure around assertz()

% Case when asserting with a defined predicate (valid)
safe_assertz(Term) :-
     % "Extract" the functor name and arity from Term
    functor(Term, Name, Arity),
    current_predicate(Name/Arity),
    assertz(Term).

% Case when asserting with an undefined predicate (invalid)
safe_assertz(Term) :-
    functor(Term, Name, Arity),
    \+ current_predicate(Name/Arity),
    write('Error: Unknown predicate'), % Throw error
    fail.

% RULES ========================================================================
% Notation: parent(X, Y) should mean "X is a parent of Y"
%===============================================================================

female(X) :- fact_female(X).

female(X) :- fact_sister(X, _).

female(X) :- fact_mother(X, _).

male(X) :- fact_male(X).

male(X) :- fact_brother(X, _).

male(X) :- fact_father(X, _).

% Parent -----------------------------------------------------------------------

parent(X, Y) :- fact_parent(X, Y).

% Sibling ----------------------------------------------------------------------

% Define sibling/1 as a "synonym" for sibling/2 
sibling([X, Y]) :- sibling(X, Y).

% sibling/2 is commutative 
sibling(X, Y) :-
    fact_sibling(X, Y);
    fact_sibling(Y, X).

% sibling/2 should be inferrable from sibling/1
sibling(X, Y) :-
    fact_sibling([Y, X]);
    fact_sibling([X, Y]).

% Being siblings can be inferred from either being a sister
sibling(X, Y) :-
    fact_sister(X, Y);
    fact_sister(Y, X).

sibling(X, Y) :-
    fact_brother(X, Y);
    fact_brother(Y, X).

sibling(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
    X \= Y.

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