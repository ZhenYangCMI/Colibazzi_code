% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc
project='Colibazzi'
preprocessDate='2_22_14';
% Initiate the settings.
% 1. define Dir
% for numerical ID
subList=load('/home/data/Projects/Colibazzi/data/subClean_step2_98sub.txt');
% for text ID
% subListFile='/home/data/Projects/Colibazzi/data/subClean_step2.txt';
% subList1=fopen(subListFile);
% subList=textscan(subList1, '%s', 'delimiter', '\n')
% subList=cell2mat(subList{1})

numSub=length(subList)

measureList={'ROI1', 'ROI2'};
%measureList={'VMHC'}
numMeasure=length(measureList)

mask=['/home/data/Projects/', project, '/masks/stdMask_98sub_compCor_100prct.nii'];

GroupAnalysis=['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/compCor/CWAS_98sub/mdmr3mmFWHM8Model2followUp/regressionAnalysis/'];

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
model=load(['/home/data/Projects/', project, '/data/regressionModel.txt']);

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
    
    FileName = {['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/compCor/CWAS_98sub/mdmr3mmFWHM8Model2followUp/regressionAnalysis/', measure, '_AllVolume_meanRegress.nii']};
    % perform group analysis
    mkdir([GroupAnalysis,measure]);
    outDir=[GroupAnalysis,measure];
    
    % Model 1
    %labels={'group', 'handedness', 'meanFD_demean', 'constant'}
    %regressionModel=[model(:, 2) model(:, 5) model(:, 10) ones(numSub, 1)];

% Model 2
labels={'group', 'gender', 'handedness', 'age_demean', 'meanFD_demean', 'constant'}
regressionModel=[model(:, 2) model(:, 3) model(:, 5) model(:, 9) model(:, 10) ones(numSub, 1)];

    OutputName=[outDir,filesep, measure]
    y_GroupAnalysis_Image(FileName,regressionModel,OutputName,mask);
    
    % 6. convert t to Z
    effectList={'T1'};
    Df1=91; % N-k-1=98-6-1=91
    
    for k=1:length(effectList)
        effect=char(effectList{k})
        
        ImgFile=[outDir, filesep, measure, '_', effect, '.nii'];
        OutputName=[outDir, filesep,  measure, '_', effect, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
    end
    
    
end
