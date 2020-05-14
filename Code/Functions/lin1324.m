function[sixMat]=lin1324(lin,T1,T2)
    a=lin(1,1); %chassis config phi from ipconfig
 xo=lin(1,2); %chassis config x from ipconfig
 yo=lin(1,3); %chassis config y from ipconfig
 Tsb=[cos(a),-sin(a),0,xo;sin(a),cos(a),0,yo;0,0,1,0.0963;0,0,0,1]; %formula for transformation b in s frame
 sixMat=Tsb*T1*T2;
end