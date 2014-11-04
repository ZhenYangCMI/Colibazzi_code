% This script extract ROI mean values for each measure and concate ROImean across all measures
clear
clc
close all

project='Colibazzi';

%measureList={'DegreeCentrality', 'VMHC','SCATHAL1', 'SCATHAL2', 'SCATHAL6', 'Group_text_ROI1', 'Group_text_ROI2', 'Group_text_ROI3','Group_text_ROI4', 'Group_text_ROI5', 'Group_text_ROI6' };
measureList={ 'Group_text_ROI3'};

%T1:Group effect
T='T1'
numClusters=zeros(length(measureList), 2);
% load subList
subList=load(['/home/data/Projects/Zhen/', project, '/data/subClean_step2_98sub.txt']);
numSub=length(subList)
outputDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/ROIbasedDimAnalysis/'];
figDir='/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/ROImeanAndGlobalVariable/';

for i=1:length(measureList)
    measure=measureList{i}
    close all
    
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
    
    
    file=['/home/data/Projects/', project, '/results/CPAC_zy2_22_14_reorganized/meanRegress/', measure, '/', measure, '_AllVolume_meanRegress_', num2str(numSub), 'sub.nii'];
    
    
    
    [AllVolume,VoxelSize,theImgFileList, Header] =rest_to4d(file);
    
    % reshape the data read in and mask out the regions outside of the brain
    [nDim1,nDim2,nDim3,nSub]=size(AllVolume);
    AllVolume=reshape(AllVolume,[],nSub)';
    AllVolume=AllVolume(:, MaskIndex);
    
    
    figure(i)
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
    vox=AllVolume(:, find(NegROI1D~=0));
    
    if find(NegROI1D~=0)~=0
        ROI1=reshape(vox(1:8, :),[],1);
        ROI2=reshape(vox(9:51, :),[],1);
        ROI3=reshape(vox(52:end, :),[],1);
        
        figure(1)
        
        % split data into 3 groups
        for j=1:3
            if  j==1
                ROI=ROI1;
                color=[255, 0, 0];
                color=color/255;
            elseif j==2
                ROI=ROI2;
                color=[25, 25, 112];
                color=color/255;
            else
                ROI=ROI3;
                color=[95, 158, 160];
                color=color/255;
            end
            [x,binpos]=hist(ROI,30);
            counts = hist(ROI,binpos);
            y=counts/length(ROI); % convert counts to probablity density
            
            % smooth the curve
            yy=[];
            yy(1)=y(1);
            yy(2)=(y(1)+y(2)+y(3))/3;
            yy(length(y))=y(length(y));
            yy(length(y-1))=(y(length(y-1))+y(length(y))+y(length(y+1)))/3;
            for i=3:(length(y)-2)
                yy(i)=(y(i-2)+y(i-1)+y(i)+y(i+1)+y(i+2))/5;
            end
            
            value=1;
            %plot(binpos, y, 'o', color)
            hold on
            plot(binpos, yy, 'MarkerFaceColor', color)
            h1=area(binpos, yy)
            child=get(h1,'Children')
            set(child,'FaceAlpha',value)
            set(h1(1),'FaceColor',color, 'LineWidth', 1.5);
            ylabel(['Probablity Density'])
            xlabel([measure])
            box on
        end
       saveas(figure(1), [figDir, measure, '_ROI_distribution_neg.png']) 
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
    vox=AllVolume(:, find(PosROI1D~=0));
    
    if find(PosROI1D~=0)~=0
        ROI1=reshape(vox(1:8, :),[],1);
        ROI2=reshape(vox(9:51, :),[],1);
        ROI3=reshape(vox(52:end, :),[],1);
        
        figure(2)
        
        % split data into 3 groups
        for j=1:3
            if  j==1
                ROI=ROI1;
                color=[255, 0, 0];
                color=color/255;
            elseif j==2
                ROI=ROI2;
                color=[25, 25, 112];
                color=color/255;
            else
                ROI=ROI3;
                color=[95, 158, 160];
                color=color/255;
            end
            [x,binpos]=hist(ROI,30);
            counts = hist(ROI,binpos);
            y=counts/length(ROI); % convert counts to probablity density
            
            % smooth the curve
            yy=[];
            yy(1)=y(1);
            yy(2)=(y(1)+y(2)+y(3))/3;
            yy(length(y))=y(length(y));
            yy(length(y-1))=(y(length(y-1))+y(length(y))+y(length(y+1)))/3;
            for i=3:(length(y)-2)
                yy(i)=(y(i-2)+y(i-1)+y(i)+y(i+1)+y(i+2))/5;
            end
            
            value=1;
            %plot(binpos, y, 'o', color)
            hold on
            plot(binpos, yy, 'MarkerFaceColor', color)
            h1=area(binpos, yy)
            child=get(h1,'Children')
            set(child,'FaceAlpha',value)
            set(h1(1),'FaceColor',color, 'LineWidth', 1.5);
            ylabel(['Probablity Density'])
            xlabel([measure])
            box on
        end
       saveas(figure(2), [figDir, measure, '_ROI_distribution_pos.png']) 
    end
    
    
end



