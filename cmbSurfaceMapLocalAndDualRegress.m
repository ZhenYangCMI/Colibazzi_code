
% This script will combine individual surface map for into one panel for both full and separate models

clear
clc
close all
%%%Get the Surface maps
preprocessDate='2_22_14'

map='easythresh'; % easythresh unthresh

approachList={'SCAGroup1', 'SCAGroup2', 'SCAGroup3'}; % localMeasure or gRAICAR
%approachList={'localMeasure'}
numRow=length(approachList);
img=[];
t=0;
BackGroundColor = uint8([255*ones(1,1,3)]);

OutputUpDir = ['/home/data/Projects/Colibazzi/figs/'];
for i=1:numRow
    
    row=char(approachList{i})
    
    if strcmp(row, 'localMeasure')
        measureList={'ReHo', 'DegreeCentrality','fALFF', 'VMHC', 'CWAS'};
    elseif strcmp(row, 'gRAICAR1')
        measureList={'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4'};
    elseif strcmp(row, 'gRAICAR2')
        measureList={'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9'};
    elseif strcmp(row, 'SCAGroup1')
        measureList={'SCA1', 'SCA2', 'SCA3', 'SCA4'};
    elseif strcmp(row, 'SCAGroup2')
        measureList={'SCA5', 'SCA6', 'SCA7', 'SCA8'};
    elseif strcmp(row, 'SCAGroup3')
        measureList={'SCA9', 'SCA10', 'SCA11', 'SCA12'};
    end
    numMeasure=length(measureList)
    
    numCol=length(measureList);
    
    for j=1:numCol
        col=char(measureList{j})
        t=t+1
        if strcmp(map, 'unthresh')
            if strcmp(col, 'CWAS')
                img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/%s/zstats_%s_SurfaceMap.jpg', row, col)};
            else
                img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/unthresh/%s_%s_Z_SurfaceMap.jpg', row, col)};
            end
        else
            if strcmp(col, 'CWAS')
                img{t,1} = {sprintf('/home/data/Projects/Colibazzi/figs/thresh_%s_Group_text.ni_SurfaceMap.jpg', col)};
            else
                img{t,1} = {sprintf('/home/data/Projects/Colibazzi/figs/thresh_%s_T1_Z_cmb_SurfaceMap.jpg', col)};
            end
        end
    end
end


for k=1: numRow*numCol
    fileRead=char(img{k})
    imdata(:, :, :, k)=imread(fileRead);
end

% define the size of the row, the column, and the whole picture
UnitRow = size(imdata,1); % this num should be corresponding to the size(imdata, 1)

UnitColumn = size(imdata,2); % this num should be corresponding to the size(imdata, 2)

imdata_All = repmat(BackGroundColor,[UnitRow*numRow,UnitColumn*numCol,1]);


k=0
for m=1:numRow
    for n=1:numCol
        k=k+1
        imdata_All (1+(m-1)*UnitRow:m*UnitRow,1+(n-1)*UnitColumn:n*UnitColumn,:) = imdata(:, :, :, k);
    end
end

figure
image(imdata_All)
axis off          % Remove axis ticks and numbers
axis image        % Set aspect ratio to obtain square pixels
OutJPGName=[OutputUpDir, 'SCA', map, '.jpg'];
eval(['print -r300 -djpeg -noui ''',OutJPGName,''';']);





