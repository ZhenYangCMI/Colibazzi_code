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

% 4. group analysis
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
    
    % 5. convert t to Z
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
