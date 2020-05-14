function [twist,Xerr] = FeedbackControl(X,Xd,Xdnxt,kp,ki,dt)
    %X: current configuration
    %Xd: desired configuration
    %Xdnext: next desired configuration
    Xerr=se3ToVec(MatrixLog6(pinv(X)*Xd)); %calculate Xerr in vector form
    Vd= se3ToVec((1/dt)*(MatrixLog6(pinv(Xd)*Xdnxt))); %[Vd] to 6 vector
    twist= (Adjoint((X'*Xd))*Vd)+kp*Xerr+ki*(Xerr*dt);%final formula
end