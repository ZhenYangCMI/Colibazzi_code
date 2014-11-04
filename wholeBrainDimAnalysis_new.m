% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc
project='Colibazzi'
preprocessDate='2_22_14';
% Initiate the settings.
% 1. define Dir
% for numerical ID

%measureList={'DegreeCentrality', 'SCACaudateL', 'SCACaudateR'}
measureList={'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7', 'VMHC'}

numMeasure=length(measureList)
GroupAnalysis=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/wholeBrainDimAnalysis/'];

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
symptomA=load('/home/data/Projects/Zhen/Colibazzi/data/regression51patients.txt');
outcomeSocial=load('/home/data/Projects/Zhen/Colibazzi/data/regression40patients.txt');

% 4. group analysis
for j=1:numMeasure
    measure=char(measureList{j})
    mkdir([GroupAnalysis,measure]);
    outDir=[GroupAnalysis,measure];
    
    mask=['/home/data/Projects/Zhen/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];
    
    % perform group analysis
    
    modelist={'symptomA', 'outcomeSocial'};
    for k=1:length(modelist)
        modelName=char(modelist{k})
        if strcmp(modelName, 'symptomA')
            FileName = {['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', measure, '/', measure, '_AllVolume_meanRegress_51patients.nii']};
            model=symptomA;
            labels={'symptomA_demean', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        else
            FileName = {['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', measure, '/', measure, '_AllVolume_meanRegress_40patients.nii']};
            model=outcomeSocial;
            labels={'outcomeSocial', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        end
        
        OutputName=[outDir,filesep, measure, '_', modelName]
        y_GroupAnalysis_Image(FileName,regressionModel,OutputName,mask);
        
        % 6. convert t to Z
        
        
        nSub=size(regressionModel, 1);
        nCov=size(regressionModel, 2)
        Df1=nSub-nCov; % N-k-1=50-7=43 for symptome; % N-k=39-6=33; for outcome
        
        
        effect='T1'
        
        ImgFile=[outDir, filesep, measure, '_', modelName, '_', effect, '.nii'];
        OutputName=[outDir, filesep,  measure, '_', modelName, '_', effect, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
        
        
    end
end
