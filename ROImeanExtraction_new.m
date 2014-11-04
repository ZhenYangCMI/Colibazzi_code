% This script extract ROI mean values for each measure and concate ROImean across all measures
clear
clc
close all

project='Colibazzi';

measureList={'DegreeCentrality', 'VMHC','SCATHAL1', 'SCATHAL2', 'SCATHAL6', 'Group_text_ROI1', 'Group_text_ROI2', 'Group_text_ROI3','Group_text_ROI4', 'Group_text_ROI5', 'Group_text_ROI6' }
%T1:Group effect
T='T1'
numClusters=zeros(length(measureList), 2);
% load subList
subList=load(['/home/data/Projects/Zhen/', project, '/data/subClean_step2_98sub.txt']);
numSub=length(subList)
outputDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/ROIbasedDimAnalysis/'];
clustMeanConcate=[];

for i=1:length(measureList)
    measure=measureList{i}
    if strcmp(measure(1:4), 'Grou')
        mask=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_98sub_3mm_noGSR_100prct.nii.gz'];
    elseif strcmp(measure(1:4), 'VMHC')
mask=['/home/data/Projects/Zhen/Colibazzi/masks/VMHC_98sub_mask_90prct_L.nii'];
else
        mask=['/home/data/Projects/Zhen/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];
    end
    
    % load the full brain mask
    
    [MaskData,VoxDimMask,HeaderMask]=rest_readfile(mask);
    % MaskData=rest_loadmask(nDim1, nDim2, nDim3, [maskDir,'stdMask_fullBrain_68sub_90percent.nii']);
    MaskData =logical(MaskData);%Revise the mask to ensure that it contain only 0 and 1
    MaskDataOneDim=reshape(MaskData,[],1)';
    MaskIndex = find(MaskDataOneDim);
    
    
    file=['/home/data/Projects/', project, '/results/CPAC_zy2_22_14_reorganized/meanRegress_new/', measure, '/', measure, '_AllVolume_meanRegress_', num2str(numSub), 'sub.nii'];
    
    
    
    [AllVolume,VoxelSize,theImgFileList, Header] =rest_to4d(file);
    
    % reshape the data read in and mask out the regions outside of the brain
    [nDim1,nDim2,nDim3,nSub]=size(AllVolume);
    AllVolume=reshape(AllVolume,[],nSub)';
    AllVolume=AllVolume(:, MaskIndex);
    
    % exatract the ROI mean for neg clusters
    if strcmp(measure(1:4), 'Grou')
        maskFileNeg=['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/groupEffect_MDMRfollowup/cluster_mask_', measure, '_T1_Z_neg.nii.gz'];
    else
        maskFileNeg=['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/groupEffect_univariate/cluster_mask_', measure, '_T1_Z_neg.nii.gz']
    end
    
    [OutdataNegROI,VoxDimNegROI,HeaderNegROI]=rest_readfile(maskFileNeg);
    [nDim1NegROI nDim2NegROI nDim3NegROI]=size(OutdataNegROI);
    NegROI1D=reshape(OutdataNegROI, [], 1)';
    NegROI1D=NegROI1D(1, MaskIndex);
    numNegClust=length(unique(NegROI1D(find(NegROI1D~=0))))
    numClusters(i, 1)=numNegClust;
    
    clustMeanNeg=zeros(numSub, numNegClust);
    for j=1:numNegClust
        ROI=AllVolume(:, find(NegROI1D==j));
        avg=mean(ROI, 2);
        clustMeanNeg(:, j)=avg;
    end
    
    % extract the ROI mean for pos clusters
    if strcmp(measure(1:4), 'Grou')
        maskFilePos=['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/groupEffect_MDMRfollowup/cluster_mask_', measure, '_T1_Z_pos.nii.gz'];
    else
        maskFilePos=['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/groupEffect_univariate/cluster_mask_', measure, '_T1_Z_pos.nii.gz']
    end
    
    [OutdataPosROI,VoxDimPosROI,HeaderPosROI]=rest_readfile(maskFilePos);
    [nDim1PosROI nDim2PosROI nDim3PosROI]=size(OutdataPosROI);
    PosROI1D=reshape(OutdataPosROI, [], 1)';
    PosROI1D=PosROI1D(1, MaskIndex);
    numPosClust=length(unique(PosROI1D(find(PosROI1D~=0))))
    numClusters(i,2)=numPosClust;
    
    clustMeanPos=zeros(numSub, numPosClust);
    for k=1:numPosClust
        ROI=AllVolume(:, find(PosROI1D==k));
        avg=mean(ROI, 2);
        clustMeanPos(:, k)=avg;
    end
    
    clustMean=[clustMeanNeg, clustMeanPos];
    clustMeanConcate=[clustMeanConcate, clustMean];
end

totNumClusters=sum(numClusters(:,1))+sum(numClusters(:, 2))
save([outputDir, 'ROImeanAllMeasures_totol', num2str(totNumClusters), 'clusters_', num2str(numSub), 'sub.txt'],'-ascii','-double','-tabs', 'clustMeanConcate')

%save([outputDir, 'numClustersEachMeasure.txt'],'-ascii', '-tabs', 'numClusters')


