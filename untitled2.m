clear; clc;


t = linspace(0, 3, 100);

for i=1:length(t)
    x(i) = 6 + t(i) + 0.2340*t(i)^2 - 0.078*t(i)^3
    y(i) = t(i) - 0.6067*t(i)^2 + 0.0911*t(i)^3
end

plot(x, y)
hold on;

t = linspace(0, 3*(5^0.5), 100);
for i=1:length(t)
    x(i) = 9 + 0.298*t(i) - 0.4665*t(i)^2 + 0.0430*t(i)^3
    y(i) = -0.18*t(i) + 0.2417*t(i)^2 - 0.0221*t(i)^3
end
plot(x, y)

t = linspace(0, 6, 100);

for i=1:length(t)
    x(i) = 3 - 0.15*t(i) + 0.3833*t(i)^2 - 0.0319*t(i)^3
    y(i) = 3 + 0.08*t(i) - 0.1933*t(i)^2 + 0.0300*t(i)^3
end

 plot(x, y)
 hold off;