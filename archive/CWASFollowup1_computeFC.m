% This script will compute the ROI based SCA

clear
clc

project='Colibazzi'
preprocessingDate='2_22_14';
dataDir=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/noGSR/FunImg_3mm_fwhm8/'];

% text subList
%subListFile=['/home/data/Projects/', project, '/data/remainingSub.txt'];
%subList1=fopen(subListFile);
%subList=textscan(subList1, '%s', 'delimiter', '\n')
%subList=cell2mat(subList{1})

% numerical subList
subList=load(['/home/data/Projects/Zhen/', project, '/data/subClean_step2_98sub.txt']);
numSub=length(subList)
effect='Group_text' 
MaskData=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_', num2str(numSub), 'sub_3mm_noGSR_100prct.nii'];
mkdir (['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/noGSR/CWAS_98sub/mdmr3mmFWHM8followUp'])
outputDir=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/noGSR/CWAS_98sub/mdmr3mmFWHM8followUp/'];
for i=1:numSub
 sub=num2str(subList(i)) 
 
%sub=subList(i, 1:9);
    AllVolume=[dataDir, 'normFunImg_', sub, '_3mm_fwhm8_masked.nii'];
    
    ROIDef={['/home/data/Projects/', project, '/results/CPAC_zy', preprocessingDate, '_reorganized/compCor/CWAS_98sub/mdmr3mmFWHM8Model2/cluster_mask_', effect, '.nii']}
    OutputName=[outputDir, 'FC_ROI_', effect, '_', sub];
    IsMultipleLabel=1;
    [FCBrain, Header] = y_SCA(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel);
end


