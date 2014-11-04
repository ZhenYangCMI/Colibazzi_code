% This script will compute the ROI based SCA

clear
clc

rmpath /home/milham/matlab/REST_V1.7
rmpath /home/milham/matlab/REST_V1.7/Template
rmpath /home/milham/matlab/REST_V1.7/man
rmpath /home/milham/matlab/REST_V1.7/mask
rmpath /home/milham/matlab/REST_V1.7/rest_spm5_files

restoredefaultpath

addpath(genpath('/home/data/Projects/Zhen/commonCode/spm8'))
addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615
addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615/Subfunctions/
addpath /home/data/Projects/Zhen/commonCode/REST_V1.8_130615

project='Colibazzi'
preprocessingDate='2_22_14';
dataDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/FunImg/'];

% text subList
%subListFile=['/home/data/Projects/', project, '/data/remainingSub.txt'];
%subList1=fopen(subListFile);
%subList=textscan(subList1, '%s', 'delimiter', '\n')
%subList=cell2mat(subList{1})

% numerical subList
subList=load(['/home/data/Projects/Zhen/', project, '/data/patients_51sub.txt']);
numSub=length(subList)
effect='SIPSTOTA_demean' 
MaskData=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_', num2str(numSub), 'sub_3mm_noGSR_100prct.nii.gz'];
mkdir (['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/noGSR/CWAS_', num2str(numSub), 'patients/mdmr3mmFWHM8followUp1'])
outputDir=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/noGSR/CWAS_', num2str(numSub), 'patients/mdmr3mmFWHM8followUp1/'];
for i=1:numSub
 sub=num2str(subList(i)) 
 
%sub=subList(i, 1:9);
    AllVolume=[dataDir, 'normFunImg_', sub, '_3mm_fwhm8_masked.nii.gz'];
    
    %ROIDef={['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/cluster_mask_outcome_SOCIAL_Yeo.nii']}
    ROIDef={['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/CWAS_', num2str(numSub), 'patients/symptomA/cluster_mask_', effect, '.nii']};
    OutputName=[outputDir, 'FC_ROI_', effect, '_', sub];
    IsMultipleLabel=1;
    [FCBrain, Header] = y_SCA(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel);
end


