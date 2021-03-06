%%%%% #1 finding Hinfinity norm using BRL by solving LMI using mincx  %%%%%
A=[-1 0;0 -3];
B=[0 1;2 1];
C=[1 2;1 0];
D=[0 0;0 0];
G=ss(A,B,C,D);
display('the inf norm using hinfnorm function is');
hinfnorm(G)
display('now solving LMI using bounded real lemma, using mincx');
setlmis([]); %initiate a new lmi and clear all previous lmis, if any
LMIs=newlmi; %identifier for the new lmi that we have created for better
%readability, numbers can be used instead.

%declare LMI variables% for BRL we have two variables Y and gamma%
gamma=lmivar(1,[1,1]); %1 means type 1, symmetric. 1 row = 1 diagonal block
%[1= size of diagonal block, 1x1 here. 1= full block]%
Y=lmivar(1,[2,1]);%type 1, 1 diagonal block, 2x2 size block for this 
%system, full symmetric type
%now lmi terms need to be defined for the LMI constraint we have from BRL
lmiterm([LMIs,1,1,Y],1,A,'s');%for A'Y+YA
lmiterm([LMIs,2,1,Y],B',1); %for the term B'Y as (2,1) element
lmiterm([LMIs,3,1,0],C);%for the term C, a constant
lmiterm([LMIs,2,2,gamma],-1,1);%for the term -gamma*I
lmiterm([LMIs,3,2,0],D);%for D
lmiterm([LMIs,3,3,gamma],-1,1);
%to ensure the second constraint that Y is positive definite matrix
Y_pd=newlmi;
lmiterm([Y_pd,1,1,Y],-1,1);
LMIsys=getlmis;

%now define the objective function. Our objective function is gamma, to
%find the inf norm
n=decnbr(LMIsys); %n takes the number of decision variables in the problem
c=zeros(n,1); % c is initialized according to the dimension of dec.var.
for j=1:n
    [gammaj,Yj]=defcx(LMIsys,j,gamma,Y); %evaluates the matrix variables
    %gamma and Y when all elements of decision variable vector are set to 
    %zero except x=j
    c(j)=gammaj; %the objective function vector c is calculated accordingly
end
options = [1e-5,0,0,0,0];
display('the inf norm after solving the lmi using mincx is given by gamma opt')
[copt,xopt] = mincx(LMIsys,c,options);

%Obtaining the optimal Y and the optimal gamma
Yopt = dec2mat(LMIsys,xopt,Y); 
gammaopt=dec2mat(LMIsys,xopt,gamma);
disp('gammaopt is'); 
disp(gammaopt) 
disp('Popt is');
disp(Yopt)

display('now solving the same system using YALMIP toolbox');
pause(3);
%%% #2 finding Hinfinity norm using BRL by solving LMI using the YALMIP toolbox%%%%
A=[-1 0;0 -3];
B=[0 1;2 1];
C=[1 2;1 0];
D=[0 0;0 0];
G=ss(A,B,C,D)
display('the inf norm using hinfnorm function is');
hinfnorm(G)
display('now solving LMI using bounded real lemma, using YALMIP toolbox');
gamma=sdpvar(1,1); 
P=sdpvar(2,2,'symmetric');
appa=A'*P+P*A;
pb=P*B;
c_d=C';
bp=B'*P;
gam=-gamma*eye(2);
d_d=D';
c=C ;
d=D ;
% size(appa)
% size(pb)
% size(c_d)
% size(bp)
% size(gam)
% size(d_d)
% size(c)
% size(d)
P=P>0;
lmi=[appa pb c_d;bp gam d_d;c d gam]<0;
lmi=lmi+P;
%P
options=sdpsettings('solver','lmilab');
diag=optimize(lmi,gamma,options);

display('the value of gamma after solving the lmi is');
gamma=double(gamma)