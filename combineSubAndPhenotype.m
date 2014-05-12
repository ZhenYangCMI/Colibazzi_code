close all
clear all
clc

javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');


dataDir='/home/data/Projects/Colibazzi/data/';

% if has letters, read in as string; if only numbers, read in as numerical values
%b1=textread([dataDir, 'combinedSubList.txt'],'%s');
b1=textread([dataDir, 'patients_51sub.txt'],'%d');
[number,txt,raw]= xlsread([dataDir, 'outcome.xlsx']);

[r,c]=size(number);
[rt,xt]=size(raw);
[r1,c1]=size(b1);

%headlines=rt-r;
headlines=1;

if exist([dataDir, 'tmp.xls'], 'file')
    delete ([dataDir, 'tmp.xls'])
end

for i=1:headlines
    str1='A';
    linenumber=sprintf('%s%d',str1,i);
    xlwrite([dataDir, 'tmp.xls'],raw(i,:), 'sheet1',linenumber);
end

bcounter=headlines+1;
for i=headlines+1:rt
    % for numeric subID
    for j=1:r1
        if number(i-1,1)==b1(j,1)
                        % for text subID
            %for j=1:r1
            %if strcmp(char(txt(i,2)), char(b1(j,1)))
            
            str1='A';
            linenumber=sprintf('%s%d',str1,bcounter);
            xlwrite([dataDir, 'tmp.xls'], raw(i,:), 'sheet1',linenumber);
            bcounter=bcounter+1;
        end
    end
end



