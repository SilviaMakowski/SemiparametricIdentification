function Q = myNewtonCotes(fx,x)
    % x must be an equally spaced grid with number of intervals multiple of 5.
    N = length(x)-1;
    h=x(2)-x(1);    
    endpts = fx(1)+fx(end);   
    
    Q = (5*h/288)*(19*endpts+75*sum(fx(2:5:N)+fx(5:5:N))+50*sum(fx(3:5:N)+fx(4:5:N))+38*sum(fx(6:5:N)));
end