% This script extract ROI mean values for each measure and concate ROImean across all measures
clear
clc
close all

project='Colibazzi';
measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'SCA1', 'SCA2', 'SCA3', 'SCA4'...
'SCA5', 'SCA6', 'SCA7', 'SCA8', 'SCA9', 'SCA10', 'SCA11', 'SCA12','SCAlGpi', 'SCArGpi', 'SCAVTA', 'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7', 'CWASROI1', 'CWASROI2'};
%measureList={'ReHo', 'DegreeCentrality'}
%T1:Group effect
T='T1'
numClusters=zeros(length(measureList), 2);
% load subList
subList=load(['/home/data/Projects/', project, '/data/patients_51sub.txt']);
numSub=length(subList)
outputDir=['/home/data/Projects/', project, '/results/CPAC_zy2_22_14_reorganized/ROIDimAnalysis/'];
clustMeanConcate=[];

for i=1:length(measureList)
measure=measureList{i}
	if strcmp(measure, 'CWASROI1') || strcmp(measure, 'CWASROI2')
	mask=['/home/data/Projects/', project, '/masks/stdMask_98sub_compCor_100prct.nii'];
	else
	mask=['/home/data/Projects/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];
	end

% load the full brain mask

[MaskData,VoxDimMask,HeaderMask]=rest_readfile(mask);
% MaskData=rest_loadmask(nDim1, nDim2, nDim3, [maskDir,'stdMask_fullBrain_68sub_90percent.nii']);
MaskData =logical(MaskData);%Revise the mask to ensure that it contain only 0 and 1
MaskDataOneDim=reshape(MaskData,[],1)';
MaskIndex = find(MaskDataOneDim);

file=['/home/data/Projects/', project, '/results/CPAC_zy2_22_14_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_51patients.nii'];
[AllVolume,VoxelSize,theImgFileList, Header] =rest_to4d(file);
    
% reshape the data read in and mask out the regions outside of the brain
    [nDim1,nDim2,nDim3,nSub]=size(AllVolume);
    AllVolume=reshape(AllVolume,[],nSub)';
    AllVolume=AllVolume(:, MaskIndex);

% exatract the ROI mean for neg clusters
maskFileNeg=['/home/data/Projects/Colibazzi/masks/ROImasksForDimensionalAnalysis/cluster_mask_', measure, '_T1_Z_neg.nii']
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
maskFilePos=['/home/data/Projects/Colibazzi/masks/ROImasksForDimensionalAnalysis/cluster_mask_', measure, '_T1_Z_pos.nii']
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

% NP 'age_demean', 'DS_FT_demean', 'DS_BT_demean', 'ageByFTdemean', 'ageByBTdemean', 'WASI_Full4IQ_demean', 'meanFDJenk_demean', 'hand_demean'
%clustMeanAndNP=horzcat(clustMeanNeg2D, clustMeanPos2D, NP(:,6), NP(:, 8:11), NP(:, 14:16));

totNumClusters=sum(numClusters(:,1))+sum(numClusters(:, 2))
save([outputDir, 'ROImeanAllMeasures_totol', num2str(totNumClusters), 'clusters.txt'],'-ascii','-double','-tabs', 'clustMeanConcate')

save([outputDir, 'numClustersEachMeasure.txt'],'-ascii', '-tabs', 'numClusters')


