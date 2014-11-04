clear all
clc
close all

%a=load('/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/ROIbasedDimAnalysis/ROImeanAllMeasures_totol16clusters_98sub.txt');

% figure(1)
% for i=1:8
%     subplot(2,4,i)
%     b=zeros(51,2);
%     b(:,1)=a(1:51,i+8);
%     b(1:47,2)=a(52:end, i+8);
%     b(48:51,2)=nan;
%     boxplot(b)
% end
% 
% saveas(figure(1), ['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/plotROImean/col_9to16.png'])

measureList={'DegreeCentrality', 'VMHC','SCATHAL1', 'SCATHAL2', 'SCATHAL6', 'Group_text_ROI1', 'Group_text_ROI2', 'Group_text_ROI3','Group_text_ROI4', 'Group_text_ROI5', 'Group_text_ROI6' }
allP=[];
allH=[];
for i=1:length(measureList)
    measure=measureList{i}
x=load(['/home/data/Projects/Zhen/Colibazzi/results/CPAC_zy2_22_14_reorganized/meanRegress/', measure, '/', measure, '_MeanSTD_98sub.mat'])
mean_AllSub=x.Mean_AllSub;
std_AllSub=x.Std_AllSub;
[h p]=ttest2(std_AllSub(1:51,1), std_AllSub(52:end, 1));
allP(i,1)=p;
allH(i,1)=h;
% figure(1)
% y=zeros(51,2);
% y(:,1)=mean_AllSub(1:51,1);
% y(1:47,2)=mean_AllSub(52:end, 1);
% y(48:51,2)=nan;
% z=zeros(51,2);
% z(:,1)=std_AllSub(1:51,1)
% z(1:47,2)=std_AllSub(52:end, 1)
% z(48:51,2)=nan;
% subplot(1,2,1)
% boxplot(y)
% subplot(1,2,2)
% boxplot(z)
% saveas(figure(1), ['/home/data/Projects/Zhen/Colibazzi/figs/finalAnalysis/plotROImean/global_', measure, '.png'])
close all
end
