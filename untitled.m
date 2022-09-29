clc;
clear all;
pk = [3,3];
pk1 = [9,3];

pk_= [-0.15,0.08];
pk1_ = [1,1];

t = 6;

b2 = 3*(pk1 - pk)/(t)^2 - 2*pk_/t - pk1_/t
b3 = 2*(pk - pk1)/((t)^3)  + pk_/(t*t) + pk1_/(t*t)