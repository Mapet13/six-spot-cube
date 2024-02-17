include "globals.mzn";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
enum COLOR = { Red, White, Green, Orange, Blue, Yellow };
enum Rotation_move = { Clockwise, CounterClockwise };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int: ROTATION_MAX = 2;
set of int: ROTATION_STATE = 0..ROTATION_MAX;

int: ROTATABLE_CORNERS_COUNT = 3;
set of int: CORNER = 1..ROTATABLE_CORNERS_COUNT;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
array[CORNER, CORNER] of COLOR: rotation_map = [|Red,Yellow,Blue|Orange,Yellow,Green|Orange,White,Blue|];
array[CORNER, CORNER] of COLOR: stationary_rotation_map = [|White,Green,Orange|Red,White,Blue|Red,Green,Yellow|];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cube configuration declaration:
array[CORNER] of ROTATION_STATE: corners_rotation;
array[COLOR] of COLOR: spot_colors;
int: MAX_MOVES;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solved:
array[CORNER] of ROTATION_STATE: solved_rotation = [0, 0, 0];
array[COLOR] of COLOR: solved_spot_colors = [Red, White, Green, Orange, Blue, Yellow];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set of int: MOVES = 0..MAX_MOVES;
set of int: STATES = 0..MAX_MOVES+1;
var MOVES: steps;
array[MOVES] of var Rotation_move: moves_kind;
array[MOVES] of var CORNER: moves_corner;
array[STATES, CORNER] of var ROTATION_STATE: rotation_states;
array[STATES, COLOR] of var COLOR: spot_color_states;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bind initial state:
constraint rotation_states[0, ..] = corners_rotation;
constraint spot_color_states[0, ..] = spot_colors;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function var int: corner_rotation_offset(var Rotation_move: move) = 
  if move == Clockwise 
  then 1 
  else 2 
  endif;
  
function var ROTATION_STATE: next_rotation_corner_at_index(var STATES: step, var CORNER: index) = 
  if moves_corner[step] == index 
  then (rotation_states[step, index] + corner_rotation_offset(moves_kind[step])) mod (ROTATION_MAX + 1)
  else rotation_states[step, index] 
  endif;
  
function var ROTATION_STATE: get_correct_corner_rotation(var STATES: step, var ROTATION_STATE: value) = 
  (value + corner_rotation_offset(moves_kind[step])) mod (ROTATION_MAX + 1);
  
function var ROTATION_STATE: next_rotation_color_at_index(var STATES: step, var COLOR: index) = 
  if moves_corner[step] == index 
  then get_correct_corner_rotation(step, rotation_states[step, index])
  else rotation_states[step, index] 
  endif;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
predicate rotation_should_be_applied_to_corners(var STATES: step) = 
  forall(i in CORNER)(next_rotation_corner_at_index(step, i) = rotation_states[step+1, i]);
  
predicate rotation_should_be_applied_to_colors(var STATES: step) = 
  (forall(j in CORNER)(
    rotation_should_not_move_rest_of_colors(step, stationary_rotation_map[moves_corner[step], j]) /\ 
    rotation_should_rotate_colors(step, rotation_map[moves_corner[step], j], rotation_map[moves_corner[step], get_correct_corner_rotation(step, j-1)+1])
  ));
  
predicate rotation_should_not_move_rest_of_colors(var STATES: step, var COLOR: i) = 
  spot_color_states[step, i] = spot_color_states[step + 1, i];
  
predicate rotation_should_rotate_colors(var STATES: step, var COLOR: i, var COLOR: expected_index) = 
  spot_color_states[step + 1, i] = spot_color_states[step, expected_index];
  
predicate rotation_should_be_applied(var STATES: step) = 
  rotation_should_be_applied_to_corners(step) /\ rotation_should_be_applied_to_colors(step);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% there need to be a solution:
constraint steps <= MAX_MOVES;
% solution must be solved:
constraint forall(i in CORNER)(rotation_states[steps, i] = solved_rotation[i]);
constraint forall(i in COLOR)(spot_color_states[steps, i] = solved_spot_colors[i]);
% Each side should be coloured differently:
constraint forall(i in 0..steps)(alldifferent(spot_color_states[i, ..]));
% Rotation move should change cube state:
constraint forall(i in 0..(steps-1))(rotation_should_be_applied(i));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solve minimize steps;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output 
["Steps   = ", show(steps), ";\n"] ++
["Initial = ", show(rotation_states[0, ..]) ++ show(spot_color_states[0, ..]), ";\n"] ++ 
["Operations:", "\n"] ++ 
[
  show(moves_corner[i]) ++ " " ++ show(moves_kind[i]) ++ " -> " ++ show(rotation_states[i + 1, ..]) ++ show(spot_color_states[i + 1, ..]) ++ "\n" 
  | i in 0..MAX_MOVES where fix(i < steps)
]; 



