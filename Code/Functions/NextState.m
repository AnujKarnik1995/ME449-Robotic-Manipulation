function [newconfig] = NextState (oconfig,jwspeed,timstep,wslimit,jalimit)
    %newconfig: new configuration- 3 var chassis config, 5 joint ang, 4 wheel angles 
    %ncconfig: new chassis configurtion
    %oconfig: current/old configuraion- 3 var for chassis config,... 
    ...5 joint angles for arm, 4 joint angles for wheel 
    %jwspeed: joint-wheel speed-5 joint speeds, 4 wheel speeds
    %timstep: time step
    %wslimit: wheel speed limit
    %jalimit: joint angle limit
   
   owspeeds = [jwspeed(1,6),jwspeed(1,7),jwspeed(1,8),jwspeed(1,9)]; %extract old wheel vel from old speeds 9   
   njangle = oconfig(1,4:8) + timstep*jwspeed(1,1:5);
   i=1; % to conform to joint speed limits
   while i<6
       if njangle(1,i)>=jalimit
           njangle(1,i)=jalimit;
       end
       if njangle(1,i)<=-jalimit
           njangle(1,i)=-jalimit;
       end
       i=i+1;
   end
   ncconfig = chassistwister(oconfig,owspeeds,wslimit); % create new chassis config
   nwangle = oconfig(1,9:12) + timstep*owspeeds(1,1:4);
   newconfig=[ncconfig,njangle,nwangle,0];
   %new configuration with gripper state from old configuration.
   
end