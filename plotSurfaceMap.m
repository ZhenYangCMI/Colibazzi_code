clear
clc
close all

addpath /home/data/Projects/Zhen/microstate/DPARSF_preprocessed/code/REST_V1.8_121225
addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.2_130309
addpath /home/data/Projects/Zhen/BIRD/BIRD_code/dynamicAnalysis/BrainNetViewer

imgInputDir = ['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/groupAnalysis98sub/SCATHAL_MDMRnet7peak/easythresh_z1.64p0.05'];
cd (imgInputDir)

%NMin=-2.33; PMin = 2.33; %for univariate approaches
%NMin=-1.64; PMin = 1.64; % for CWAS
NMin=-0.01; PMin = 0.01;
NMax=-4; PMax=4; % set 4 for thresh map

Prefix='';
DirImg = dir([imgInputDir,filesep,Prefix,'*cmb.nii']);

% AFNI colorMap
%ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;];
%ColorMap=[1,1,0;1,0.4118,0;1,0,0;0,0,1;0,0.6,1;0,1,1;]; % nice six colors
% ColorMap=[1,1,0;1,0,0;0,0,1;0,1,1;]
% ColorMap=flipdim(ColorMap,1);
% colormap used to plot the overlap
% the colormap below are for plotting the combined or overlapped maps
% [64, 196, 255] and [255, 255, 0] are fake, always using odd number of
% colors, the middle, the first, or the last are colors possibly not used.
% ColorMap=[0, 128,0; 106, 196, 255; 51, 83, 255; 106, 90, 205; 64, 196, 255; 230, 123, 184; 228, 108, 10;  255, 255, 0; 205, 0, 0]
% ColorMap=ColorMap/255;

% the colorMap used in the pib, for threshed map
ColorMap=[1,1,0;1,0.9,0;1,0.8,0;1,0.7,0;1,0.6,0;1,0.5,0;0,0.5,1;0,0.6,1;0,0.7,1;0,0.8,1;0,0.9,1;0,1,1;];
ColorMap=flipdim(ColorMap,1);
cmap1 = colorRamp(ColorMap(1:6,:), 32);
cmap2= colorRamp(ColorMap(7:end,:), 32);
ColorMap=vertcat(cmap1,cmap2);


surfaceMapOutputDir = imgInputDir;
numImg=length(DirImg)


PicturePrefix='';

ClusterSize=0;

SurfaceMapSuffix='_SurfaceMap.jpg';


ConnectivityCriterion=18;

[BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));

SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,'SurfTemplate',filesep,'BrainMesh_ICBM152_smoothed.nv'];

viewtype='MediumView';



for i=1:numImg
    InputName = [imgInputDir,filesep,DirImg(i).name];
    
    OutputName = [surfaceMapOutputDir,filesep, DirImg(i).name(1:end-4),SurfaceMapSuffix];
    
    H_BrainNet = rest_CallBrainNetViewer(InputName,NMin,PMin,ClusterSize,ConnectivityCriterion,SurfFileName,viewtype,ColorMap,NMax,PMax);
    
    eval(['print -r300 -djpeg -noui ''',OutputName,''';']);
end

