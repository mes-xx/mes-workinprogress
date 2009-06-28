% Expected rat performance in BCI task. Target size decreases over time as
% rat gets better at the task. Eventually, there is a significant
% difference between the actual performance and chance performance

days = 1:60;

actual = sigmoid(days, 0.33, 0.8);
chance = [sigmoid(days(1:30), 0.33, 0.1), ones(1,30)*0.1];

figure
hold on
plot(days, actual, 'LineWidth', 5)
plot(days, chance, '--k', 'LineWidth', 3)
axis([1 60 0 1])
xlabel('Time')
ylabel('Success rate')
legend('Actual performance', 'Chance performance')