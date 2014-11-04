i

close all
clear all
clc
addpath /home/data/Projects/Zhen/commonCode
codeDir='/home/data/Projects/Zhen/commonCode/';

javaaddpath([codeDir, 'poi_library/poi-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-schemas-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/xmlbeans-2.3.0.jar']);
javaaddpath([codeDir, 'poi_library/dom4j-1.6.1.jar']);
javaaddpath([codeDir, 'poi_library/stax-api-1.0.1.jar']);


% define path and variables
maskDir='/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/MDMR/';
atlasDir='/home2/data/Projects/Zhen/workingMemory/mask/atlas/';

clustList=dir([maskDir, 'cluster_mask*.nii.gz'])
resolution='3mm';

resultDir=maskDir;
delete ([resultDir, 'clusterReport.xls'])

% read in the MNI stand mask
standardMask=[atlasDir, 'MNI152_T1_', resolution, '_brain_mask.nii.gz'];
[OutdataStand,VoxDimStand,HeaderStand]=rest_readfile(standardMask);
dataStand1D=reshape(OutdataStand,[],1);
standIndex = find(dataStand1D);


% read in the cluster mask
t=1;
for i=1:length(clustList)
    
    effect=clustList(i).name
    effect=cellstr(effect(1:end-7));
    str1='A';
    linenumber=sprintf('%s%d',str1,t);
    xlwrite([resultDir, 'clusterReport.xls'],effect, 'sheet1', linenumber);
    
    maskFile=[maskDir, char(effect), '.nii.gz'];
        
    % read in the mask and reshape to 1D
    [OutdataMask,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
    [nDim1Mask nDim2Mask nDim3Mask]=size(OutdataMask);
    maskImg1D=reshape(OutdataMask, [], 1);
    maskImg1D=maskImg1D(standIndex, 1);
    numClust=length(unique(maskImg1D(find(maskImg1D~=0))))
    
    t=t+1;
    % read in the atlas
    atlasList={'HOC', 'HOSC', 'networks', 'brodmann', 'cerebellum'};
    %atlasList={'HOC', 'HOSC'}
    for j=1:length(atlasList)
        atlas=char(atlasList{j})
        
        if strcmp(atlas, 'HOC')
            title2={'clusterSize', 'prctInClust', 'HOCIndx', 'atlasROIsize', 'prctInAtlas', 'HOCRegion', 'side'};
            linenumber=sprintf('%s%d',str1,t);
            xlwrite([resultDir, 'clusterReport.xls'],title2, 'sheet1', linenumber);
            atlasFile=[atlasDir, atlas, '_', resolution, '.nii.gz'];
        elseif strcmp(atlas, 'HOSC')
            title2={'clusterSize', 'prctInClust', 'HOSCIndx', 'atlasROIsize', 'prctInAtlas', 'HOSCRegion', 'side'};
            linenumber=sprintf('%s%d',str1,t);
            xlwrite([resultDir, 'clusterReport.xls'],title2, 'sheet1', linenumber);
            atlasFile=[atlasDir, atlas, '_', resolution, '.nii.gz'];
        elseif strcmp(atlas, 'networks')
            title2= {'clusterSize', 'prctInClust', 'networkIndx', 'atlasROIsize', 'prctInAtlas', 'networks', 'side(N/A)'};
            linenumber=sprintf('%s%d',str1,t);
            xlwrite([resultDir, 'clusterReport.xls'],title2, 'sheet1', linenumber);
            atlasFile=[atlasDir, atlas, '_', resolution, '.nii.gz'];
        elseif strcmp(atlas, 'brodmann')
            title2={'clusterSize', 'prctInClust', 'BAIndx', 'atlasROIsize', 'prctInAtlas', 'BA', 'side(N/A)' };
            linenumber=sprintf('%s%d',str1,t);
            xlwrite([resultDir, 'clusterReport.xls'],title2, 'sheet1', linenumber);
            atlasFile=[atlasDir, atlas, '_', resolution, '.nii.gz'];
        elseif strcmp(atlas, 'cerebellum')
            title2={'clusterSize', 'prctInClust', 'CRBLIndx', 'atlasROIsize', 'prctInAtlas', 'CRBLRegion', 'side' };
            linenumber=sprintf('%s%d',str1,t);
            xlwrite([resultDir, 'clusterReport.xls'],title2, 'sheet1', linenumber);
            atlasFile=[atlasDir, atlas, '_', resolution, '.nii.gz'];
        end
        
        
        [Outdata,VoxDim,Header]=rest_readfile(atlasFile);
        [nDim nDim2 nDim3]=size(Outdata);
        atlas1D=reshape(Outdata, [], 1);
        atlas1D=atlas1D(standIndex, 1);
        ROIindx=unique(atlas1D);
        ROIindx=ROIindx(find(ROIindx~=0));
        ROIsize=histc(atlas1D, ROIindx);
        
        % read in the atlas label
        [number,txt,raw]= xlsread([atlasDir, 'atlasLabels.xlsx'], atlas);
        
        t=t+1;
        for k=1:numClust
            region={};
            side={};
            atlasROIsize=[];
            prctInAtlas=[];
            prctInClust=[];
            indx=[];
            clust=maskImg1D;
            clust(find(clust~=k))=0;
            clust=logical(clust);
            clustSize=length(find(clust));
            
            overlap=clust.*atlas1D;
            indx=unique(overlap);
            indx=indx(find(indx~=0));
            count=histc(overlap, indx);
            prctInClust=count/clustSize*100;
            for m=1:length(indx)
                prctInAtlas(m,1)=count(m)/ROIsize(find(ROIindx==indx(m)))*100;
                atlasROIsize(m,1)=ROIsize(find(ROIindx==indx(m)));
                region{m,1}=txt(find(number==indx(m))+1, 2); % number starts from the second row
                side{m, 1}=txt(find(number==indx(m))+1, 3);
            end
            
            if ~isempty(region)
                clustSize1=repmat(clustSize, length(indx),1);
                
                numericalInfo=[clustSize1, prctInClust, indx, atlasROIsize, prctInAtlas];
                
                linenumber1=sprintf('%s%d',str1,t);
                xlwrite([resultDir, 'clusterReport.xls'],numericalInfo, 'sheet1', linenumber1);
                
                
                str2='f';
                linenumber2=sprintf('%s%d',str2,t);
                xlwrite([resultDir, 'clusterReport.xls'],region, 'sheet1', linenumber2);
                
                str3='g';
                linenumber3=sprintf('%s%d',str3,t);
                xlwrite([resultDir, 'clusterReport.xls'],side, 'sheet1', linenumber3);
            end
            
            t=t+length(indx);
        end
    end
end









