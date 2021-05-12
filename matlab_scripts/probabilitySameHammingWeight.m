rng shuffle

count = 0;
experiments = 10000000;
for i = 1 : experiments
    a = randi([0 131071]);
    b = randi([0 131071]);
    a = hammingWeight(a);
    b = hammingWeight(b);
    if a == b
        count = count + 1;
    end
end

disp(count)
prob = count / experiments;
disp(prob)