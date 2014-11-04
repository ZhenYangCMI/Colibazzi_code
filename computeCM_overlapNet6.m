clear
clc
close all

% define path and variables
maskDir='/home/data/Projects/Zhen/Colibazzi/figs/final/MDMR/';
clustList=dir([maskDir, 'OverlapNet6_peakROI_mask.nii'])
resultDir=maskDir;
delete ([resultDir, 'clusterCM.xls'])


% read in the cluster mask
t=1;

for i=1:length(clustList)
    effect=clustList(i).name
    %effect=cellstr(effect(14:end-7));
    str1='A';
    linenumber1=sprintf('%s%d',str1,t);
    xlwrite([resultDir, 'clusterCM.xls'],effect, 'sheet1', linenumber1);
    
    t=t+1;
    linenumber2=sprintf('%s%d',str1,t);
    title={'clustNumber', 'ICenter', 'JCenter', 'KCenter', 'XCenter', 'YCenter', 'ZCenter'};
    xlwrite([resultDir, 'clusterCM.xls'],title, 'sheet1', linenumber2);
    
    %maskFile=[maskDir, 'cluster_mask_', char(effect), '.nii.gz'];
maskFile=[maskDir, char(effect)];
    
    % compute the CM
    
    [Data Head]=rest_ReadNiftiImage(maskFile);
    
    [nDim1 nDim2 nDim3]=size(Data);
    
    [I J K] = ndgrid(1:nDim1,1:nDim2,1:nDim3);
    
    Element = unique(Data);
    Element(1) = []; % This is the background 0
    Table = [];
    for iElement=1:length(Element)
        
        ICenter = mean(I(Data==Element(iElement)));
        JCenter = mean(J(Data==Element(iElement)));
        KCenter = mean(K(Data==Element(iElement)));
        
        Center = Head.mat*[ICenter JCenter KCenter 1]';
        XCenter = Center(1);
        YCenter = Center(2);
        ZCenter = Center(3);
        
        Table = [Table;[iElement,ICenter,JCenter,KCenter,XCenter,YCenter,ZCenter]];
    end
    t=t+1;
    if ~isempty(Table)
        linenumber3=sprintf('%s%d',str1,t);
        xlwrite([resultDir, 'clusterCM.xls'],Table, 'sheet1', linenumber3);
    end
    t=t+size(Table, 1);
end

