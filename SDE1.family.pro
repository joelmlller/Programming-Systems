%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ECE3520/CpSc3520 SDE1: Prolog Declarative and Logic Programming

% Use the following Prolog relations as a database of familial 
% relationships for 4 generations of people.  If you find obvious
% minor errors (typos) you may correct them.  You may add additional
% data if you like but you do not have to.

% Then write Prolog rules to encode the relations listed at the bottom.
% You may create additional predicates as needed to accomplish this,
% including relations for debugging or extra relations as you desire.
% All should be included when you turn this in.  Your rules must be able
% to work on any data and across as many generations as the data specifies.
% They may not be specific to this data.

% Using SWI-Prolog, run your code, demonstrating that it works in all modes.
% Log this session and turn it in with your code in this (modified) file.
% You examples should demonstrate working across 4 generations where
% applicable.

% Fact recording Predicates:

% list of two parents, father first, then list of all children
% parent_list(?Parent_list, ?Child_list).

% Data:

parent_list([fred_smith, mary_jones],
            [tom_smith, lisa_smith, jane_smith, john_smith]).

parent_list([tom_smith, evelyn_harris],
            [mark_smith, freddy_smith, joe_smith, francis_smith]).

parent_list([mark_smith, pam_wilson],
            [martha_smith, frederick_smith]).

parent_list([freddy_smith, connie_warrick],
            [jill_smith, marcus_smith, tim_smith]).

parent_list([john_smith, layla_morris],
            [julie_smith, leslie_smith, heather_smith, zach_smith]).

parent_list([edward_thompson, susan_holt],
            [leonard_thompson, mary_thompson]).

parent_list([leonard_thompson, list_smith],
            [joe_thompson, catherine_thompson, john_thompson, carrie_thompson]).

parent_list([joe_thompson, lisa_houser],
            [lilly_thompson, richard_thompson, marcus_thompson]).

parent_list([john_thompson, mary_snyder],
            []).

parent_list([jeremiah_leech, sally_swithers],
            [arthur_leech]).

parent_list([arthur_leech, jane_smith],
            [timothy_leech, jack_leech, heather_leech]).

parent_list([robert_harris, julia_swift],
            [evelyn_harris, albert_harris]).

parent_list([albert_harris, margaret_little],
            [june_harris, jackie_harrie, leonard_harris]).

parent_list([leonard_harris, constance_may],
            [jennifer_harris, karen_harris, kenneth_harris]).

parent_list([beau_morris, jennifer_willis],
            [layla_morris]).

parent_list([willard_louis, missy_deas],
            [jonathan_louis]).

parent_list([jonathan_louis, marsha_lang],
            [tom_louis]).

parent_list([tom_louis, catherine_thompson],
            [mary_louis, jane_louis, katie_louis]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SWE1 Assignment - Create rules for:

% Parent is the parent - mother or father of the child
parent(Parent, Child) :-
    parent_list(Parents, Children),
    member(Parent, Parents),
    member(Child, Children).

% Husband is married to Wife - note the order is significant
married(Husband, Wife) :-
    parent_list([Husband, Wife], _).

% Ancestor is parent, grandparent, great-grandparent, etc. of Person
ancestor(Ancestor, Person) :-
    parent(Ancestor, Person).
ancestor(Ancestor, Person) :-
    parent(Parent, Person),
    ancestor(Ancestor, Parent).

% The same as ancestor, only backwards.
descendent(Descendent, Person) :-
    ancestor(Person, Descendent).

% There are exactly Gen generations between Ancestor and Person.  
generations(Ancestor, Person, Gen) :-
    generations_helper(Ancestor, Person, 0, Gen).

generations_helper(Ancestor, Person, Acc, Gen) :-
    parent(Ancestor, Person),
    Gen is Acc + 1.
generations_helper(Ancestor, Person, Acc, Gen) :-
    parent(Parent, Person),
    NewAcc is Acc + 1,
    generations_helper(Ancestor, Parent, NewAcc, Gen).

% Ancestor is the ancestor of both Person1 and Person2.
least_common_ancestor(Person1, Person2, Ancestor) :-
    findall(Ancestor1, ancestor(Ancestor1, Person1), Ancestors1),
    findall(Ancestor2, ancestor(Ancestor2, Person2), Ancestors2),
    intersection(Ancestors1, Ancestors2, CommonAncestors),
    member(Ancestor, CommonAncestors),
    forall((member(OtherAncestor, CommonAncestors), OtherAncestor \= Ancestor),
           (generations(Ancestor, Person1, Gen1),
            generations(Ancestor, Person2, Gen2),
            generations(OtherAncestor, Person1, Gen3),
            generations(OtherAncestor, Person2, Gen4),
            Gen1 + Gen2 =< Gen3 + Gen4)).

% Do Person1 and Person2 have a common ancestor?
blood(Person1, Person2) :-
    least_common_ancestor(Person1, Person2, _).

% Are Person1 and Person2 on the same list 2nd area of a parent_list record.
sibling(Person1, Person2) :-
    parent_list(_, Children),
    member(Person1, Children),
    member(Person2, Children),
    Person1 \= Person2.

% father is always first on the list in parent_list.
father(Father, Child) :-
    parent_list([Father, _], Children),
    member(Child, Children).

% mother is always second on the list in parent_list.
mother(Mother, Child) :-
    parent_list([_, Mother], Children),
    member(Child, Children).

% Note that some uncles may not be in a parent_list arg of parent_list, but would have a male record to specify gender.
uncle(Uncle, Person) :-
    parent(Parent, Person),
    sibling(Uncle, Parent).

% Aunt
aunt(Aunt, Person) :-
    parent(Parent, Person),
    sibling(Aunt, Parent).

% cousins have a generations greater than parents and aunts/uncles.
cousin(Cousin, Person) :-
    parent(Parent, Person),
    parent(Grandparent, Parent),
    parent(Grandparent, AuntOrUncle),
    parent(AuntOrUncle, Cousin),
    Parent \= AuntOrUncle.

% 1st cousin, 2nd cousin, 3rd once removed, etc.
cousin_type(Person1, Person2, CousinType, Removed) :-
    least_common_ancestor(Person1, Person2, Ancestor),
    generations(Ancestor, Person1, Gen1),
    generations(Ancestor, Person2, Gen2),
    CousinType is min(Gen1, Gen2) - 1,
    Removed is abs(Gen1 - Gen2).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software.
% Please run ?- license. for legal details.
%
% For online help and background, visit https://www.swi-prolog.org
% For built-in help, use ?- help(Topic). or ?- apropos(Word).
%

%?- consult('C:\\Users\\joelm\\Desktop\\cpsc3520\\SDE1.family.pro').
%true.


%Test cases for parent/2:
% Test case 1
%?- parent(fred_smith, tom_smith).
%true.

% Test case 2
%?- parent(tom_smith, X).
%X = mark_smith ;
%X = freddy_smith ;
%X = joe_smith ;
%X = francis_smith.

% Test case 3
%?- parent(X, joe_smith).
%X = tom_smith ;
%X = evelyn_harris.

% Test case 4
%?- parent(fred_smith, X), parent(X, lisa_smith).
%X = tom_smith.

% Test case 5
%?- parent(X, Y).
%X = fred_smith,
%Y = tom_smith ;
%X = fred_smith,
%Y = lisa_smith ;
%...

%Test cases for married/2:
% Test case 1
%?- married(tom_smith, evelyn_harris).
%true.

% Test case 2
%?- married(evelyn_harris, tom_smith).
%false.

% Test case 3
%?- married(X, Y).
%X = tom_smith,
%Y = evelyn_harris ;
%X = albert_harris,
%Y = margaret_little ;
%...

%Test cases for ancestor/2:
% Test case 1
%?- ancestor(fred_smith, francis_smith).
%true.

% Test case 2
%?- ancestor(X, francis_smith).
%X = fred_smith ;
%X = tom_smith ;
%X = mark_smith ;
%X = freddy_smith ;
%...

% Test case 3
%?- ancestor(john_thompson, mary_louis).
%true.

% Test case 4
%?- ancestor(john_thompson, X).
%X = mary_louis ;
%X = jane_louis ;
%X = katie_louis ;
%...

%Test cases for descendent/2:
% Test case 1
%?- descendent(john_smith, tim_smith).
%true.

% Test case 2
%?- descendent(X, heather_smith).
%X = john_smith ;
%X = layla_morris ;
%X = zach_smith ;
%...

% Test case 3
%?- descendent(tim_louis, X).
%X = tom_louis ;
%X = marsha_lang ;
%X = jonathan_louis ;
%X = missy_deas ;
%...

%Test cases for generations/3:
% Test case 1
%?- generations(fred_smith, francis_smith, G).
%G = 3.

% Test case 2
%?- generations(fred_smith, X, 2).
%X = mark_smith ;
%X = freddy_smith ;
%X = joe_smith ;
%X = francis_smith.

% Test case 3
%?- generations(X, francis_smith, G).
%X = fred_smith,
%G = 3 ;
%X = tom_smith,
%G = 2 ;
%X = mark_smith,
%G = 1 ;
%...

% Test case 4
%?- generations(fred_smith, francis_smith, 2).
%true.

% Test case 5
%?- generations(fred_smith, francis_smith, 1).
%false.

%Test cases for least_common_ancestor/3:
% Test case 1
%?- least_common_ancestor(mark_smith, jill_smith, Ancestor).
%Ancestor = tom_smith ;
%false.

% Test case 2
%?- least_common_ancestor(mark_smith, jill_smith, Ancestor), ancestor(Ancestor, mark_smith), ancestor(Ancestor, jill_smith).
%Ancestor = tom_smith ;
%false.

% Test case 3
%?- least_common_ancestor(jill_smith, marcus_smith, Ancestor).
%Ancestor = freddy_smith ;
%false.

% Test case 4
%?- least_common_ancestor(jill_smith, marcus_smith, Ancestor), ancestor(Ancestor, jill_smith), ancestor(Ancestor, marcus_smith).
%Ancestor = freddy_smith ;
%false.

%Test cases for blood/2:
% Test case 1
%?- blood(mark_smith, jill_smith).
%true.

% Test case 2
%?- blood(mark_smith, mary_thompson).
%true.

% Test case 3
%?- blood(tom_smith, martha_smith).
%false.

%Test cases for sibling/2:
% Test case 1
%?- sibling(jane_smith, lisa_smith).
%true.

% Test case 2
%?- sibling(jack_leech, heather_leech).
%false.

% Test case 3
%?- sibling(X, Y).
%X = tom_smith,
%Y = lisa_smith ;
%X = lisa_smith,
%Y = tom_smith ;
%...

%Test cases for father/2:
% Test case 1
%?- father(fred_smith, tom_smith).
%true.

% Test case 2
%?- father(X, tim_smith).
%X = freddy_smith ;
%X = john_smith ;
%...

% Test case 3
%?- father(john_thompson, X).
%false.

%Test cases for mother/2:
% Test case 1
%?- mother(mary_jones, tom_smith).
%false.

% Test case 2
%?- mother(X, lisa_smith).
%X = mary_jones ;
%X = evelyn_harris ;
%...

% Test case 3
%?- mother(X, mary_louis).
%false.

%Test cases for uncle/2:
% Test case 1
%?- uncle(tom_smith, zach_smith).
%true.

% Test case 2
%?- uncle(marcus_smith, heather_leech).
%true.

% Test case 3
%?- uncle(X, Y).
%X = mark_smith,
%Y = julie_smith ;
%X = mark_smith,
%Y = leslie_smith ;
%...

%Test cases for aunt/2:
% Test case 1
%?- aunt(lisa_smith, zach_smith).
%false.

% Test case 2
%?- aunt(X, john_smith).
%X = martha_smith ;
%X = jane_smith ;
%...

% Test case 3
%?- aunt(X, katie_louis).
%false.

%Test cases for cousin/2:
% Test case 1
%?- cousin(tim_smith, jill_smith).
%true.

% Test case 2
%?- cousin(john_smith, heather_smith).
%true.

% Test case 3
%?- cousin(X, Y).
%X = jill_smith,
%Y = julie_smith ;
%X = jill_smith,
%Y = leslie_smith ;
%...

%Test cases for cousin_type/4:
% Test case 1
%?- cousin_type(tim_smith, heather_smith, CousinType, Removed).
%CousinType = 1,
%Removed = 1 ;
%false.

% Test case 2
%?- cousin_type(john_smith, mary_louis, CousinType, Removed).
%CousinType = 1,
%Removed = 0 ;
%false.

% Test case 3
%?- cousin_type(jill_smith, marcus_smith, CousinType, Removed).
%CousinType = 1,
%Removed = 0 ;
%false.
