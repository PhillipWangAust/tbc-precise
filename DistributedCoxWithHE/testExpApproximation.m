x = -20:0.1:20;
y = exp(x);

y1 = 1;

for i = 1:100
    y1 = y1 + (x.^i)/factorial(i);
end

figure(1);
plot(x, y, 'b', x, y1, 'r');

mean(abs(y - y1))
