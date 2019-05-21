% check the behavior of pi_bar depending on the value of v

b = 0:0.02:3;
c = 3;
delta = 2/3;
max_v = max((c-b)./delta);
v = 0:0.01:max_v;

% numerator:
fun_num = @(v,b) (b + delta.*v) - (c-b)./delta;

% denominator:
fun_den = @(v,b) (b + delta.*v) - (c-b);

% fraction:
fun_frac = @(v,b) fun_num(v,b)./fun_den(v,b);

num = zeros(length(v),length(b));
den = zeros(length(v),length(b));
frac = zeros(length(v),length(b));

for i=1:length(b)
num(:,i) = fun_num(v,b(i));
den(:,i) = fun_den(v,b(i));
frac(:,i) = fun_frac(v,b(i));
end

%
figure
plot(v(1:20),num(1:20,:)); title('Numerator')
figure
plot(v,den); title('Denominator')

xcoord = v;
figure
plot(xcoord(abs(frac(:,111))<=1),frac(abs(frac)<=1)); title('Fraction')


plot(v,frac(:,85:151))






