% This script will compute the ROI based SCA

clear
clc

% rmpath /home/milham/matlab/REST_V1.7
% rmpath /home/milham/matlab/REST_V1.7/Template
% rmpath /home/milham/matlab/REST_V1.7/man
% rmpath /home/milham/matlab/REST_V1.7/mask
% rmpath /home/milham/matlab/REST_V1.7/rest_spm5_files
%
% restoredefaultpath
%
% addpath(genpath('/home/data/Projects/Zhen/commonCode/spm8'))
% addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615
% addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615/Subfunctions/
% addpath /home/data/Projects/Zhen/commonCode/REST_V1.8_130615

project='Colibazzi'
preprocessingDate='2_22_14';
dataDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/FunImg/'];

subList=load(['/home/data/Projects/Zhen/', project, '/data/subClean_step2_98sub.txt']);
numSub=length(subList)

%BrainMaskFile=['/home/data/Projects/Zhen/Colibazzi/masks/CWAS/stdMask_', num2str(numSub), 'sub_3mm_noGSR_100prct.nii.gz'];
BrainMaskFile=['/home/data/Projects/Zhen/Colibazzi/masks/meanStandFunMask_98sub_90prct_3mm.nii'];

MaskData=BrainMaskFile;
%1. compute the whole brain iFC
outputDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/SCATHALCommon/'];
for i=1:numSub
    sub=num2str(subList(i))

    %sub=subList(i, 1:9);
    AllVolume=[dataDir, 'normFunImg_', sub, '_3mm_fwhm8.nii.gz'];

    ROIDef={['/home/data/Projects/Zhen/Colibazzi/masks/SCAMaskFinal/MDMRiFC_DC_THAL_overlapmask.nii']}

    OutputName=[outputDir, 'FC_', sub];
    IsMultipleLabel=1;
    [FCBrain, Header] = y_SCA(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel);
end

% 2. mean regression
effect='SCATHALCommon';
dataOutDir=['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/meanRegress/SCATHALCommon/'];

FileNameSet=[];

for i=1:length(subList)
    sub=num2str(subList(i));
    disp(['Working on ', sub])
    
    FileName = ['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/noGSR/SCATHALCommon/FC_', sub, '.nii'];
    
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

OutputName=[dataOutDir, effect];
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
outName=[dataOutDir, effect, '_AllVolume_meanRegress.nii'];
rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)


