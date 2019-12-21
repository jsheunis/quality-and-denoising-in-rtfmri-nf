
%% Purpose
% This script allows reproducibility of figures in the manuscript:
% Quality and denoising in real-time fMRI neurofeedback: a methods review
% (https://osf.io/xubhq)

% The script:
% 1) Loads a list of articles (JSON) and annotated features (txt) into Matlab
% 2) Wrangles the data to match the features to the articles using DOI
% 3) Plots pie charts
% 4) Plots a bar graph

% Dependencies:
% Color brewer: https://nl.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab

%% Load article AND features (Data provided in github repo and OSF supplementary material)

articles_json = 'Users/jheunis/Documents/MATLAB/quality-and-denoising-in-rtfmri-nf/rtfMRI_methods_review_included_studies.json';
articles = loadjson(articles_json);
articles_features_txt = 'Users/jheunis/Documents/MATLAB/quality-and-denoising-in-rtfmri-nf/rtfMRI_methods_review_included_studies_procsteps.txt';
articles_features = tdfread(articles_features_txt);
articles_features_defaults_txt = 'Users/jheunis/Documents/MATLAB/quality-and-denoising-in-rtfmri-nf/rtfMRI_methods_review_included_studies_procsteps_DEFAULTS.txt';
articles_features_defaults = tdfread(articles_features_defaults_txt);

%% Select features to plot

% features = articles_features;
features = articles_features_defaults;

%% Data wrangling to add features to articles

N_studies = numel(articles);
article_feature_mapping = zeros(N_studies,2);
for i = 1:N_studies
    article_feature_mapping(i,1) = i;
    doi = lower(strtrim(articles{1,i}.DOI));
    
    for j = 1:N_studies
        if strcmp(doi, lower(strtrim(features.doi(j,:))))
            article_feature_mapping(i,2) = j;
        end
    end
    
    if article_feature_mapping(i,2) == 0
        disp(num2str(i))
    end
    
    feature_fields = fieldnames(features);
    num_fields = length(feature_fields);
    for K = 1:num_fields
        this_field = feature_fields{K};
        articles{1,i}.features.(this_field) = strtrim(features.(this_field)(article_feature_mapping(i,2),:));
    end
end

%% Create colormaps for figures

% [colormap]=cbrewer(ctype, cname, ncol, interp_method)
%
% INPUT:
%   - ctype: type of color table 'seq' (sequential), 'div' (diverging), 'qual' (qualitative)
%   - cname: name of colortable. It changes depending on ctype.
%   - ncol:  number of color in the table. It changes according to ctype and
%            cname
%   - interp_method: interpolation method (see interp1.m). Default is "cubic" )

[cb1] = cbrewer('div','Spectral',5,'pchip');
[cb2] = cbrewer('div','RdBu',7,'pchip');
[cb3] = cbrewer('div','Spectral',7,'pchip');
[cb33] = cbrewer('div','Spectral',9,'pchip');
[cb4] = cbrewer('div','RdYlGn',7,'pchip');
[cb5] = cbrewer('qual','Paired',8,'pchip');
[cb6] = cbrewer('qual','Paired',5,'pchip');

%% Plot pie charts

% --- RESPIRATORY CORRECTION ----
% 'RT', 'RT + OFFLINE RETROICOR', 'RT + OFFLINE RETROICOR + OFFLINE CORR', ==> 'RT'
% 'DNR', 'OFFLINE CORR', 'OFFLINE RETROICOR', 'MONITOR EXCLUSION' ==> 'DNR'
% 'ROI DIFF', 'ROI DIFF + OFFLINE CORR', ==> 'ROI DIFF'
% 'RT CORR +REG', ==> 'OTHER'
% 'N', ==> 'N'
resp = {'RT',...
'DNR',...
'ROI DIFF',...
'ROI DIFF + OFFLINE CORR',...
'RT + OFFLINE RETROICOR',...
'RT + OFFLINE RETROICOR + OFFLINE CORR',...
'RT CORR +REG',...
'OFFLINE CORR',...
'OFFLINE RETROICOR',...
'N',...
'MONITOR EXCLUSION'};
resp_correction = {'RT',...
'DNR',...
'ROI DIFF',...
'OTHER',...
'N'};
inds_recoded = cell(1, numel(resp_correction));
inds_recoded{1} = [1,5,6];
inds_recoded{2} = [2,8,9,11];
inds_recoded{3} = [3,4];
inds_recoded{4} = 7;
inds_recoded{5} = 10;
title_str = 'RESPIRATORY CORRECTION';
[resp_vals, p] = plotPie(resp, 'resp', articles, cb3, title_str, resp_correction, inds_recoded);

% --- SOFTWARE ----
software = {'AFNI',...
'OpenNFT',...
'TBV',...
'Custom Matlab + SPM',...
'Custom Other',...
'BioImage Suite',...
'FRIEND',...
'BART'};
title_str = 'SOFTWARE';
plotPie(software, 'software', articles, cb5, title_str)

% --- SPATIAL SMOOTHING ----
spatial_smooth = {'4MM',...
'5MM',...
'6MM',...
'7MM',...
'8MM',...
'9MM',...
'12MM',...
'DNR',...
'Y'};
title_str = 'SPATIAL SMOOTHING';
plotPie(spatial_smooth, 'ss', articles, cb33, title_str)

% --- DRIFT REMOVAL ----
drift = {'BANDPASS',...
'HIGHPASS',...
'EMA',...
'IGLM',...
'DNR',...
'Y'};
title_str = 'DRIFT REMOVAL';
plotPie(drift, 'dr', articles, cb3, title_str)

% --- TEMPORAL SMOOTHING ----
temporal_smooth = {'2PT',...
'3PT',...
'4PT',...
'5PT',...
'6PT',...
'DNR',...
'Y'};
title_str = 'TEMPORAL SMOOTHING';
plotPie(temporal_smooth, 'ts', articles, cb3, title_str)

% --- FREQUENCY FILTERING ----
freq_filt = {'BANDPASS',...
'HIGHPASS',...
'LOWPASS',...
'DNR',...
'Y'};
title_str = 'FREQUENCY FILTERING';
plotPie(freq_filt, 'ff', articles, cb3, title_str)

% --- OUTLIER REMOVAL ----
outlier_rem = {'KALMAN',...
'DNR',...
'Y'};
title_str = 'OUTLIER REMOVAL';
plotPie(outlier_rem, 'or', articles, cb3, title_str)

% --- FIELD STRENGTH ----
field_strength = {'1.5T',...
'1.5T,3T',...
'3T',...
'3T,7T'};
title_str = 'FIELD STRENGTH';
plotPie(field_strength, 'magnet', articles, cb6, title_str)



%% Plot bar graph
N_studies = numel(articles);
y_mat = zeros(1,10);
feats = {'stc', 'mc', 'ss', 'dr', 'hmp', 'ts', 'ff', 'or', 'droi'};

for i = 1:numel(feats)
    y_mat(i) = sum(cellfun(@(x) strcmp(x.features.(feats{i}), 'DNR') , articles)) + sum(cellfun(@(x) strcmp(x.features.(feats{i}), 'N') , articles));
end
y_mat(10) = N_studies - resp_vals(1);

[cb] = cbrewer('qual','Set3',12,'pchip');
cl(1,:) = cb(4,:);
cl(2,:) = cb(1,:);
fig_position = [100 65 1089 640]; % coordinates for figures

N_studies = 128;
pps_dnr_no = y_mat;
studies = N_studies*ones(size(pps_dnr_no));
pps_yes = studies - pps_dnr_no;
bar_data = vertcat(pps_yes, pps_dnr_no);
f1 = figure;
b1 = bar(bar_data');

b1(1).FaceColor = cb4(7,:);
b1(1).FaceAlpha = 0.7;
b1(2).FaceColor = cb4(1,:);
b1(2).FaceAlpha = 0.7;

l1 = legend(b1, {'Yes','No/DNR'});

xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Slice timing','Volume realignment',...
    'Spat. smoothing','Drift removal',...
    '6HMP regression','Temp. smoothing',...
    'Freq. filtering',...
    'Outlier removal','Differential ROI',...
    'Physio. noise'},...
    'XTickLabelRotation',45,...
    'fontsize',18);
grid;