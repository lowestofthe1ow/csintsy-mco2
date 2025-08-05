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
    \+ unsupported(Term),
    \+ contradiction(Term),
    assertz(Term).

% Case when asserting with an undefined predicate (invalid)
safe_assertz(Term) :-
    functor(Term, Name, Arity),
    \+ current_predicate(Name/Arity),
    % Throw unknown predicate error
    throw(error(unknown_predicate(Term), safe_assertz/1)).

% Case when asserting with an unsupported combination of arguments (invalid)
safe_assertz(Term) :-
    unsupported(Term),
    % Throw error
    throw(error(unsupported(Term), safe_assertz/1)).

% Case when asserting with a contradiction (invalid)
safe_assertz(Term) :-
    contradiction(Term),
    % Throw error
    throw(error(contradiction(Term), safe_assertz/1)).

% UNSUPPORTED PREDICATES =======================================================

unsupported(fact_sibling(X)) :- \+ is_list(X).

% Things get complex with lists for grandparents, so we ban them

unsupported(fact_grandmother(L, _)) :- is_list(L).

unsupported(fact_grandfather(L, _)) :- is_list(L).

% CONTRADICTION RULES ==========================================================

% Note: At the application level, we only assert "fact_" predicates

% Sex --------------------------------------------------------------------------

contradiction(fact_female(X)) :- male(X).

contradiction(fact_female(L)) :- is_list(L), member(X, L), male(X).

contradiction(fact_male(X)) :- female(X).

contradiction(fact_male(L)) :- is_list(L), member(X, L), female(X).

% Parent -----------------------------------------------------------------------

contradiction(fact_parent(X, Y)) :- ancestor(Y, X).

contradiction(fact_parent(X, Y)) :-
    \+ is_list(X),
    findall(Z, (parent(Z, Y)), L),  % Find all parents of Y
    flatten(L, Flattened),          % Un-nest nested lists
    sort(Flattened, Sorted),        % Removes duplicates
    length(Sorted, S),              % Get total number of parents of Y
    \+ member(X, Sorted),           % If X is already a parent of Y, ignore
    S >= 2.                         % If Y already has 2 parents, contradiction

% Ban lists of more than 2 parents
contradiction(fact_parent(L, _)) :-
    is_list(L),
    length(L, S),
    S > 2.

% Avoid same-sex parents (both male) in lists
contradiction(fact_parent(L, _)) :-
    is_list(L),
    member(X, L),
    member(Y, L),
    male(X),
    male(Y),
    X \= Y.

% Contradiction if existing father
contradiction(fact_parent(X, Y)) :-
    \+ is_list(X),
    male(X),
    father(Z, Y),
    X \= Z.

% Avoid same-sex parents (both female) in lists
contradiction(fact_parent(L, _)) :-
    is_list(L),
    member(X, L),
    member(Y, L),
    female(X),
    female(Y),
    X \= Y.

% Contradiction if existing mother
contradiction(fact_parent(X, Y)) :-
    female(X),
    mother(Z, Y),
    X \= Z.

contradiction(fact_parent(X, X)) :- true.

% You cannot be your own parent (lists)

contradiction(fact_parent(L, X)) :- is_list(L), member(X, L).

contradiction(fact_parent(X, L)) :- is_list(L), member(X, L).

contradiction(fact_parent(L1, L2)) :-
    is_list(L1),
    is_list(L2),
    member(X, L1),
    member(X, L2).

% Mother -----------------------------------------------------------------------

contradiction(fact_mother(X, Y)) :- contradiction(fact_parent(X, Y)).

contradiction(fact_mother(X, _)) :- male(X).

contradiction(fact_mother(X, Y)) :- mother(Z, Y), X \= Z.

contradiction(fact_mother(L, _)) :- is_list(L), length(L, S), S > 1.

% Father -----------------------------------------------------------------------

contradiction(fact_father(X, Y)) :- contradiction(fact_parent(X, Y)).

contradiction(fact_father(X, _)) :- female(X).

contradiction(fact_father(X, Y)) :- father(Z, Y), X \= Z.

contradiction(fact_father(L, _)) :- is_list(L), length(L, S), S > 1.

% Child ------------------------------------------------------------------------

contradiction(fact_child(X, Y)) :- contradiction(fact_parent(Y, X)).

% Daughter ---------------------------------------------------------------------

contradiction(fact_daughter(X, _)) :- male(X).

contradiction(fact_daughter(X, Y)) :- contradiction(fact_child(X, Y)).

% Son --------------------------------------------------------------------------

contradiction(fact_son(X, _)) :- female(X).

contradiction(fact_son(X, Y)) :- contradiction(fact_child(X, Y)).

% Sibling ----------------------------------------------------------------------

contradiction(fact_sibling(X, X)) :- true.

contradiction(fact_sibling(L, X)) :- is_list(L), member(X, L).

contradiction(fact_sibling(X, L)) :- is_list(L), member(X, L).

contradiction(fact_sibling(L1, L2)) :-
    is_list(L1),
    is_list(L2),
    member(X, L1),
    member(X, L2).

% Sister -----------------------------------------------------------------------

contradiction(fact_sister(X, Y)) :- contradiction(fact_sibling(X, Y)).

contradiction(fact_sister(X, _)) :- male(X).

% Brother ----------------------------------------------------------------------

contradiction(fact_brother(X, Y)) :- contradiction(fact_sibling(X, Y)).

contradiction(fact_brother(X, _)) :- female(X).

% Grandfather ------------------------------------------------------------------

contradiction(fact_grandfather(X, X)) :- true.

contradiction(fact_grandfather(X, Y)) :- ancestor(Y, X).

contradiction(fact_grandfather(X, Y)) :-
    grandfather(A, Y),
    grandfather(B, Y),
    A \= B, X \= A, X \= B.

contradiction(fact_grandfather(X, _)) :- female(X).

% Grandmother ------------------------------------------------------------------

contradiction(fact_grandmother(X, X)) :- true.

contradiction(fact_grandmother(X, Y)) :- ancestor(Y, X).

contradiction(fact_grandmother(X, Y)) :-
    grandmother(A, Y),
    grandmother(B, Y),
    A \= B, X \= A, X \= B.

contradiction(fact_grandmother(X, _)) :- male(X).

% Aunt -------------------------------------------------------------------------

contradiction(fact_aunt(X, _)) :- male(X).

contradiction(fact_aunt(X, Y)) :- ancestor(Y, X).

contradiction(fact_aunt(X, X)) :- true.

% Uncle ------------------------------------------------------------------------

contradiction(fact_uncle(X, _)) :- female(X).

contradiction(fact_uncle(X, Y)) :- ancestor(Y, X).

contradiction(fact_uncle(X, X)) :- true.

% RULES ========================================================================

% Sex --------------------------------------------------------------------------

% Note: For sex, we use the fact_ predicates as a more general intermediate to avoid infinite recursion, instead of just for assertions

female(X) :- fact_daughter(X, _).

female(X) :- fact_sister(X, _).

female(X) :- fact_mother(X, _).

female(X) :- fact_aunt(X, _).

female(X) :- fact_grandmother(X, _).

female(X) :- fact_female(X).

female(X) :- fact_female(L), is_list(L), member(X, L).

female(L) :- is_list(L), forall(member(X, L), female(X)).

male(X) :- fact_son(X, _).

male(X) :- fact_brother(X, _).

male(X) :- fact_father(X, _).

male(X) :- fact_uncle(X, _).

male(X) :- fact_grandfather(X, _).

male(X) :- fact_male(X).

male(X) :- fact_male(L), is_list(L), member(X, L).

male(L) :- is_list(L), forall(member(X, L), male(X)).

% Parent -----------------------------------------------------------------------

parent(X, Y) :- fact_parent(X, Y).

parent(X, Y) :- fact_mother(X, Y).

parent(X, Y) :- fact_father(X, Y).

parent(X, Y) :- fact_child(Y, X).

parent(X, Y) :- fact_son(Y, X).

parent(X, Y) :- fact_daughter(Y, X).

parent(X, Y) :-
    fact_parent(L, Y),
    is_list(L),
    member(X, L).

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
    female(X).

% Father -----------------------------------------------------------------------

father(X, Y) :- fact_father(X, Y).

father(X, Y) :- 
    parent(X, Y),
    parent(Z, Y),
    X \= Z,
    fact_female(Z).

father(X, Y) :-
    parent(X, Y),
    male(X).

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

sibling(X, Y) :-
    fact_aunt(X, Z),
    parent(Y, Z).

sibling(X, Y) :-
    fact_aunt(Y, Z),
    parent(X, Z).

sibling(X, Y) :-
    fact_uncle(X, Z),
    parent(Y, Z).

sibling(X, Y) :-
    fact_uncle(Y, Z),
    parent(X, Z).

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

% Grandfather ------------------------------------------------------------------

grandfather(X, Y) :-
    fact_grandfather(X, Y).

grandfather(X, Y) :-
    parent(X, Z),
    parent(Z, Y),
    male(X).

% Grandmother ------------------------------------------------------------------

grandmother(X, Y) :-
    fact_grandmother(X, Y).

grandmother(X, Y) :-
    parent(X, Z),
    parent(Z, Y),
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

ancestor(X, Y) :-
    parent(X, Y).

ancestor(X, Y) :-
    grandfather(X, Y).

ancestor(X, Y) :-
    grandmother(X, Y).

ancestor(X, Y) :-
    parent(P, Y),
    ancestor(X, P).

% Related ----------------------------------------------------------------------

related([X, Y]) :- related(X, Y).

related(X, Y) :-
    sibling(X, Y).

related(X, Y) :-
    ancestor(Z, X),
    ancestor(Z, Y).

related(X, Y) :-
    ancestor(A, X),
    ancestor(B, Y),
    sibling(A, B).

related(X, Y) :- ancestor(X, Y).

related(X, Y) :- ancestor(Y, X).
