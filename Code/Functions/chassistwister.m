function [newcconfig] = chassistwister(oconfig,owspeeds,wslimit)
   %for youbot; 4 macanum wheel robot
   F=(0.0475/4)*[-1/0.385,1/0.385,1/0.385,-1/0.385;1,1,1,1;-1,1,-1,1]; % F-matrix
   %wheeltl=zeros(4,1); %creating a matrix for wheelspeeds
   i=1;
   while i<5 %to conform to wheel speed limit
       if owspeeds(1,i)>=wslimit
           owspeeds(1,i)=wslimit;
       end
       if owspeeds(1,i)<-wslimit
           owspeeds(1,i)=-wslimit;
       end
           i=i+1;
   end
   Vb=(F*(owspeeds)')'; %calculate 1x3 body twist
   if round(Vb(1,1),3)==0 %conditions for dq (MR page no: 548)
       qb=[0,Vb(1,2),Vb(1,3)];
   end
   if round(Vb(1,1),3) ~= 0.000000 %conditions for dq (MR page no: 548)
       qb=[Vb(1,1),((Vb(1,2)*sin(Vb(1,1))+Vb(1,3)*(cos(Vb(1,1))-1))/Vb(1,1)),...
          (Vb(1,3)*sin(Vb(1,1))+Vb(1,2)*(1-(cos(Vb(1,1))))/Vb(1,1))];
   end
   qs=[1,0,0;0,cos(oconfig(1,1)),-sin(oconfig(1,1));0,sin(oconfig(1,1)),...
       cos(oconfig(1,1))]*transpose(qb);%converting chassis config to space frame
   qs(1,1)=round(qs(1,1),3,"decimals"); %rounding to 3 decimals
   newcconfig=[oconfig(1,1),oconfig(1,2),oconfig(1,3)]+qs'; %new configuration as output for Nextstate
   %newcconfig=newcconfig'% representing configuration as a row vector
end



 