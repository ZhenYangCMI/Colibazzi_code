close all
clear all
clc

javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');

[number,txt,raw]= xlsread(['/home/data/Projects/Zhen/Colibazzi/data/plotROImeanByGroup.xlsx']);

ROI=number(1:98, 5:end);
x=1:98;
%markList={'o','+', '.', '*', 'x', 's', 'd', '^', 'V', '>', '<', 'p', 'h'}
markList={'o'};
figure(1)
for i=1:16
    %mark=char(markList(i));
    s=40;
    subplot(4,4,i)
  %scatter(x(1:8), ROI(1:8,i), 40, mark, 'MarkerEdgeColor','r', 'MarkerFaceColor','r')
  scatter(x(1:8), ROI(1:8,i), 20, 'r')
   hold on
%scatter(x(9:51), ROI(9:51, i),40,  mark, 'MarkerEdgeColor','b', 'MarkerFaceColor','b')
scatter(x(9:51), ROI(9:51, i),20, 'b')
hold on
%scatter(x(52:end), ROI(52:end, i),40, mark, 'MarkerEdgeColor','g', 'MarkerFaceColor','g')
scatter(x(52:end), ROI(52:end, i),20, 'g') 
end

save

