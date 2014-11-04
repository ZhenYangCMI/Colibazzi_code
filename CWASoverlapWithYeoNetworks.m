% This script extract ROI mean values for each measure and concate ROImean across all measures
clear
clc
close all

maskDir='/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/';
maskList={'Group_text', 'SIPSTOTA_demean', 'outcome_SOCIAL'};

voxEachNetwork=[];
prctEachNetwork=[];
for i=1:length(maskList)
    mask=char(maskList(i));
    maskFile=[maskDir, 'cluster_mask_', mask, '_Yeo.nii']
    
    [MaskData,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
    
    MaskData1D=reshape(MaskData,[],1);
    
    networkNum=unique(MaskData1D);
    networkNum=networkNum(find(networkNum));
    totVox=length(find(MaskData1D));
    
    for j=1:length(networkNum)
        numVox=length(find(MaskData1D==j));
        prct=numVox/totVox;
        voxEachNetwork(j,i)=numVox;
        prctEachNetwork(j,i)=prct;
    end
end

voxEachNetwork
prctEachNetwork

% based on 3dclustStim (cluster alpha=0.05, voxel p=0.005), cluster
% threshold is 26, 36, and 25 for 'Group_text', 'SIPSTOTA_demean',
% 'outcome_SOCIAL' respectively. according to these threshold, voxels overlapped with network 5 is
% removed from 'Group_text' followup analysis



