% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc
project='Colibazzi'
preprocessDate='2_22_14';
% Initiate the settings.
% 1. define Dir
% for numerical ID
%subList=load('/home/data/Projects/Colibazzi/data/patients_51sub.txt');
% for text ID
% subListFile='/home/data/Projects/Colibazzi/data/subClean_step2.txt';
% subList1=fopen(subListFile);
% subList=textscan(subList1, '%s', 'delimiter', '\n')
% subList=cell2mat(subList{1})

%numSub=length(subList)

%measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'SCA1', 'SCA2', 'SCA3', 'SCA4'...
%'SCA5', 'SCA6', 'SCA7', 'SCA8', 'SCA9', 'SCA10', 'SCA11', 'SCA12','SCAlGpi', 'SCArGpi', 'SCAVTA', 'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7', 'CWASROI1', 'CWASROI2'};
measureList={'DegreeCentrality' }
numMeasure=length(measureList)

GroupAnalysis=['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/wholeBrainDimAnalysis/'];

% 2. set path
addpath /home/data/HeadMotion_YCG/YAN_Program/mdmp
addpath /home/data/HeadMotion_YCG/YAN_Program
addpath /home/data/HeadMotion_YCG/YAN_Program/TRT
addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.2_130309
addpath /home/data/HeadMotion_YCG/YAN_Program/spm8
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
Error=[];
addpath([ProgramPath,filesep,'Subfunctions']);
[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));

% 3. load covariates
modelSymptom=load(['/home/data/Projects/', project, '/data/regression50patients.txt']);
modelOutcome=load(['/home/data/Projects/', project, '/data/regression39patients.txt']);

% 4. check the relationship between global variable and the variable of
% interests

% for j=1:numMeasure
%     measure=char(measureList{j})
%
%     glob=load(['/home/data/Projects/workingMemory/results/CPAC_analysis_new/reorgnized/meanRegress/', measure, '/', measure, '_MeanSTD.mat'])
%     globMean=glob.Mean_AllSub;
%     globStd=glob.Std_AllSub;
%
%     % check the correlation between the global variables and the age, DF, DB, DTot
%     figure(j)
%     for i=1:8
%
%         % scatter plot the global Mean and variable of interests and
%         % calculate the partial correlation with motion controlled
%         if i<5
%             subplot(2,4,i)
%             scatter(globMean, model(:,i+2))
%             [r, p]=partialcorr(globMean, model(:,i+2), model(:, 11));
%             lsline
%             ylim([0 20])
%             if strcmp(measure, 'ReHo')
%                 xlim([0.05 0.15])
%             elseif strcmp(measure, 'DegreeCentrality')
%                 xlim([2000 8000])
%             elseif strcmp(measure, 'VMHC')
%                 xlim([0.2 0.8])
%             end
%             if i==1;
%                 r
%                 p
%             end
%         else
%             subplot(2,4,i)
%             scatter(globStd, model(:,i-2))
%             [r, p]=partialcorr(globStd, model(:,i-2), model(:, 11));
%             lsline
%             ylim([0 20])
%             if strcmp(measure, 'ReHo')
%                 xlim([0.02 0.08])
%             elseif strcmp(measure, 'DegreeCentrality')
%                 xlim([0 3000])
%             elseif strcmp(measure, 'fALFF')
%                 xlim([0 0.15])
%             elseif strcmp(measure, 'VMHC')
%                 xlim([0.2 0.3])
%             elseif strcmp(measure, 'skewness')
%                 xlim([0.04 0.06])
%             else
%                 xlim([0 20])
%             end
%             if i==5;
%                 r
%                 p
%             end
%         end
%     end
%     saveas(figure(j), ['/home/data/Projects/workingMemory/figs/CPACpreprocessedNew/meanRegress/', measure, '_globalVariable_phenotype.png'])
% end

% 5. group analysis

for j=1:numMeasure
    measure=char(measureList{j})
    mkdir([GroupAnalysis,measure]);
    outDir=[GroupAnalysis,measure];
    if strcmp(measure, 'CWASROI1') || strcmp(measure, 'CWASROI2')
        mask=['/home/data/Projects/', project, '/masks/stdMask_98sub_compCor_100prct.nii'];
    else
        mask=['/home/data/Projects/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];
    end
    
    % perform group analysis
    
    modelist={'modelSymptom', 'modelOutcomeRole', 'modelOutcomeSocial'};
    for k=1:length(modelist)
        modelName=char(modelist{k})
        if strcmp(modelName, 'modelSymptom')
            FileName = {['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_50patients.nii']};
            model=modelSymptom;
            labels={'symptomA_demean', 'symptomB_demean', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 12) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
            
        elseif strcmp(modelName, 'modelOutcomeRole')
            FileName = {['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_39patients.nii']};
            model=modelOutcome;
            labels={'outcomeRole', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        else
            model=modelOutcome;
            FileName = {['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_39patients.nii']};
            labels={'outcomeSocial', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 12) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        end
        
        OutputName=[outDir,filesep, measure, '_', modelName]
        y_GroupAnalysis_Image(FileName,regressionModel,OutputName,mask);
        
        % 6. convert t to Z
        if strcmp(modelName, 'modelSymptom')
            effectList={'T1', 'T2'};
        else
            effectList={'T1'};
        end
        
        nSub=size(regressionModel, 1);
        nCov=size(regressionModel, 2)
        Df1=nSub-nCov; % N-k-1=50-7=43 for symptome; % N-k=39-6=33; for outcome
        
        for k=1:length(effectList)
            effect=char(effectList{k})
            
            ImgFile=[outDir, filesep, measure, '_', modelName, '_', effect, '.nii'];
            OutputName=[outDir, filesep,  measure, '_', modelName, '_', effect, '_Z.nii'];
            Flag='T';
            [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
        end
        
    end
end
