function [Ret] = TrajectoryGenerator(Xstart, Xend, Tf, N, method,gs)
      timegap = Tf / (N - 1);
   
traj = cell(1, N);
[Rstart, pstart] = TransToRp(Xstart);
[Rend, pend] = TransToRp(Xend);
for i = 1: N
    if method == 3
        s = CubicTimeScaling(Tf,timegap * (i - 1));
    else
        s = QuinticTimeScaling(Tf,timegap * (i - 1));
    end
    traj{i} ...
    = [Rstart * MatrixExp3(MatrixLog3(Rstart' * Rend) * s), ...
       pstart + s * (pend - pstart); 0, 0, 0, 1];
      % writes all trajectories as  a 1x13 matrix S
   S(i,:)=[traj{i}(1,1),traj{i}(1,2),traj{i}(1,3),traj{i}(2,1),traj{i}(2,2),traj{i}(2,3),traj{i}(3,1),traj{i}(3,2),traj{i}(3,3),traj{i}(1,4),traj{i}(2,4),traj{i}(3,4),gs];
end
Ret=S; %returns S;
end