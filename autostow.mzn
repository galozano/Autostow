%-----------------------------------------------------------------
% Includes
%-----------------------------------------------------------------

include "regular.mzn";

%-----------------------------------------------------------------
% Parameters
%-----------------------------------------------------------------

% global variables
int: number_of_cranes;
int: number_of_stow_factors; 
int: total_time_slots;

%float: time_per_time_slot;

set of int: Cranes = 1..number_of_cranes;
set of int: StowFactors = 1..number_of_stow_factors;
set of int: TimeSlots = 1..total_time_slots;

%Number of stow factor per crane
array[StowFactors, Cranes] of int: inventory;

%Number of stow factor per timeslot
array[StowFactors, TimeSlots] of int: crane_stow_list;

%Dependencies between stowfactors in each crane
array[Cranes, StowFactors, StowFactors] of int: dependencies;

%-----------------------------------------------------------------
% Decision Variables
%-----------------------------------------------------------------

%Assignments of the crane to each stowfactor and to each timeslot
array[StowFactors, TimeSlots, Cranes] of var bool: assignments;

%-----------------------------------------------------------------
% Constraints
%-----------------------------------------------------------------

%For each crane in each timeslot there can be only one crane assigned
constraint forall(c in Cranes, t in TimeSlots)
            (sum(s in StowFactors) (bool2int(assignments[s, t, c])) <= 1);  

%Maje sure the number of assignemts of each time slot is greater or equal to stow list
constraint forall(s in StowFactors, t in TimeSlots)
            (sum(c in Cranes) (bool2int(assignments[s, t, c])) >= crane_stow_list[s, t]) ;

%The number assignemnts of each crane in each stowfactor cant be greater than the one in inventory
constraint forall( c in Cranes, s in StowFactors)
             (sum(t in TimeSlots) (bool2int(assignments[s,t,c])) <= inventory[s, c]);

%Make sure dependencies between stow factors are met in every crane
%constraint forall(c in Cranes)
%            (forall(s, s1 in StowFactors)
%              (forall(t, t1 in TimeSlots) (if dependencies[c, s, s1] > 0 /\ sum(t3 in 0..t) (assignments[s, t3, c])  > dependencies[c, s, s1]
%                                                                         /\ sum(t4 in 0..t2)(assignments[s1, t4, c]) > dependencies[c, s, s1]
%                                           then  (t > t1) else true endif)))


%Twins should always be handle by the same crane at the same time
%constraint forall(c in Cranes)
%            (forall(t in TimeSlots where bool2int(assignments[1,t,c]) >= 1) (bool2int(assignments[1,(t+1),c]) == 1 \/ %bool2int(assignments[1,(t-1),c]) == 1));


solve maximize (sum(c in Cranes)
  (sum(t,t1 in TimeSlots where t < t1)
    ( if (sum(s in StowFactors)(bool2int(assignments[s,t,c]))) >= 1 /\ (sum(s in StowFactors)  (bool2int(assignments[s,t1,c]))) >= 1 then (t1-t) else 0 endif )));

%solve satisfy;

output [ "Number of Cranes:", show(number_of_cranes) ++ "\n"]  ++
[ if show(assignments[s, t, c])== "true" then " T: " ++ show(t) ++ "\t S: " ++ show(s) ++ "\t C: " ++ show(c) ++ "\n" else "" endif| t in TimeSlots, s in StowFactors ,c in Cranes]; 

%["Stow Factor,Crane,Time,Assigned \n"] ++
%[ if show(assignments[s, t, c]) == "true" then show(s) ++ "," ++ show(c) ++ "," ++ show(t) ++ "," ++ %show(assignments[s, t, c]) ++ "\n" else "" endif | s in StowFactors, t in TimeSlots ,c in Cranes] 