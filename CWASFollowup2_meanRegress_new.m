clear
clc

preprocessDate='2_22_14';
project='Colibazzi';
covType='noGSR' % covType can be noGSR or compCor

%effectList={'Group_text', 'SIPSTOTA_demean', 'outcome_SOCIAL'};
effectList={'Group_text'}
for k=1:length(effectList)
    effect=char(effectList(k));
    
    if strcmp(effect, 'Group_text')
        %subID=load('/home/data/Projects/Colibazzi/data/subClean_step2_98sub.txt');
    subID=load('/home/data/Projects/Zhen/Colibazzi/data/patients_51sub.txt'); % used for ROI based prediction analysis
        %ROIList={'ROI1', 'ROI2', 'ROI3', 'ROI4', 'ROI5', 'ROI6' };
        ROIList={'ROI4', 'ROI5', 'ROI6'};
        BrainMaskFile=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_98sub_3mm_noGSR_100prct.nii.gz'];
    elseif strcmp(effect, 'SIPSTOTA_demean')
        subID=load('/home/data/Projects/Zhen/Colibazzi/data/patients_51sub.txt');
        ROIList={'ROI1', 'ROI2', 'ROI3', 'ROI4', 'ROI5', 'ROI6', 'ROI7' };
        %ROIList={'ROI'};
        BrainMaskFile=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_51sub_3mm_noGSR_100prct.nii.gz'];
    else
        subID=load('/home/data/Projects/Zhen/Colibazzi/data/patients_40sub.txt')
        ROIList={'ROI1', 'ROI2', 'ROI3', 'ROI4', 'ROI5', 'ROI6', 'ROI7' };
        %ROIList={'ROI1', 'ROI2'};
        BrainMaskFile=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_40sub_3mm_noGSR_100prct.nii.gz'];
    end
    
    numROI=length(ROIList)
    
    for j=1:numROI
        ROI=char(ROIList{j})
        
        mkdir (['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', effect, '_', ROI])
        dataOutDir=['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', effect, '_', ROI, '/'];
        %Test if all the subjects exist
        
        FileNameSet=[];
        
        for i=1:length(subID)
            sub=num2str(subID(i));
            disp(['Working on ', sub])
            
            if strcmp(effect, 'Group_text')
                FileName = ['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/CWAS_98sub/mdmr3mmFWHM8followUp/', ROI, 'FC_ROI_', effect, '_', sub, '.nii'];
            elseif strcmp(effect, 'SIPSTOTA_demean')
                FileName = ['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/CWAS_51patients/mdmr3mmFWHM8followUp/', ROI, 'FC_ROI_', effect, '_', sub, '.nii'];
            else
                FileName = ['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/CWAS_40patients/mdmr3mmFWHM8followUp/', ROI, 'FC_ROI_', effect, '_', sub, '.nii'];
            end
            
            if ~exist(FileName,'file')
                
                disp(sub)
                
            else
                
                FileNameSet{i,1}=FileName;
                
            end
            
        end
        
        FileNameSet;
        
        [AllVolume,vsize,theImgFileList, Header,nVolumn] =rest_to4d(FileNameSet);
        
        
        
        [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
        
        
        
        
        
        %Set Mask
        
        if ~isempty(BrainMaskFile)
            
            [MaskData,MaskVox,MaskHead]=rest_readfile(BrainMaskFile);
            
        else
            
            MaskData=ones(nDim1,nDim2,nDim3);
            
        end
        
        
        % Convert into 2D. NOTE: here the first dimension is voxels,
        
        % and the second dimension is subjects. This is different from
        
        % the way used in y_bandpass.
        
        %AllVolume=reshape(AllVolume,[],nDimTimePoints)';
        
        AllVolume=reshape(AllVolume,[],nDimTimePoints);
        
        
        MaskDataOneDim=reshape(MaskData,[],1);
        
        MaskIndex = find(MaskDataOneDim);
        
        nVoxels = length(MaskIndex);
        
        %AllVolume=AllVolume(:,MaskIndex);
        
        AllVolume=AllVolume(MaskIndex,:);
        
        
        
        AllVolumeBAK = AllVolume;
        
        
        % compute the mean and st acorss all voxels for each sub
        Mean_AllSub = mean(AllVolume)';
        
        Std_AllSub = std(AllVolume)';
        
        %Prctile_25_75 = prctile(AllVolume,[25 50 75]);
        
        
        %Median_AllSub = Prctile_25_75(2,:)';
        
        %IQR_AllSub = (Prctile_25_75(3,:) - Prctile_25_75(1,:))';
        
        
        Mat = [];
        
        Mat.Mean_AllSub = Mean_AllSub;
        
        Mat.Std_AllSub = Std_AllSub;
        
        OutputName=[dataOutDir, effect, '_', ROI];
        save([OutputName,'_MeanSTD.mat'],'Mean_AllSub','Std_AllSub');
        
        
        Cov = Mat.Mean_AllSub;
        
        
        %Mean centering
        
        Cov = (Cov - mean(Cov))/std(Cov);
        
        
        AllVolumeMean = mean(AllVolume,2);
        
        AllVolume = (AllVolume-repmat(AllVolumeMean,1,size(AllVolume,2)));
        
        
        %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
        
        AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
        
        %AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));
        
        
        AllVolumeSign = sign(AllVolume);
        
        
        % write the data as a 4D volume
        AllVolumeBrain = (zeros(nDim1*nDim2*nDim3, nDimTimePoints));
        
        AllVolumeBrain(MaskIndex,:) = AllVolume;
        
        
        
        AllVolumeBrain=reshape(AllVolumeBrain,[nDim1, nDim2, nDim3, nDimTimePoints]);
        
        Header_Out = Header;
        
        Header_Out.pinfo = [1;0;0];
        
        Header_Out.dt    =[16,0];
        
        %write 4D file as a nift file
        outName=[dataOutDir, effect,'_', ROI, '_AllVolume_meanRegress.nii'];
        rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)
        
    end
end
