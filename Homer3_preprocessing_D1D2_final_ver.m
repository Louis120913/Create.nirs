%% Adjust Homer3_preprocessing Data for different subjects
%% Author: Tai-Jui Chang, 2021.08.26
%% Choose Folder & Load Demo File (Homer3: 'SD', 't', 'd', 's', 'aux')
clear; clc;
[Demo_nirs, file_path] = uigetfile('*.nirs','請選擇位於存放Homer3分析結果位置的.nirs範例檔案');
tic
cd (file_path); load (Demo_nirs, '-mat'); load ('adjust_info_D1D2');
xls_path_list = dir ([file_path '*.xlsx']); % dir可看目前目錄底下或者指定路徑全名
xls_num = length (xls_path_list);
%% Load Raw Intensity : 資料夾內部,屬於最底層的for迴圈
for i = 1:xls_num
    xls_name = xls_path_list (i).name; % 檔案名稱列表取得各自檔案名
    fprintf ('%d %s\n', i, [file_path xls_name]); % 顯示正在處理的路徑和檔案名
    data = xlsread ([file_path xls_name]);
    d_nColumns = size (data, 1);
%% Load Background & Get Baseline : 
    bcg_name = xls_name (1:end-5); % .xls 字串長度為4,真正的檔案名 (不含附檔名)
    mbcg = mean (importdata ([bcg_name '.mat']), 3);
    mbsl = mean (importdata ([bcg_name '_baseline.mat']), 3);
    bcg_44 (1, 1:44) = mbcg (4, 62:105);
    bcg_44 (2, 1:44) = mbcg (2, 62:105);
    bcg = reshape (bcg_44, [] , 88);
    background = repmat (bcg, d_nColumns, 1);
    mix = mbsl-mbcg; % baseline平均 - background平均
    bsl_44 (1, 1:44) = mix (4, 62:105);
    bsl_44 (2, 1:44) = mix (2, 62:105);
    bsl = reshape (bsl_44, [] , 88);
    baseline = repmat (bsl, d_nColumns, 1);
%% Variable <d>: [raw intensity x timepoints]
    d = (data - background)./ baseline ; % 調整正確.nirs欄位順序 (扣完一起調整),相同波長緊鄰並排,ex: C1W1 C2W1 C1W2 C2W2
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
    fprintf ('%d %s\n', i, ['目前已完成 ' file_path bcg_name '.nirs']); % 顯示正在存檔的路徑和檔案名
    mkdir (subject_name); save ([subject_name '\' bcg_name '.nirs'], '-mat', 's', 'd', 't', 'SD', 'aux'); % 這邊'-mat'應該可以省略 
end
toc
msgbox ('Preprocessing .nirs file for different subjects in Homer3 is done!', 'Done')
%% Homer3: Motion Detection / Motion Correction / Bandpass Filter / GLM & Block Average