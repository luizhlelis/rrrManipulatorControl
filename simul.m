clc;
clear all;
close all;

% tf1 = 2 polos, 1 zero, sem atraso
% tf3 = 1 polo, 1 zero, sem atraso

mat = load('entradaSaida.mat','-mat');

inOutMat = mat.entradaSaidaTemp;
inMat = inOutMat(:,1);
[inMatRows,inMatCols] = size(inMat)
outMat = inOutMat(:,2);

% Condicoes iniciais iguais a zero
filtIn = inMat(904:inMatRows)-20;
filtOut = outMat(904:inMatRows)-36.29;

[inRows,inCols] = size(filtIn)

% TF 1
tf1Mat = load('tfs/tf1.mat','-mat');
tf1 = tf1Mat.tf1;
tf1 = tf(tf1.Numerator,tf1.Denominator)
t = 0:1:(inRows-1);
resp1 = lsim(tf1,filtIn,t);

% % TF 2
% tf2Mat = load('tfs/tf2.mat','-mat');
% tf2 = tf2Mat.tf2;
% tf2 = tf(tf2.Numerator,tf2.Denominator,'InputDelay',tf1.IODelay)
% t = 0:1:(inMatRows-1);
% resp2 = lsim(tf2,inMat,t);
% 
% % TF 3
% tf3Mat = load('tfs/tf3.mat','-mat');
% tf3 = tf3Mat.tf3;
% tf3 = tf(tf3.Numerator,tf3.Denominator)
% t = 0:1:(inMatRows-1);
% resp3 = lsim(tf3,inMat,t);

figure(1)
plot(filtIn,'g')
hold on
plot(filtOut,'b')
hold on
plot(resp1,'r')

%sisotool(tf1)

contPI = tf([33.731 33.731*0.009023],[1 0]);
temp1 = series(contPI,tf1);
temp2 = feedback(temp1,1);

% contPI = tf([38.359 0.009023],[1 0]);
% temp1 = series(contPI,tf1);
% temp2 = feedback(temp1,1);

temp3 = feedback(tf1,1);

temp4 = feedback(contPI,tf1);

figure(2)
step(14*temp2)
hold on
step(14*temp3)

figure(3)
step(14*temp4)


% Atraso de fase
%   33.3 (s+0.01147)
%   ----------------
%     (s+0.003774)

% PI
%   33.731 (s+0.009023)
%   -------------------
%            s

%   38.359 (s+0.01109)
%   ------------------
%           s