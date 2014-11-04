% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc

% 1. set path
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

% 2. Initiate the settings.
project='Colibazzi'
preprocessDate='2_22_14';

%effectList={'SIPSTOTA_demean', 'outcome_SOCIAL'};
effectList={'outcome_SOCIAL'};

GroupAnalysis=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/wholeBrainDimAnalysis/'];

for k=1:length(effectList)
    effect=char(effectList(k));
    
    if strcmp(effect, 'SIPSTOTA_demean')
        measureList={'SIPSTOTA_demean_ROI1','SIPSTOTA_demean_ROI2', 'SIPSTOTA_demean_ROI3', 'SIPSTOTA_demean_ROI4','SIPSTOTA_demean_ROI5', 'SIPSTOTA_demean_ROI6', 'SIPSTOTA_demean_ROI7' }
        model=load('/home/data/Projects/Zhen/Colibazzi/data/regression51patients.txt');
        mask='/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_51sub_3mm_noGSR_100prct.nii.gz';
    else
        measureList={'outcome_SOCIAL_ROI1','outcome_SOCIAL_ROI2', 'outcome_SOCIAL_ROI3', 'outcome_SOCIAL_ROI4','outcome_SOCIAL_ROI5', 'outcome_SOCIAL_ROI6', 'outcome_SOCIAL_ROI7' }
        model=load('/home/data/Projects/Zhen/Colibazzi/data/regression40patients.txt');
        mask='/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_40sub_3mm_noGSR_100prct.nii.gz';
    end
    numMeasure=length(measureList)
    
    
    % 3. group analysis
    for j=1:numMeasure
        measure=char(measureList{j})
        mkdir([GroupAnalysis,measure]);
        outDir=[GroupAnalysis,measure];
        FileName = {['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', measure, '/', measure, '_AllVolume_meanRegress.nii']};
        
        if strcmp(effect, 'SIPSTOTA_demean')
            labels={'symptomA_demean', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        else
            labels={'outcomeSocial', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'};
            regressionModel=[model(:, 11) model(:, 9) model(:, 10) model(:, 3) model(:, 5) ones(size(model, 1), 1)];
        end
        
        OutputName=[outDir,filesep, measure]
        y_GroupAnalysis_Image(FileName,regressionModel,OutputName,mask);
        
        % 6. convert t to Z
        
        
        nSub=size(regressionModel, 1);
        nCov=size(regressionModel, 2)
        Df1=nSub-nCov; % N-k-1=50-7=43 for symptome; % N-k=39-6=33; for outcome
        
        
        effect='T1'
        
        ImgFile=[outDir, filesep, measure, '_', effect, '.nii'];
        OutputName=[outDir, filesep,  measure, '_', effect, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
        
        
    end
end
