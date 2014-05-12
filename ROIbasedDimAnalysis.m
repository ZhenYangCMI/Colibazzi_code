clear
clc
project='Colibazzi';
ROImean=load(['/home/data/Projects/Colibazzi/data/ROImeanRegression51patients.txt']);
subList=load('/home/data/Projects/Colibazzi/data/patients_51sub.txt');
numSub=length(subList)

%ROIList={'VMHC_neg_ROI1', 'VMHC_neg_ROI2', 'VMHC_neg_ROI3', 'DC_pos_ROI1', 'DR1_pos_ROI1', 'DR2_pos_ROI1', 'DR3_neg_ROI1', 'DR4_pos_ROI1', 'DR9_neg_ROI1', 'SCA12_pos_ROI1', 'SCATHAL1_neg_ROI1', 'SCATHAL2_neg_ROI1', 'SCATHAL5_neg_ROI1', 'SCATHAL6_neg_ROI1', 'SCATHAL7_neg_ROI1', 'CWASROI1_neg_ROI1', 'CWASROI1_pos_ROI1', 'CWASROI2_pos_ROI1'};
ROIList={'VMHC_neg_ROI1'}
% regression analysis
modelist={'modelSymptom', 'modelOutcomeRole', 'modelOutcomeSocial'};
%modelist={'modelOutcomeSocial'}

for k=1:length(modelist)
modelName=char(modelist{k}) 
data=ROImean;
 
	if strcmp(modelName, 'modelSymptom')
	data(16,:)=[];
	ROIdata=data(:,2:19);
	labels={'symptomA', 'symptomB', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'}
	regressionModel=[data(:, 22) data(:, 28) data(:, 37) data(:, 38) data(:, 36) data(:, 35) ones(size(data,1), 1)];

[rho1,pval1] = partialcorr(ROIdata,regressionModel(:,1), regressionModel(:, 3:end-1))
[rho2,pval2] = partialcorr(ROIdata,regressionModel(:,2), regressionModel(:, 3:end-1))

	elseif strcmp(modelName, 'modelOutcomeRole')

	data(find(ROImean(:,20)==0), :)=[];
	ROIdata=data(:,2:19);
    labels={'outcomeROLE', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'}
    regressionModel=[data(:, 20) data(:, 37) data(:, 38) data(:, 36) data(:, 35) ones(size(data,1), 1)];
[rho3,pval3] = partialcorr(ROIdata,regressionModel(:,1), regressionModel(:, 2:end-1))
	
else
	data(find(ROImean(:,21)==0), :)=[];
ROIdata=data(:,2:19);
    labels={'outcomeSOCIAL', 'age_demean', 'meanFD_demean', 'sex', 'handedness', 'constant'}
    regressionModel=[data(:, 21) data(:, 37) data(:, 38) data(:, 36) data(:, 35) ones(size(data,1), 1)];
[rho4,pval4] = partialcorr(ROIdata,regressionModel(:,1), regressionModel(:, 2:end-1))
	end

end

allp=[pval1;pval2;pval3;pval4];
q=0.05;
[pID,pN] = FDR(pval3,q)



