% colors: // TODO: to enum
% 	1.red
% 	2.white
% 	3.green
% 	4.orange
%  	5.blue
%  	6.yellow
int: COLOR_COUNT = 6; 
set of int: COLOR = 1..COLOR_COUNT;

int: ROTATION_MAX = 2;
set of int: ROTATION_STATE = 0..ROTATION_MAX;

int: ROTATABLE_CORNERS_COUNT = 3;
set of int: CORNER = 1..ROTATABLE_CORNERS_COUNT;

enum Rotation_move = { Clockwise, CounterClockwise };
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cube configuration:
array[CORNER] of ROTATION_STATE: corners_rotation;
array[COLOR] of COLOR: spot_colors;
int: MAX_MOVES;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solved:
array[CORNER] of ROTATION_STATE: solved_rotation = [0, 0, 0];
array[COLOR] of COLOR: solved_spot_colors = [1, 2, 3, 4, 5, 6];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set of int: MOVES = 0..MAX_MOVES;
set of int: STATES = 0..MAX_MOVES+1;
var MOVES: steps;
array[MOVES] of var Rotation_move: moves_kind;
array[MOVES] of var CORNER: moves_corner;
array[MOVES, CORNER] of var ROTATION_STATE: rotation_states;
array[MOVES, COLOR] of var COLOR: spot_color_states;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constraint rotation_states[0, ..] = corners_rotation;
constraint spot_color_states[0, ..] = spot_colors;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% there need to be a solution:
constraint steps <= MAX_MOVES;
% solution must be solved:
constraint forall(i in CORNER)(rotation_states[steps, i] = solved_rotation[i]);
constraint forall(i in COLOR)(spot_color_states[steps, i] = solved_spot_colors[i]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solve minimize steps;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output 
["Steps = ", show(steps), ";\n"] ++
["Operations:", "\n"] ++ 
[
  show(moves_corner[i]) ++ " " ++ show(moves_kind[i]) ++ "\n" | i in 0..MAX_MOVES where fix(i < steps)
]; 



