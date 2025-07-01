:- dynamic fact_male     /1.
:- dynamic fact_female   /1.
:- dynamic fact_parent   /2.
:- dynamic fact_sibling  /2.
:- dynamic fact_sister   /2.
:- dynamic fact_brother  /2.
:- dynamic fact_mother   /2.
:- dynamic fact_father   /2.

% Notation: parent(X, Y) should mean "X is a parent of Y"

% RULES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

female(X) :- fact_female(X).

male(X) :- fact_male(X).

% Parent

parent(X, Y) :-
    fact_parent(X, Y).

sibling(X, Y) :- fact_sibling(X, Y).

sibling(X, Y) :- fact_sibling(Y, X).

sibling(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
    X \= Y;
    fact_sister(X, Y);
    fact_sister(Y, X);
    fact_brother(X, Y);
    fact_brother(Y, X).

sister(X, Y) :- fact_sister(X, Y).

sister(X, Y) :-
    sibling(X, Y),
    female(X).

brother(X, Y) :-
    fact_brother(X, Y).

brother(X, Y) :-
    sibling(X, Y),
    male(X).

mother(X, Y) :- fact_mother(X, Y).

mother(X, Y) :-
    parent(X, Y),
    female(X).

father(X, Y) :- fact_father(X, Y).

father(X, Y) :-
    parent(X, Y),
    male(X).

