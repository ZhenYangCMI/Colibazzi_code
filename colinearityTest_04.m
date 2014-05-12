% multicolinearity test for noGSR, GSR, compCor, and meanRegression
clear
clc

numSub=51

model=load(['/home/data/Projects/Colibazzi/data/regressionModelDimentionalAnalysis.txt']);
labelsSymptom={'symptomA', 'symptomB', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'}
    modelSymptom=[model(:, 13) model(:, 19) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(numSub, 1)];

labelsOutcome={'outcomeRole', 'outcomeSocial', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'}
    modelOutcome=[model(:, 11) model(:, 12) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(numSub, 1)];

 
 
% You can also add an interecept term, which reproduces Belsley et al.'s
% example
colldiag(modelSymptom,labelsSymptom)
colldiag(modelOutcome,labelsOutcome)




