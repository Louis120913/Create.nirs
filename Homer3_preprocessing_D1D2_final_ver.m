%% Adjust Homer3_preprocessing Data for different subjects
%% Author: Tai-Jui Chang, 2021.08.26
%% Choose Folder & Load Demo File (Homer3: 'SD', 't', 'd', 's', 'aux')
clear; clc;
[Demo_nirs, file_path] = uigetfile('*.nirs','�п�ܦ��s��Homer3���R���G��m��.nirs�d���ɮ�');
tic
cd (file_path); load (Demo_nirs, '-mat'); load ('adjust_info_D1D2');
xls_path_list = dir ([file_path '*.xlsx']); % dir�i�ݥثe�ؿ����U�Ϊ̫��w���|���W
xls_num = length (xls_path_list);
%% Load Raw Intensity : ��Ƨ�����,�ݩ�̩��h��for�j��
for i = 1:xls_num
    xls_name = xls_path_list (i).name; % �ɮצW�٦C����o�U���ɮצW
    fprintf ('%d %s\n', i, [file_path xls_name]); % ��ܥ��b�B�z�����|�M�ɮצW
    data = xlsread ([file_path xls_name]);
    d_nColumns = size (data, 1);
%% Load Background & Get Baseline : 
    bcg_name = xls_name (1:end-5); % .xls �r����׬�4,�u�����ɮצW (���t���ɦW)
    mbcg = mean (importdata ([bcg_name '.mat']), 3);
    mbsl = mean (importdata ([bcg_name '_baseline.mat']), 3);
    bcg_44 (1, 1:44) = mbcg (4, 62:105);
    bcg_44 (2, 1:44) = mbcg (2, 62:105);
    bcg = reshape (bcg_44, [] , 88);
    background = repmat (bcg, d_nColumns, 1);
    mix = mbsl-mbcg; % baseline���� - background����
    bsl_44 (1, 1:44) = mix (4, 62:105);
    bsl_44 (2, 1:44) = mix (2, 62:105);
    bsl = reshape (bsl_44, [] , 88);
    baseline = repmat (bsl, d_nColumns, 1);
%% Variable <d>: [raw intensity x timepoints]
    d = (data - background)./ baseline ; % �վ㥿�T.nirs��춶�� (�����@�_�վ�),�ۦP�i����F�ñ�,ex: C1W1 C2W1 C1W2 C2W2
%% Variable <t>: Sampling Rate
    t0 = adjust_info.t_table (i);
    tn = 0:1:size (d, 1)-1;
    t = t0*tn';
%% Variable <SD>: Change Wavelengths & MeasList for subject (different ROIs)
    SD.Lambda = adjust_info.Lambda;
    subject_name = bcg_name (3:4); 
    SD.MeasList = adjust_info.(subject_name);
    SD.MeasListAct = ones (88, 1);
%% Variable <s>
    s = zeros (d_nColumns, 1);
%% Variable <aux>
    aux = zeros (d_nColumns, 1);        
%% Save .nirs Files
    fprintf ('%d %s\n', i, ['�ثe�w���� ' file_path bcg_name '.nirs']); % ��ܥ��b�s�ɪ����|�M�ɮצW
    mkdir (subject_name); save ([subject_name '\' bcg_name '.nirs'], '-mat', 's', 'd', 't', 'SD', 'aux'); % �o��'-mat'���ӥi�H�ٲ� 
end
toc
msgbox ('Preprocessing .nirs file for different subjects in Homer3 is done!', 'Done')
%% Homer3: Motion Detection / Motion Correction / Bandpass Filter / GLM & Block Average