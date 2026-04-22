function model = train_model(Xtrain, Ytrain)

model = fitcensemble(Xtrain, Ytrain, 'Method','Bag');

figure;
bar(predictorImportance(model));
title('Feature Importance');
xlabel('Feature Index');
ylabel('Importance');

end