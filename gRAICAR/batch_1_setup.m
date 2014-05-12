
% batch_1_setup.m

% Batch script for setup gRAICAR analysis
% 1. Please make sure the following settings are correct;
% 2. Please run this script to setup gRAICAR analysis
%

% The gRAICAR package is written by
% Zhi Yang Ph.D
% Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% 
% Reference: Zhi Yang, Xi-Nian Zuo, Peipei Wang, Zhihao Li, Stephen LaConte, Peter Bandettini, Xiaoping Hu
% Generalized RAICAR: Discover homogeneous subject (sub)groups by reproducibility of their intrinsic connectivity networks. NeuroImage. In press.

%%%%%%%%% requires user changes %%%%%%%%%%%%%%%
rootDir = '/home2/data/Projects/workingMemory/data/gRAICAR_analysis/wave1';

% outdir: the name of directory for the output of gRAICAR (!!!!relative to the rootDir, instead of full path!!!!)
outDir = '/gRAICAR_PR_autoDim_ANTs';

% taskName: name of the analysis task, will be used as the prefix of the configFile that stores information about the analysis.
taskName = 'wave1';

% pathSbList: path to the subject list file (!!!!relative to the rootDir, instead of full path!!!!)
% the subject list file contains a list (column) of subject names. The data for each subject are under the directory with the listed subject name
pathSbList = '/scripts/subjectList_Num_68sub.txt'

% icaPrefix: name of the Melodic ICA file
icaPrefix = 'melodic_IC_mni152_3mm_ANTs.nii.gz';

% icaDir: path of the ICA directory (!!!!relative to the subject directory, instead of full path!!!!)
icaDir='/FunImg/ICA/melodic_autoDim';

% maskPath: path of the mask file (!!!!relative to the rootDir, instead of full path!!!!)
maskPath = '/mask/melodic_IC_mni152_3mm_ANTs_mask_wave1_68sub_90prct.nii.gz'


%%%%%%%%%% end of user input %%%%%%%%%%%%%%%%%%%

fprintf ('\n-------------------------\n');
fprintf (' setting up gRAICAR \n');
fprintf ('-------------------------\n');

% load the subject list
fid = fopen ([rootDir, pathSbList]);
tmp = textscan (fid,'%s');
len = length (tmp{1});
fclose(fid);

sbList = cell(len,1);
fid = fopen ([rootDir, pathSbList], 'r');
for i=1:len
    sbList{i} = fgetl (fid);
end
fclose(fid);

% setup analysis
obj = gRAICAR_setup_singleMelodic (rootDir, sbList, outDir, taskName, icaDir, icaPrefix, maskPath);

% bin the ICA maps
fprintf ('\n-------------------------\n');
fprintf (' bining IC maps \n');
fprintf ('-------------------------\n');

obj = gRAICAR_prepareData (obj,1:length(sbList));

% prepare for NMI computation
mkdir ([rootDir, outDir])
delete([rootDir, outDir, '/progress.log'])
dlmwrite ([rootDir, outDir, '/progress.log'], 1, 'precision', '%d');

fprintf ('\n-------------------------\n');
fprintf (' set up finished, please run batch_2 \n');
fprintf ('-------------------------\n');

 % compute NMI: parallel for biowulf
 step = obj.setup.step;
 total = size (obj.result.cmptTab, 1);
 numTasks = ceil(total/step);

 !rm -rf mlb_NMI.swarm;
 for i=1:numTasks
     start = step*(i-1)+1;
     ending = min(total, step*i);
     cmd = sprintf ('cd %s/0scripts/; matlab -nodesktop -minimize -nosplash -r "gRAICAR_distrCompNMI_biow(%d,%d);"', rootDir,start, ending);
     fid = fopen ('mlb_NMI.swarm','a');
     fprintf (fid, '%s\n',cmd);
     fclose (fid);
 end




% obj = gRAICAR_align_fullMICM (obj.setup.outPrefix);
% fn = sprintf ('%sresult_30_40.mat', obj.setup.outDir);
% save (fn, 'obj');

% % weighted average: parallel for biowulf
% !rm -rf mlb_average.swarm;
% for i=1:30 % components for average
%     cmd = sprintf ('cd /data/yangz8/workSpace/nki_lifespan/0scripts/; matlab -nodesktop -minimize -nosplash -r "gRAICAR_weight_averageMap_biow(%d);"', i)
%     fid = fopen ('mlb_average.swarm','a');
%     fprintf (fid, '%s\n',cmd);
%     fclose (fid);
% end
% [obj, null_interSb_reproMap] = gRAICAR_examRepro (obj, 5000);
% fn = sprintf ('%sresult_all_autoDim.mat', obj.setup.outDir);
% save (fn, 'obj');
% fn = sprintf ('%snull_interSb_reproMap.mat', obj.setup.outDir);
% save (fn, 'null_interSb_reproMap');


