function y_tal2icbm_spm_Image(SourceFile, RefFile, OutFile)
% FORMAT y_tal2icbm_spm_Image(SourceFile, RefFile, OutFile)
% Write an image file from Talairach space into MNI space
% Input:
%   SourceFile     - The source image in Talairach space
%   RefFile        - The reference image in MNI space. The output file will have the same voxel size and dimension as this reference image.
%   OutFile        - The output name for the output file, which is in MNI space.
% Output:
%   *.nii          - Data put into MNI space via Jack Lancaster's tal2icbm_spm.m
%___________________________________________________________________________
% Written by YAN Chao-Gan 120911.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

[RefData RefHead]=rest_ReadNiftiImage(RefFile);

[SourceData SourceHead]=rest_ReadNiftiImage(SourceFile);

[nDim1,nDim2,nDim3]=size(RefData);
[D1,D2,D3] = ndgrid(1:nDim1,1:nDim2,1:nDim3);
D=zeros(nDim1,nDim2,nDim3,4);
D(:,:,:,1)=D1;
D(:,:,:,2)=D2;
D(:,:,:,3)=D3;
D(:,:,:,4)=ones(nDim1,nDim2,nDim3);

D=reshape(D,[],4);
MNIxyz = D*RefHead.mat';
Talxyz = rest_icbm_spm2tal(MNIxyz(:,1:3));
D(:,1:3)=Talxyz;
Talijk = D*inv(SourceHead.mat)';

Talijk = round(Talijk(:,1:3));

OutsideMask = zeros(size(Talijk,1),1);
Temp = Talijk(:,1)>size(SourceData,1);
Talijk(find(Temp),1)=size(SourceData,1);
OutsideMask = OutsideMask + Temp;
Temp = Talijk(:,1)<1;
Talijk(find(Temp),1)=1;
OutsideMask = OutsideMask + Temp;

Temp = Talijk(:,2)>size(SourceData,2);
Talijk(find(Temp),2)=size(SourceData,2);
OutsideMask = OutsideMask + Temp;
Temp = Talijk(:,2)<1;
Talijk(find(Temp),2)=1;
OutsideMask = OutsideMask + Temp;

Temp = Talijk(:,3)>size(SourceData,3);
Talijk(find(Temp),3)=size(SourceData,3);
OutsideMask = OutsideMask + Temp;
Temp = Talijk(:,3)<1;
Talijk(find(Temp),3)=1;
OutsideMask = OutsideMask + Temp;

Index = sub2ind(size(SourceData),squeeze(Talijk(:,1)),squeeze(Talijk(:,2)),squeeze(Talijk(:,3)));

Data = SourceData(Index);
Data(find(OutsideMask))=0;
Data = reshape(Data,[nDim1, nDim2, nDim3]);

RefHead.dt=16;

rest_Write4DNIfTI(Data,RefHead,OutFile);

