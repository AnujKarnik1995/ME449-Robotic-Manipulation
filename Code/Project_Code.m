clc;
clear all;

%%PASTE INPUTS HERE%%



%--------------------%


%INPUTS FOR TRAJECTORY GENERATION:
Tser=[0,0,1,0;0,1,0,0;-1,0,0,0.5;0,0,0,1]; %reference
cubeinitial=[0,0,1,1; 0,1,0,0;-1,0,0,0.025;0,0,0,1]; %initial cube location
cubefinal= [0,1,0,0;0,0,-1,-1;-1,0,0,0.025;0,0,0,1]; %cube final location
Tse1=cubeinitial+[0,0,0,0;0,0,0,0;0,0,0,0.1;0,0,0,0]; %Standoff (gripper open); (generated w.r.t. cube so no separate transformation matrix needed)
Tse2=cubefinal+[0,0,0,0;0,0,0,0;0,0,0,0.1;0,0,0,0]; %final stand-off;(generated w.r.t. cube so no separate transformation matrix needed)


%GENERATE TRAJECTORIES: P1 TO P8
[P{1}]=TrajectoryGenerator(Tser,Tse1,7,7000,5,0); %reference to standoff
[P{2}]=TrajectoryGenerator(Tse1,cubeinitial,3,300,5,0); %standoff to grasp
[P{3}]=TrajectoryGenerator(cubeinitial,cubeinitial,3,300,5,1); %gripper close
[P{4}]=TrajectoryGenerator(cubeinitial,Tse1,3,300,5,1); %lift after grasp
[P{5}]=TrajectoryGenerator(Tse1,Tse2,8,8000,5,1); %move to drop standoff
[P{6}]=TrajectoryGenerator(Tse2,cubefinal,6,600,5,1); %standoff to ungrasp
[P{7}]=TrajectoryGenerator(cubefinal,cubefinal,3,300,5,0); %gripper open
[P{8}]=TrajectoryGenerator(cubefinal,Tse2,3,300,5,0); %move away 
P=[P{1};P{2};P{3};P{4};P{5};P{6};P{7};P{8}]; %combined trajectory file


% SECONDARY DATA NEEDED FOR JACOBIAN
ablst=[0,0,0,0,0;0,-1,-1,-1,0;1,0,0,0,1;0,-0.5076,-0.3526,-0.2176,0;...
    0.033,0,0,0,0;0,0,0,0,0];                    % Arm B list for jacobian (from wiki) 
Tbo=[1,0,0,0.1662;0,1,0,0;0,0,1,0.0026;0,0,0,1]; %representing O frame in body frame (from wiki)
Moe=[1,0,0,0.033;0,1,0,0;0,0,1,0.6546;0,0,0,1];  % Configuration at home position(from wiki)
F=(0.0475/4)*[-1/0.385,1/0.385,1/0.385,-1/0.385;1,1,1,1;-1,1,-1,1]; % 3x4 F matrix for YouBot control (from text)
F6=zeros(6,4); %declaring 6x4 matrix for base jacobian
F6(3:5,1:4)=F; %inserting values fron F in F6 which is a 6x4 matrix
garbagecon=stcon; %declaring a temporary variable garbage configuration to store current Linear 13 configuration.


%INPUTS FOR FEEDBACK CONTROL:
u=1;  %counter
while u<(size(P,1))  %loop runs till number of total trajectories
Ld=P(u,:); %desired linear 13 configuration 
Ldnxt=P(u+1,:); %desired next linear 13 configuration
armtl=zeros(5,1); %declaring matrix for arm-thetalist 
armtl(1:5,:)= garbagecon(4:8); %arm thetalist_extracted from starting configuration
i=1;
while i<6
    c{i}= MatrixExp6(VecTose3(ablst(:,i)*armtl(i,1)));  %matrix exponential from joint 1 to 5
    i=i+1;
end
Toe= Moe*c{1}*c{2}*c{3}*c{4}*c{5}; %representing end effector in o frame_product of exponentials
clear c; 
X=lin1324(garbagecon,Tbo,Toe); %creating X matrix-current configuration in 4x4 matrix form from Linear 13 form
Xd=[Ld(1,1:3),Ld(1,10);Ld(1,4:6),Ld(1,11);Ld(1,7:9),Ld(1,12);0,0,0,1]; %converting current 13 vector reference to 4x4 matrix
Xdnxt=[Ldnxt(1,1:3),Ldnxt(1,10);Ldnxt(1,4:6),Ldnxt(1,11);Ldnxt(1,7:9),Ldnxt(1,12);0,0,0,1];%converting next 13 vector reference to 4x4 matrix


%CALCULATING JACOBIAN AND PSEUDO INVERSE FOR CALCULATION OF FINAL TWIST (MILESTONE 3)
armjac=JacobianBody(ablst,armtl); %arm jacobian
baseJac=Adjoint(Toe'*Tbo')*F6; %base jacobian
fJac= [baseJac,armjac]; %calculating final jacobian & rounding to 3 places 
psdjac=(pinv(fJac)); %rounding pseudo-inverse of Jacobian upto 3 decimal places


%CALCULATING FINAL TWIST BASED ON FEEDBACK CONTROL FUNCTION
[twist,err]=FeedbackControl(X,Xd,Xdnxt,Kp,Ki,timestep); %calculate twist
outputspeeds=psdjac*twist; %new joint and wheel speeds as column vector
outputspeeds=[outputspeeds(5:9,1);outputspeeds(1:4)]';%new joint and wheel speeds as row vector
Error(u,:)=err; %storing the Xerr value in Error variable.


%DATA FOR NEXT STATE FUNCTION:
New13=NextState(garbagecon,outputspeeds,timestep,wslimit,jalimit); %New Linear 12 vector data stored in matrix
New13(1,13)=Ld(1,13); %adding gripper state from trajectory'S last value
Y(u,:)=[New13]; %matrix Y to store all outputs for CSV generation
garbagecon=New13; %replacing old linear 13 configuration with new configuration
u=u+1; %update counter
end


% PRINTING FINAL TRAJECTORIES TO FILE:
csvwrite("File",Y);


%PLOTTING Xerr:
figure;
plot(Error);
xlabel('Iteration');
ylabel('Error magnitude (m/s,rad/s)');
grid on;
title("Plot of components of Xerr");
legend('\omegax','\omegay','\omegaz','vx','vy','vz');
csvwrite("Xerr list",Error);