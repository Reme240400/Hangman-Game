/* Logical and Functional Programming Project a.y. 2023-2024
   Lecturer: Prof. Marco Bernardo
   Students: 
            Tommaso Remedi  - 300535 
            Riccardo Monaco - 300537 */

/* Prolog program to play the hangman game. */

main :- 
    env_setup(6).

/* Words to guess list. */

words_list(['haskell', 'programming', 'functional', 'language', 'computation']).

/* The predicate env_setup sets the game environment, picking the word to guess:
   - The first parameter stands for the total attempts. */

env_setup(Remaining_Attemps) :- 
    clean_console,
    write('Welcome to the Hangman Game!'), nl,
    sel_word(Word_To_Guess),
    play(Word_To_Guess, [], Remaining_Attemps).

/* The predicate sel_world randomly selects a word from the given list: 
   - The first parameter stands for the word to be selected. */

sel_word(Word) :-
    words_list(Words_List),
    length(Words_List, List_Length),
    random(0, List_Length, Word_Index),
    nth0(Word_Index, Words_List, Atom_Word),
    atom_chars(Atom_Word, Word).

/* The predicate play manages the game, it updates the guessed letters and the attempts:
   - The first parameter stands for the word to guess;
   - The second parameter stands for the letters already guessed;
   - The third parameter stands for the remaining attempts. */

play(Word_To_Guess, Guessed_Letters, Remaining_Attemps) :-
    Remaining_Attemps =:= 0 ->
        handle_loss(Word_To_Guess)
    ;
    check_guessed(Word_To_Guess, Guessed_Letters) ->
        handle_win(Word_To_Guess)
    ;   
        handle_in_progress(Word_To_Guess, Guessed_Letters, Remaining_Attemps).

/* The predicate handle_loss handles the case when the user runs out of attempts:
   - The first parameter stands for the word to guess. */

handle_loss(Word_To_Guess) :-
    clean_console,
    draw_hangman(0),
    write('You\'ve Lost!'), nl,
    write('The word to guess was: '), print_list(Word_To_Guess), nl.

/* The predicate handle_win handles the case when the user wins:
   - The first parameter stands for the word to guess. */

handle_win(Word_To_Guess) :-
    clean_console,
    write('You\'ve won! The secret word was: '), print_list(Word_To_Guess), nl.

/* The predicate handle_in_progress handles the in-progress scenario:
   - The first parameter stands for the word to guess;
   - The second parameter stands for the letters already guessed;
   - The third parameter stands for the remaining attempts. */

handle_in_progress(Word_To_Guess, Guessed_Letters, Remaining_Attemps) :-
    clean_console,
    write('Current word:'), nl,
    render_word(Word_To_Guess, Guessed_Letters), nl, nl,
    draw_hangman(Remaining_Attemps),
    write('Remaining attempts: '), write(Remaining_Attemps), nl, nl,
    write('Guess a Letter: '), nl,
    read_first_char(Inserted_Letter),
    upd_attempt(Word_To_Guess, Guessed_Letters, Inserted_Letter, Remaining_Attemps).


/* The predicate read_first_char reads and checks the validity of the input:
   - The first parameter stands for the first inserted char. */

read_first_char(First_Char) :-
    get_code(First_Code),
    atom_codes(First_Char, [First_Code]),
    (
        (First_Code >= 97, First_Code =< 122) ->
            read_remaining_chars(First_Code, Remaining_Codes) 
        ;
            write('Please, enter a lowercase letter.'), nl,
            read_remaining_chars(First_Code, Remaining_Codes),
            clean_console,
            write('Guess a Letter: '), nl,
            read_first_char(_)
    ).


/* The predicate read_remaining_chars cleans up any leftover of the input:
   - The first parameter stands for the first code read;
   - The second parameters stands for the eventual other codes inserted. */

read_remaining_chars(10, []) :- !.  
read_remaining_chars(Code, [Code | Remaining_Codes]) :-
    get_code(New_Code),
    read_remaining_chars(New_Code, Remaining_Codes).


/* The predicate upd_attempt updates the guessed letters list with eventually a new one:
   - The first parameter stands for the word to guess;
   - The second parameter stands for the letters already guessed;
   - The third parameter stands for the letter the user has inserted;
   - The fourth parameter stands for the remaining attempts. */

upd_attempt(Word_To_Guess, Guessed_Letters, Inserted_Letter, Remaining_Attemps) :-
    write('____________________________________'), nl, nl,
    memberchk(Inserted_Letter, Guessed_Letters) ->
           write('Already guessed letter!'), nl,
           play(Word_To_Guess, Guessed_Letters, Remaining_Attemps)                 
    ;   
    memberchk(Inserted_Letter, Word_To_Guess) ->
           write('The letter is in the word!'), nl,
           append(Guessed_Letters, [Inserted_Letter], Upd_Guessed_Letters),
           play(Word_To_Guess, Upd_Guessed_Letters, Remaining_Attemps)
    ;
    write('Wrong letter!'), nl,
    Upd_Remaining_Attempts is Remaining_Attemps - 1,
    play(Word_To_Guess, Guessed_Letters, Upd_Remaining_Attempts).


/* The predicate render_word prints a letter if it is found in the word, a "_" if not:
   - The first parameter stands for the letters of the word to guess;
   - The second parameter stands for the letters already guessed. */

render_word([], _).
render_word([C|Word_To_Guess], Guessed_Letters) :-
    (
        memberchk(C, Guessed_Letters) ->
        write(C)
        ;   
        write('-')
    ),
    render_word(Word_To_Guess, Guessed_Letters).

/* The predicate check_guessed returns true if all the letters have been guessed:
   - The first parameter stands for the word to guess;
   - The second parameter stands for the letters already guessed. */

check_guessed(Word_To_Guess, Guessed_Letters) :-
    subtract(Word_To_Guess, Guessed_Letters, []).

/* The predicate draw_hangman prints the characters to draw the countours of the hangman:
   - The first parameter stands for the remaining attempts. */

draw_hangman(Remaining_Attemps) :-
    write('  +---+'), nl,
    write('  |   |'), nl,
    draw_case(Remaining_Attemps),
    write('========='), nl.

/* The auxiliary predicate draw_case draws the specific "state" of the hangman:
   - The first parameter stands for the reached level of error. */

draw_case(6) :-
    write('      |'), nl,
    write('      |'), nl,
    write('      |'), nl.
draw_case(5) :-
    write('  O   |'), nl,
    write('      |'), nl,
    write('      |'), nl.
draw_case(4) :-
    write('  O   |'), nl,
    write('  |   |'), nl,
    write('      |'), nl.
draw_case(3) :-
    write('  O   |'), nl,
    write(' /|   |'), nl,
    write('      |'), nl.
draw_case(2) :-
    write('  O   |'), nl,
    write(' /|\\  |'), nl,
    write('      |'), nl.
draw_case(1) :-
    write('  O   |'), nl,
    write(' /|\\  |'), nl,
    write(' /    |'), nl.
draw_case(0) :-
    write('  O   |'), nl,
    write(' /|\\  |'), nl,
    write(' / \\  |'), nl.

/* The predicate clean_console prints a new line. */

clean_console :-
    nl.

/* The predicate print_list pretty prints a list: 
   - The first parameter stands for the list to print. */

print_list([]).
print_list([X|Xs]) :-
    write(X),
    print_list(Xs).