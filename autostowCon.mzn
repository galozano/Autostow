%includes
include "regular.mzn";

% global variables
int: numberOfCranes;
int: numberOfStowFactors; 
int: totalTimeSlots;
int: totalOfContainers;

set of int: Cranes = 1..numberOfCranes;
set of int: StowFactors = 1..numberOfStowFactors;
set of int: TimeSlots = 1..totalTimeSlots;
set of int: Containers = 1..totalOfContainers;

array[Containers, StowFactors] of int: inventory;
array[Containers, Cranes] of int: craneAssignment;
array[StowFactors, TimeSlots] of int: craneStowList;

array[Containers, Containers] of bool: dependencies; 
array[Containers, Containers] of bool: twinContainers;
array[Containers, TimeSlots] of bool: specificContainers;

%Var
array[Containers, Cranes, StowFactors, TimeSlots] of var bool: assignments;

%Names
array[Cranes] of string: craneNames;
array[StowFactors] of string: stowFactorsNames;
array[Containers] of string: containersNames;

%For each crane in each timeslot there can be only one crane assigned
constraint forall(c in Containers, q in Cranes, t in TimeSlots)
            (sum(s in StowFactors) (bool2int(assignments[c, q, s, t])) <= 1);  

%Number of sssignments must be lower than number of each time slot
constraint forall(s in StowFactors, t in TimeSlots)
            (sum(q in Cranes, c in Containers) (bool2int(assignments[c, q, s, t])) >= craneStowList[s, t]);

%Assignments must be lower than what is on inventory
constraint forall(c in Containers, s in StowFactors)
             (sum(t in TimeSlots, q in Cranes) (bool2int(assignments[c, q, s, t])) <= inventory[c,s]);

%Assignments for each crane should be equal to assignment of the crane
constraint forall(c in Containers, q in Cranes)
              (sum(t in TimeSlots, s in StowFactors) (bool2int(assignments[c, q, s, t])) <= craneAssignment[c,q]);

%Make sure dependencies are met
constraint forall(c, c1 in Containers)
              (forall(t, t1 in TimeSlots)
              ( if dependencies[c,c1] /\ (sum(s in StowFactors, q in Cranes) (bool2int(assignments[c, q, s, t])) >= 1)  
                                      /\ (sum(s in StowFactors, q in Cranes) (bool2int(assignments[c1, q, s, t1])) >= 1)
                then (t-t1 > 0) else true endif));

%Make sure twin containers are next to each other with same crane
constraint forall(c, c1 in Containers)
             (forall(t, t1 in TimeSlots)
              (if twinContainers[c,c1] /\ (sum(s in StowFactors, q in Cranes) (bool2int(assignments[c, q, s, t])) >= 1)
                                       /\ (sum(s in StowFactors, q in Cranes) (bool2int(assignments[c1, q, s, t1])) >= 1)
                then abs(t - t1) == 1 else true endif));

%Make sure specific container are in the right place
constraint forall(c in Containers, t in TimeSlots)
              (if specificContainers[c, t] then (sum(s in StowFactors, q in Cranes) (bool2int(assignments[c, q, s, t]))) >= 1 else true endif);


solve maximize (sum(q in Cranes)
  (sum(t,t1 in TimeSlots where t < t1)
    ( if (sum(s in StowFactors,c in Containers)(bool2int(assignments[c, q, s, t]))) >= 1 
      /\ (sum(s in StowFactors,c in Containers) (bool2int(assignments[c, q, s, t1]))) >= 1 then (t1-t) else 0 endif )));

%solve satisfy;

%Output 1
output [ "Number of Cranes:", show(numberOfCranes) ++ "\n"]  ++
[ if show(assignments[c, q, s, t])== "true" then " T: " ++ show(t) ++ "\t S: " ++ show(s) ++ "\t C: " ++ show(c) ++ "\t Q:"++ show(q) ++"\n" else "" endif| t in TimeSlots, s in StowFactors ,c in Containers, q in Cranes] 

%Output 2
%output [ "Number of Cranes:", show(numberOfCranes) ++ "\n"]  ++
%[ if show(assignments[c, q, s, t])== "true" then " T: " ++ show(t) ++ "\t S: " ++ stowFactorsNames[fix(s)] ++ "\t C: " ++ containersNames[fix(c)] ++ "\t Q:"++ %craneNames[fix(q)] ++"\n" else "" endif| t in TimeSlots, s in StowFactors ,c in Containers, q in Cranes] 
