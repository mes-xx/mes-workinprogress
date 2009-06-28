data = cell(100);

period1 = 10; %leave period1 at 10ms (f = 100Hz)
halfwidth = 5; %pulses must be within 3ms to be considered in sync

for period2 = 10:100
    for offset = 0:period2
        makeT;
        temp = cov(wave1, wave2);
        data{period2} = [data{period2} temp(2)];
    end
end
        