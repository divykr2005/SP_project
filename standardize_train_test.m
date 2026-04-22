function [XtrainZ, XtestZ, mu, sigma] = standardize_train_test(Xtrain, Xtest)
%STANDARDIZE_TRAIN_TEST Z-score using training statistics only.

mu = mean(Xtrain, 1);
sigma = std(Xtrain, 0, 1);
sigma(sigma == 0) = 1;

XtrainZ = (Xtrain - mu) ./ sigma;
XtestZ = (Xtest - mu) ./ sigma;
end
