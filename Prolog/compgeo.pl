%%%% -*- Mode: Prolog -*-
%%% compgeo.pl
%%% Progetto prolog
%%% Premate_Andrea_829777_CH_LP_201907



%%% DEFINIZIONI GEOMETRICHE

%% aggiunge un nuovo punto alla base di conoscenza.
new_point(X, Y) :-
    integer(X), integer(Y), assert(point(X, Y)).


%% definisce la relazione tra punto e coordinate.
point_coordinates(point(X,Y), X, Y) :-
    integer(X), integer(Y).


area2(A, B, C, Area) :-
    nonvar(A), nonvar(B), nonvar(C),
    point_coordinates(A, Xa, Ya),
    point_coordinates(B, Xb, Yb),
    point_coordinates(C, Xc, Yc), !,
    Area is (Xa - Xc) * (Yb - Yc) - (Ya - Yc) * (Xb - Xc).


left(A, B, C) :-
    area2(A, B, C, Area), Area > 0.


lefton(A, B, C) :-
    area2(A, B, C, Area), Area < 0.


coll(A, B, C) :-
    area2(A, B, C, Area), Area == 0.


angle2d(A, B, R) :-
	A \= B ,
        point_coordinates(A, Xa, Ya),
        point_coordinates(B, Xb, Yb),
        R is atan(Yb - Ya, Xb - Xa).


%%% ORDINAMENTO, PUNTO MINIMO E MANIPOLAZIONE LISTE

%% preleva dalla base di conoscenza tutti i punti e li
%% inserisce nella lista L, togliendo eventuali duplicati.
get_points_set(L) :- setof(point(X, Y), point(X, Y), L).


%% trova in una lista l'elemento minore, che denominiamo p0.
get_p0([Point], Point) :-
    !.

get_p0([H1, H2 | Rest], Min) :-
    point_coordinates(H1, _X1, Y1), point_coordinates(H2, _X2, Y2),
    Y1 < Y2, !, get_p0([H1 | Rest], Min).

get_p0([H1, H2 | Rest], Min) :-
    point_coordinates(H1, _X1, Y1), point_coordinates(H2, _X2, Y2),
    Y1 > Y2, !, get_p0([H2 | Rest], Min).

get_p0([H1, H2 | Rest], Min) :-
    point_coordinates(H1, X1, _Y1), point_coordinates(H2, X2, _Y2),
    X1 < X2, !, get_p0([H1 | Rest], Min).

get_p0([H1, H2 | Rest], Min) :-
    point_coordinates(H1, X1, _Y1), point_coordinates(H2, X2, _Y2),
    X1 >= X2, !, get_p0([H2 | Rest], Min).


%% setta p0 dopo averlo trovato tramite la fz get_p0/2.
set_p0(P0) :-
    get_points_set(L), get_p0(L, P0), nb_setval(p0, P0).


%% determina quale tra due punti forma, con p0 e la
%% direzione orizzontale, l'angolo minore, in caso di parità
%% è considerato minore il punto più vicino a p0.
%% ATTENZIONE: leggere il readme.
smaller_angle(A, B) :-
    nb_getval(p0, P0),
    angle2d(P0, A, Ra), angle2d(P0, B, Rb),
    Ra < Rb, !.

smaller_angle(A, B) :-
    nb_getval(p0, P0),
    angle2d(P0, A, Ra), angle2d(P0, B, Rb),
    Ra == Rb,
    point_coordinates(A, _Xa, Ya),  point_coordinates(B, _Xb, Yb),
    Ya < Yb, !.

smaller_angle(A, B) :-
    nb_getval(p0, P0),
    angle2d(P0, A, Ra), angle2d(P0, B, Rb),
    Ra == Rb,
    point_coordinates(A, Xa, Ya),
    point_coordinates(B, Xb, Yb),
    Ya == Yb, Xa =< Xb, !.


%% implementazione del quicksort sfruttando la funzione
%% smaller_angle/2 (ordine crescente).

pivoting(_, [], [], []) :-
    !.
pivoting(H, [X | T], [X | L], G):-
    smaller_angle(H, X), !, pivoting(H, T, L, G).
pivoting(H, [X | T], L, [X | G]):-
    pivoting(H, T, L, G), !.

quick_sort_acc([], Acc, Acc) :-
    !.
quick_sort_acc([H | T], Acc, Sorted):-
    pivoting(H, T, L1, L2), !,
    quick_sort_acc(L1, Acc, Sorted1), !,
	quick_sort_acc(L2 , [H | Sorted1], Sorted), !.

quick_sort_by_angle(List, Sorted):-
    quick_sort_acc(List, [], Sorted).


%% la funzione reverse_list ribalta una lista e fa uso di
%% una funzione di appoggio con accumulatore
reverse_list_acc([], Acc, Acc).
reverse_list_acc([H | Stack_in], Stack_out, Acc) :-
    reverse_list_acc(Stack_in, Stack_out, [H | Acc]).

reverse_list(Stack_in, Stack_out) :-
    reverse_list_acc(Stack_in, Stack_out, []).


%% ATTENZIONE: la fz fa quanto detto nel punto 5) del readme
adjust_last_coll([H | CH], ListaPunti, Out) :-
    nb_getval(p0, P0), angle2d(P0, H, R),
    get_same_angle_list(ListaPunti, R, Same_angle_points),
    quick_sort_by_angle(Same_angle_points, Same_angle_points_Ordered),
    append(Same_angle_points_Ordered, CH, Out).


%% data una lista e un punto associa una lista contenente tutti i punti
%% che formano con p0 lo stesso angolo del punto passato come argomento
get_same_angle_list([], _, []) :-
    !.
get_same_angle_list([H|ListaPunti], R, Same_angle_points) :-
    nb_getval(p0, P0), angle2d(P0, H, Ang), Ang \= R, !,
    get_same_angle_list(ListaPunti, R, Same_angle_points).
get_same_angle_list([H|ListaPunti], R, [H|Same_angle_points]) :-
    nb_getval(p0, P0), angle2d(P0, H, Ang), Ang == R, !,
    get_same_angle_list(ListaPunti, R, Same_angle_points).



%%% STACK

%% Le funzioni di questa sezione sono praticamente immediate;
%% è stato scelto di implementarle per dare maggiore leggibilità
%% al codice e fare intendere che si ha a che fare con uno stack.

pop(H, [H | T], T).

top(H, [H | _]).

next_to_top(H2, [_, H2 | _]).

push(X, T, [X | T]).



%%% CONVEX HULL

%% implementa il punto focale dell'algoritmo nella
%% sua definizione generale.
convexh_algorithm([], Stack, Stack) :-
    !.

convexh_algorithm([H | Points], Stack, CH) :-
    top(S1, Stack), next_to_top(S2, Stack),
    left(S2, S1, H), !, push(H, Stack, NewStack),
    convexh_algorithm(Points, NewStack, CH).

convexh_algorithm([H | Points], Stack, CH) :-
    top(S1, Stack), next_to_top(S2, Stack),
    lefton(S2, S1, H), !, pop(S1, Stack, NewStack),
    convexh_algorithm([H | Points], NewStack, CH).

% mantengo i punti collineari
convexh_algorithm([H | Points], Stack, CH) :-
    top(S1, Stack), next_to_top(S2, Stack),
    coll(S2, S1, H), !, push(H, Stack, NewStack),
    convexh_algorithm(Points, NewStack, CH).

/* in questo modo invece si rimuovono i punti collineari
convexh_algorithm([H | Points], Stack, CH) :-
    top(S1, Stack), next_to_top(S2, Stack),
    coll(S2, S1, H), !, pop(S1, Stack, NewStack),
    push(H, NewStack, NewStack2),
    convexh_algorithm(Points, NewStack2, CH).
*/

%% calcola la CH sfruttando i punti presenti nella base
%% di conoscenza.
convexh_without_list(CH) :-
    set_p0(P0), retractall(P0),
    get_points_set(L), quick_sort_by_angle(L, [P1 | Sorted]),
    push(P0, [], Stack),
    push(P1, Stack, NewStack),
    convexh_algorithm(Sorted, NewStack, Not_adj_CH),
    adjust_last_coll(Not_adj_CH, L, Adjusted_CH),
    reverse_list(Adjusted_CH, CH),
    length(CH, Length), Length > 2, % un poligono ha min 3 punti
    clean_points.

%% calcola la CH dei punti presenti nella lista In ed
%% eventuali punti già prensenti nella base di conoscenza.
convexh(In, CH) :-
    assert_input_list(In),
    convexh_without_list(CH).

%% elimina i punti presenti nella base di conoscenza e p0.
clean_points :-
    nb_delete(p0), retractall(point(_,_)).



%%% FILE INPUT

read_points(File, Points) :-
    file_check(File),
    csv_read_file(File, Points, [functor(point), separator(0'\t)]).

%% esegue l'assert di ogni punto presente in una lista
assert_input_list([]) :-
    !.

assert_input_list([H | InputList]) :-
    assert_input_list(InputList), assert(H).



%%% CONTROLLO FILE DI PUNTI

%% controlla se il file di punti passato ha la forma indicata
%% nelle specifiche del progetto
file_check(File) :-
    read_file_to_codes(File, Codes, []),
    recognize(Codes), !.

file_check(_) :-
    print('Errore! Il file non contiene i dati nel modo richiesto'), fail.

%% controlla se il codice passato rappresenta un numero
num_code(Code) :-
    Code >= 48, Code =< 57.

%% controlla se il codice passato rappresenta un tab
tab_code(Code) :-
    Code == 9.

%% controlla se il codice passato rappresenta una nuova linea
nline_code(Code) :-
    Code == 10.

%% controlla se il codice passato rappresenta un simbolo meno
minus_code(Code) :-
    Code == 45.


%% automa
accept([I | Is], S) :-
    delta(S, I, N),
    accept(Is, N).
accept([], Q) :-
    final(Q).

initial(q0).
final(q3).

delta(q0, Code, q1) :-
    num_code(Code).
delta(q0, Code, q1_minus) :-
    minus_code(Code).
delta(q1_minus, Code, q1) :-
    num_code(Code).
delta(q1, Code, q1) :-
    num_code(Code), !.
delta(q1, Code, q2) :-
    tab_code(Code).
delta(q2, Code, q3) :-
    num_code(Code).
delta(q2, Code, q3_minus) :-
    minus_code(Code).
delta(q3_minus, Code, q3) :-
    num_code(Code).
delta(q3, Code, q3) :-
    num_code(Code), !.
delta(q3, Code, q0) :-
    nline_code(Code).

recognize(Input) :-
    initial(S),
    accept(Input, S).



%%%% end of file -- compgeo.pl
