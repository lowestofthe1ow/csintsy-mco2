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

test3 :- 
    assertz(fact_sibling(s, t)),
    assertz(fact_parent(s, a)),
    assertz(fact_parent(s, y)),
    assertz(fact_parent(x, z)),
    assertz(fact_parent(y, z)),
    assertz(fact_parent(a, c)),
    assertz(fact_parent(b, c)),
    related(z, t). % return yes

test4 :-
    assertz(fact_parent(gp,p)),
    assertz(fact_sibling(a,gp)),
    assertz(fact_parent(p,c)),
    related(a, c). % return yes

test5 :-
    assertz(fact_father(m, s)),
    assertz(fact_mother(m, y)),
    assertz(fact_mother(s, a)),
    assertz(fact_child(z, y)),
    assertz(fact_child(z, x)),
    assertz(fact_child(c, a)),
    assertz(fact_child(c, b)),
    related(m, b). % return no

test6 :-
    % assertz(fact_sibling(m, s)),
    assertz(fact_father(p, m)),
    assertz(fact_father(p, s)),
    assertz(fact_father(f, h)),
    assertz(fact_father(m, h)),
    assertz(fact_mother(s, g)),
    assertz(fact_father(t, g)),
    assertz(fact_mother(h, l)),
    assertz(fact_father(g, l)),
    assertz(fact_mother(h, a)),
    assertz(fact_father(g, x)),
    assertz(fact_mother(o, x)),
    assertz(fact_father(c, a)),
    related(a, x). %return yes

test7 :-
    assertz(fact_father(p, a)),
    assertz(fact_father(p, b)),
    assertz(fact_mother(m, a)),
    assertz(fact_mother(a, r)),
    assertz(fact_mother(m, b)),
    assertz(fact_parent(b, c)),
    assertz(fact_parent(c, d)),
    assertz(fact_parent(d, e)),
    assertz(fact_parent(e, f)),
    assertz(fact_parent(f, g)),
    related(r, g). %yes

test8 :-
    safe_assertz(fact_parent(a, [x, y])),
    safe_assertz(fact_child([b, c, d], x)),
    parent(a, x),
    parent(x, d),
    grandparent(a, d).

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

:- dynamic fact_sister   /2.

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

/* - male
   - female
   - mother
   - father
   - sister
   - brother
   - sibling
   - parent
   - child
   - grandfather
   - grandmother
   - daughter
   - son
   - aunt
   - uncle
   - related
 */

% Gender contradictions
contradiction(fact_female(X)) :- male(X).
contradiction(fact_male(X))   :- female(X).


% Sibling contradictions
contradiction(fact_sibling(X, X)) :- true.
contradiction(fact_sibling(X, Y)) :-
    \+ (X \= Y, fact_parent(P, X), fact_parent(P, Y)).   % check

contradiction(fact_sister(X, _)) :- male(X).
contradiction(fact_sister(X, X)) :- true.
contradiction(fact_sister(X, Y)) :-
    \+ (fact_female(X), X \= Y, fact_parent(P, X), fact_parent(P, Y)).

contradiction(fact_brother(X, _)) :- female(X).
contradiction(fact_brother(X, X)) :- true.
contradiction(fact_brother(X, Y)) :-
    \+ (fact_male(X), X \= Y, fact_parent(P, X), fact_parent(P, Y)).


% Parent contradictions
contradiction(fact_parent(X, X)) :- true.
contradiction(fact_parent(X, Y)) :-
    \+ fact_child(Y, X).

contradiction(fact_mother(X, _)) :- male(X).
contradiction(fact_mother(X, X)) :- true.
contradiction(fact_mother(X, Y)) :-
    \+ (fact_female(X), fact_parent(X, Y)).

contradiction(fact_father(X, _)) :- female(X).
contradiction(fact_father(X, X)) :- true.
contradiction(fact_father(X, Y)) :-
    \+ (fact_male(X), fact_parent(X, Y)).


% Child contradictions
contradiction(fact_child(X, X)) :- true.
contradiction(fact_child(X, Y)) :- 
    \+ is_list(X), 
    parent(X, Y).


% Grandparent contradictions
contradiction(fact_grandfather(X, _)) :- female(X).
contradiction(fact_grandfather(X, X)) :- true.
contradiction(fact_grandfather(X, Y)) :-
    \+ (fact_male(X), fact_parent(X, Z), fact_parent(Z, Y)).

contradiction(fact_grandmother(X, _)) :- male(X).
contradiction(fact_grandmother(X, X)) :- true.
contradiction(fact_grandmother(X, Y)) :-
    \+ (fact_female(X), fact_parent(X, Z), fact_parent(Z, Y)).


% Daughter/Son contradictions
contradiction(fact_daughter(X, _)) :- male(X).
contradiction(fact_daughter(X, X)) :- true.
contradiction(fact_daughter(X, Y)) :-
    \+ (fact_female(X), fact_child(X, Y), fact_parent(Y, X)).

contradiction(fact_son(X, _)) :- female(X).
contradiction(fact_son(X, X)) :- true.
contradiction(fact_son(X, Y)) :-
    \+ (fact_male(X), fact_child(X, Y), fact_parent(Y, X)).


% Aunt/Uncle contradictions
contradiction(fact_aunt(X, _)) :- male(X).
contradiction(fact_aunt(X, X)) :- true.
contradiction(fact_aunt(X, Y)) :-
    \+ (fact_female(X), fact_parent(P, Y), fact_sibling(X, P)).


contradiction(fact_uncle(X, _)) :- female(X).
contradiction(fact_uncle(X, X)) :- true.
contradiction(fact_uncle(X, Y)) :-
    \+ (fact_male(X), fact_parent(P, Y), fact_sibling(X, P)).


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
    fact_mother(X, L),
    is_list(L),
    member(Y, L).

mother(X, Y) :-
    parent(X, Y),
    female(X).

% Father -----------------------------------------------------------------------

father(X, Y) :- fact_father(X, Y).

father(X, Y) :-
    fact_father(X, L),
    is_list(L),
    member(Y, L).

father(X, Y) :-
    parent(X, Y),
    male(X).

% Child ------------------------------------------------------------------------

child(X, Y) :- parent(Y, X).

% Daughter ---------------------------------------------------------------------

daughter(X, Y) :- fact_daughter(X, Y).

daughter(X, Y) :-
    fact_daughter(L, X),
    is_list(L),
    member(Y, L).

daughter(X, Y) :-
    child(X, Y),
    female(X).

% Son --------------------------------------------------------------------------

son(X, Y) :- fact_son(X, Y).

son(X, Y) :-
    fact_son(L, X),
    is_list(L),
    member(Y, L).

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

/* TODO: Red
   - grandfather
   - grandmother
   - daughter
   - son
   - aunt
   - uncle
   - related
 */

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
