
% %
% hopper(m1,m2,k,1,R)
%
% Function to calculate the trajectory of the hopper for a given set of
% parameters.
% Inputs: 
%   m1: rod mass
%   m2: reaction mass
%   k: spring constant
%   l: rest length of tubing
%   R: radius of reaction mass ring
%
% Outputs:
%   t: time vector returned from ODE45
%   y: matrix of state vectors returned from ODE45:
%       [postx posty reactionmassx reactionmassy ...
%           vpostx vposty reactionmassvx reactionmassvy]

function [t,Y]=hopper(m1,m2,k,l,R) 

% Set the events to capture end of simulation condition
options=odeset('Events',@events); %Stop when we hit the ground

% Set initial conditions
% [postx posty reactionmassx reactionmassy vpostx vposty etc]
X=[0;0;0;-1;0;0;0;0]; 

% Calculate the trajectory, with a fixed timestep to facilitate animations.
[t,Y]=ode45(@dHopperdt,[0:0.003:10],X,options);  

% rate function called by ode45; 
% passes back derivatives based on position and velocity
    function res=dHopperdt(t,X) 

    g=10;
    % unpack inputs
    r1=X(1:2);
    r2=X(3:4);
    v1=X(5:6);
    v2=X(7:8);

    % Deal with the rod normal force possibilities:
    % make sure that if post is on the ground, it does not move unless pulled up.
    if r1(2)<=0
        ay1=max(-springforce(r1,r2)/m1 - g,0); 
    else
        ay1=-springforce(r1,r2)/m1 - g;
    end

    % Deal with the reaction mass    
    ay2=springforce(r1,r2)/m2 - g; 
    ax1=0;
    ax2=0;

    % Pass out the results
    res=[v1;v2;ax1;ay1;ax2;ay2]; % note that v1 and v2 are each two elements.

    
% springforce(r1,r2)
%
% simple function to calculate the force in the y direction due
% to the angled springs
% takes current positions of masses as input
% and returns the force in the y direction
        function res=springforce(r1,r2)
            
            y1=r1(2);
            y2=r2(2);
            res=k*(sqrt(R^2+(y1-y2)^2)-l)*(y1-y2)/sqrt(R^2+(y1-y2)^2);
        end


    end

% Events funtion to check if we hit the ground and terminate is so
% (actually a little below it to avoid errors associated with the if statement)
    function [value, isterminal,direction] = events(t,X)
            value=X(2)+0.1; 
            isterminal=1;
            direction=-1;
    end
end