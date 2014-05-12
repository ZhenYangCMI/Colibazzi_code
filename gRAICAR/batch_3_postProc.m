% gRAICAR_batch_postNMI

% Batch script to conduct post-processings, including:
%		check NMI computations
%		align ICs
%		weighted averaging/write aligned components into nii files
%		examine the significance of the subject loads (centrality)
%	
% 1. Please make sure the following settings are correct
% 2. Please run this batch script after the NMI computation
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
keep_FSM=0;

load ([rootDir, outDir, '/', taskName, '_configFile.mat'])

% check if all NMI computations are done
fprintf ('\n-------------------------\n');
fprintf (' checking NMI computaions\n');
fprintf ('-------------------------\n');
total = size (obj.result.cmptTab, 1);

failList=[];
for ptr=1:obj.setup.step:total
	fn = sprintf ('%s/computeFile/NMI_grp_result_%d.mat', obj.setup.outDir, ptr);
	if ~exist(fn,'file')
		failList = [failList, ptr];
	end
end
if ~isempty (failList)
	fprintf ('!!!!!!!!!!!!!!!!!!!!!!!!\n');
	fprintf ('error: NMI compuation is not completed\n')
	for i=1:length(failList)
		fprintf ('file NMI_grp_result_%d.mat not found\n', failList(i));
	end
	fprintf ('!!!!!!!!!!!!!!!!!!!!!!!!\n');
	error ('NMI compuation is not completed\n');
end

% align ICs
fprintf ('\n-------------------------\n');
fprintf (' aligning ICs \n');
fprintf ('-------------------------\n');

obj = gRAICAR_align_fullMICM (obj.setup.outPrefix, keep_FSM);
obj.result = rmfield (obj.result, 'MICM'); % remove the MICM to save disk space
fn = sprintf ('%s_result.mat', obj.setup.outPrefix);
save (fn, 'obj');

% weighted averaging
fprintf ('\n-------------------------\n');
fprintf (' weighted averaging ICs \n');
fprintf ('-------------------------\n');
tic,
[map4D, allMap] = gRAICAR_weight_averageMap_fast (obj, 1:size (obj.result.foundComp));
fn = sprintf ('%s_aveMap.mat', obj.setup.outPrefix);
save (fn, 'map4D');

% write aligned components into nii file
fprintf ('\n-------------------------\n');
fprintf (' writing ACs \n');
fprintf ('-------------------------\n');

nii.hdr = obj.setup.niihdr;
sz = size (map4D);
cmd = sprintf ('!mkdir -p %s/compMaps/', obj.setup.outDir);
eval (cmd);
for i=1:sz(4)
	nii.img = map4D(:,:,:,i);
	nii.hdr.dime.dim = [3 sz(1) sz(2) sz(3) 1 1 1 1];
	nii.hdr.glmax = max (map4D(:,:,:,i));
	nii.hdr.glmin = max (map4D(:,:,:,i));
	fn = sprintf('%s/compMaps/comp%03d.nii', obj.setup.outDir, i);
	save_nii (nii, fn);
	fprintf ('compMap%d written out\n', i);
end
toc,
% write component movie into nii file
% allMap = gRAICAR_synthesizeCompMap (obj, 1:size (obj.result.foundComp,1));
tic,
% allMap = gRAICAR_movie_fast (obj, 1:size (obj.result.foundComp,1));
sz=size(allMap);
for i=1:sz(4)
	nii.img = squeeze(allMap(:,:,:,i,:));
	nii.hdr.dime.dim = [4 sz(1) sz(2) sz(3) sz(5) 1 1 1];
	nii.hdr.glmax = max (squeeze(allMap(:,:,:,i,:)));
	nii.hdr.glmin = min (squeeze(allMap(:,:,:,i,:)));
	fn = sprintf('%s/compMaps/movie_comp%03d.nii', obj.setup.outDir, i);
	save_nii (nii, fn); 
    fprintf ('movie_compMap%d written out\n', i);
end
toc,

% examine subject loads
fprintf ('\n-------------------------\n');
fprintf (' examining subject loads \n');
fprintf ('-------------------------\n');

fn = sprintf ('%s_null_interSb_reproMap.mat', obj.setup.outPrefix);
if exist (fn, 'file')    % save some time if the null distribution is already simulated
    load (fn)
    obj = gRAICAR_examRepro (obj, 1000, null_interSb_reproMap);
else
    [obj,null_interSb_reproMap] = gRAICAR_examRepro (obj, 1000);
    save (fn, 'null_interSb_reproMap');
end

fn = sprintf ('%s_result.mat', obj.setup.outPrefix);
save (fn, 'obj');



fprintf ('\n-------------------------\n');
fprintf (' gRAICAR done \n');
fprintf ('-------------------------\n');
