Y = [1,1,2,1,1];
X = 0:1:4;
Xi = 0:0.1:5;
Yi = pchip(X,Y,Xi);
plot(Xi,Yi,X,Y)