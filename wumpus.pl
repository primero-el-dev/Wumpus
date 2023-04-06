:- use_module(library(random)).
:- use_module(library(lists)).


neighbor_cave(1, [2,5,8]).
neighbor_cave(2, [1,3,10]).
neighbor_cave(3, [2,4,12]).
neighbor_cave(4, [3,5,14]).
neighbor_cave(5, [1,4,6]).
neighbor_cave(6, [5,7,15]).
neighbor_cave(7, [6,8,17]).
neighbor_cave(8, [1,7,9]).
neighbor_cave(9, [8,10,18]).
neighbor_cave(10, [2,9,11]).
neighbor_cave(11, [10,12,19]).
neighbor_cave(12, [3,11,13]).
neighbor_cave(13, [12,14,20]).
neighbor_cave(14, [4,13,15]).
neighbor_cave(15, [6,14,16]).
neighbor_cave(16, [15,17,20]).
neighbor_cave(17, [7,16,18]).
neighbor_cave(18, [9,17,19]).
neighbor_cave(19, [11,18,20]).
neighbor_cave(20, [13,16,19]).


start :-
    % Place game objects
    findall(X, (between(1, 20, X)), Caves),
    random_permutation(Caves, Random),
    Random = [Wumpus, Bat1, Bat2, Pit1, Pit2, Player | Tail],
    nb_setval(wumpus, Wumpus),
    nb_setval(bats, [Bat1,Bat2]),
    nb_setval(pits, [Pit1,Pit2]),
    nb_setval(player, Player),
    nb_setval(arrows, 5),
    
    game_loop(Win),
    tty_clear,
    (   Win == true
    ->  format('YOU WON!')
    ;   Win == false
    ->  format('YOU LOSE!')
    ;   format('Bye!')
    ).


game_loop(Win) :-
    tty_clear,
    % Get all needed data
    nb_getval(player, Player),
    nb_getval(bats, Bats),
    nb_getval(pits, Pits),
    nb_getval(wumpus, Wumpus),
    nb_getval(arrows, Arrows),
    % Make action based on current player position
    (   Wumpus \= Player
    ;   move_wumpus()
    ),
    (   not(member(Player, Bats))
    ;   random_between(1, 20, NewPlayerPosition),
        nb_setval(player, NewPlayerPosition),
        format('You''ve met bat and landed in new place!~n'),
        game_loop(Win)
    ),
    (   member(Player, Pits)
    ->  format('You''ve fallen into pit!~n~n'),
        Win = false
    ;   % Print messages about relative position of game objects
        format('~n~nYou are in cave ~w~n', Player),
        format('Arrows: ~w~n', Arrows),
        neighbor_cave(Player, Neighbors),
        intersection(Neighbors, Bats, NeighborsBats),
        (   NeighborsBats == []
        ;   format('You hear a bat~n')
        ),
        intersection(Neighbors, Pits, NeighborsPits),
        (   NeighborsPits == []
        ;   format('You feel a draft from a pit~n')
        ),
        (   not(member(Wumpus, Neighbors))
        ;   format('You smell a Wumpus~n')
        ),
        show_play_menu_and_choose_option(Neighbors, Win),
        (   ( Win == true ; Win == false ; Win == exit )
        ;   game_loop(Win)
        )
    ).


show_play_menu_and_choose_option([First, Second, Third], Win) :-
    format('1) Go to cave ~w~n', First),
    format('2) Go to cave ~w~n', Second),
    format('3) Go to cave ~w~n', Third),
    format('4) Shoot into cave ~w~n', First),
    format('5) Shoot into cave ~w~n', Second),
    format('6) Shoot into cave ~w~n', Third),
    format('7) Exit~n~n'),

    read_line_to_string(user_input, Choice),
    (   Choice == "1"
    ->  nb_setval(player, First)
    ;   Choice == "2"
    ->  nb_setval(player, Second)
    ;   Choice == "3"
    ->  nb_setval(player, Third)
    ;   Choice == "4"
    ->  shoot(First, Win)
    ;   Choice == "5"
    ->  shoot(Second, Win)
    ;   Choice == "6"
    ->  shoot(Third, Win)
    ;   Choice == "7"
    ->  Win = exit
    ;   (format('Unknown option. Please try again.~n'),
        show_play_menu_and_choose_option([First, Second, Third], Win))
    ).


shoot(Cave, Win) :-
    nb_getval(arrows, Arrows),
    (   Arrows == 0
    ->  format('Not enough arrows.~n'),
        Win = null
    ;   ArrowsAfter is Arrows - 1,
        nb_setval(arrows, ArrowsAfter),
        nb_getval(wumpus, Wumpus),
        (   Cave == Wumpus
        ->  Win = true 
        ;   format('You''ve missed and Wumpus has moved~n'),
            move_wumpus(),
            Win = null
        )
    ).
    

move_wumpus() :-
    nb_getval(wumpus, Wumpus),
    nb_getval(player, Player),
    neighbor_cave(Wumpus, Neighbors),
    subtract(Neighbors, [Player], Caves),
    random_member(NewPosition, Caves),
    nb_setval(wumpus, NewPosition).
