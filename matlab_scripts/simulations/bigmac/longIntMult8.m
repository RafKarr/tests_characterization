function w = longIntMult8(a,b)

a = vpi(a);
b = vpi(b);

%call leakage model
leakageModel8(a,b);

w = a*b;
end