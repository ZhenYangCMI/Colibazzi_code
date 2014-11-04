
% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc
project='Colibazzi'
preprocessDate='2_22_14';
% Initiate the settings.
% 1. define Dir
% for numerical ID
subList=load('/home/data/Projects/Zhen/Colibazzi/data/final/subClean_step2_98sub.txt');
% for text ID
% subListFile='/home/data/Projects/Zhen/Colibazzi/data/subClean_step2.txt';
% subList1=fopen(subListFile);
% subList=textscan(subList1, '%s', 'delimiter', '\n')
% subList=cell2mat(subList{1})

numSub=length(subList)

% used for 2mm resolution variables (univariate approaches)
%measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1','DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'SCA1', 'SCA2', 'SCA3', 'SCA4'...
%'SCA5', 'SCA6', 'SCA7', 'SCA8', 'SCA9', 'SCA10', 'SCA11', 'SCA12','SCAlGpi', 'SCArGpi', 'SCAVTA', 'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7'};
%measureList={'VMHC'}
%mask=['/home/data/Projects/Zhen/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];
%mask=['/home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask_90prct.nii'];

% used for 3mm resolution variables (MDMR followup)
%measureList={'Group_text_ROI1', 'Group_text_ROI2', 'Group_text_ROI3','Group_text_ROI4', 'Group_text_ROI5', 'Group_text_ROI6'};
measureList={'SCA_ThalROI_BasedOnMDMRoverlapNet6ClusterCMiFC'};
mask=['/home/data/Projects/Zhen/Colibazzi/masks/final/stdMask_98sub_3mm_noGSR_100prct.nii.gz'];
%mask=['/home/data/Projects/Zhen/Colibazzi/masks/meanStandFunMask_98sub_90prct.nii'];

numMeasure=length(measureList)

GroupAnalysis=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/groupAnalysis98sub/'];

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
model=load(['/home/data/Projects/Zhen/', project, '/data/final/regressionModel.txt']);

% 4. group analysis
for j=1:numMeasure
    measure=char(measureList{j})
    
    FileName = {['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_98sub.nii']};
    
    % perform group analysis
    mkdir([GroupAnalysis,measure]);                                                                                                                                                                                            
    outDir=[GroupAnalysis,measure];
    
    % Model 1
    %labels={'group', 'handedness', 'meanFD_demean', 'constant'}
    %regressionModel=[model(:, 2) model(:, 5) model(:, 10) ones(numSub, 1)];
    
    % Model 2 used in final results
    labels={'group', 'gender', 'handedness', 'age_demean', 'meanFD_demean', 'constant'}
    regressionModel=[model(:, 2) model(:, 3) model(:, 5) model(:, 9) model(:, 10) ones(numSub, 1)];
    
    OutputName=[outDir,filesep, measure]
    y_GroupAnalysis_Image(FileName,regressionModel,OutputName,mask);
    
    % 6. convert t to Z
    effectList={'T1'};
    Df1=numSub-size(regressionModel, 2); % for model 1: N-k-1=98-4-1=93; for model 2: Df1=92
    
    for k=1:length(effectList)
        effect=char(effectList{k})
        
        ImgFile=[outDir, filesep, measure, '_', effect, '.nii'];
        OutputName=[outDir, filesep,  measure, '_', effect, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
    end
    
    
end
