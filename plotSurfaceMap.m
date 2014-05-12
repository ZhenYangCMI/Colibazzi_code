clear
clc
close all


addpath /home/data/Projects/Colibazzi/code/BrainNetViewer
imgInputDir = ['/home/data/Projects/Colibazzi/figs/correctForApproaches/wholeBrainDimAnalysis'];
cd (imgInputDir)

NMin=-0.001; PMin = 0.001;
NMax=-5; PMax=5; % for CWAS set for 4, for others set for 5 to plot the overlapping

Prefix='';
DirImg = dir([imgInputDir,filesep,Prefix,'*.nii']);

% AFNI colorMap
%ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;];
%ColorMap=[1,1,0;1,0.4118,0;1,0,0;0,0,1;0,0.6,1;0,1,1;]; % nice six colors
% ColorMap=[1,1,0;1,0,0;0,0,1;0,1,1;]
% ColorMap=flipdim(ColorMap,1);
% colormap used to plot the overlap
% ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0; 64, 224, 208; 106, 90, 205; 30, 144, 255; 255, 255, 0; 220, 20, 60];
% 
% ColorMap=[1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0; 64, 224, 208; 106, 90, 205; 30, 144, 255; 255, 255, 0];
% ColorMap=ColorMap/255;

% the colorMap used in the pib
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

