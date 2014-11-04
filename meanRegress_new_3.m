clear
clc

preprocessDate='2_22_14';
project='Colibazzi';
covType='noGSR' % covType can be noGSR or compCor
subID=load('/home/data/Projects/Zhen/Colibazzi/data/patients_51sub.txt');
subType='51patients'; % 98sub, 40patients, 51patients

%measureList={'DegreeCentrality', 'SCACaudateL', 'SCACaudateR'};
%measureList={'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7', 'VMHC'}
measureList={'SCATHAL1', 'SCATHAL2', 'SCATHAL3', 'SCATHAL4', 'SCATHAL5', 'SCATHAL6', 'SCATHAL7'}
numMeasure=length(measureList)

BrainMaskFile=['/home/data/Projects/Zhen/', project, '/masks/meanStandFunMask_98sub_90prct.nii'];

for j=1:numMeasure
    measure=char(measureList{j})
    
    
    mkdir (['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', measure])
    dataOutDir=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_new/', measure, '/'];
    %Test if all the subjects exist
    
    FileNameSet=[];
    
    for i=1:length(subID)
        sub=num2str(subID(i));
        %sub=SubID(i, 1:9);
        disp(['Working on ', sub])
        
        %FileName = sprintf('/home/data/Projects/Zhen/%s/results/CPAC_zy%s_reorganized/%s/%s/%s_%s.nii.gz', project, preprocessDate, covType, measure,measure,sub);
        FileName = sprintf('/home/data/Projects/Zhen/%s/results/CPAC_zy%s_reorganized/%s/%s/%s_%s_MNI_fwhm8.nii', project, preprocessDate, covType, measure,measure,sub);
        
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
    
    OutputName=[dataOutDir, measure];
    save([OutputName,'_MeanSTD_', subType, '.mat'],'Mean_AllSub','Std_AllSub');
    
    
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
    outName=[dataOutDir, measure, '_AllVolume_meanRegress_', subType, '.nii'];
    rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)
    
end
