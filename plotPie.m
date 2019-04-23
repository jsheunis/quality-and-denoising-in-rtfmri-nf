function [vals, p] = plotPie(opts, procstep, articles, cb, title_str, varargin)

N = numel(opts);
vals = zeros(1,N);

for i = 1:N
    vals(i) = sum(cellfun(@(x) strcmp(x.features.(procstep), opts{1,i}) , articles));
end

if nargin > 5
    opts_recoded = varargin{1};
    inds_recoded = varargin{2};
    vals_recoded = zeros(1,numel(opts_recoded));
    for j = 1:numel(opts_recoded)
        vals_recoded(j) = sum(vals(inds_recoded{j}));
    end
    
    vals = vals_recoded;
    opts = opts_recoded;
    N = numel(opts);
end

[vals_sorted, sorted_ind] = sort(vals, 'descend');
count_labels = cell(1,N);
for i=1:N
    count_labels{1,i} = num2str(vals(i));
end
count_labels_sorted = count_labels(sorted_ind);
opts_sorted = opts(sorted_ind);

fig = figure('Position',[360   144   746   554]);
ax = axes('Parent', fig);
p = pie(ax, vals_sorted, count_labels_sorted);
l = legend(opts_sorted,'fontsize',18);

for i = 1:length(vals_sorted)
    set(p(i*2-1), 'FaceColor', cb(i,:))
end
set(findobj(p,'type','text'),'fontsize',18)
set(findobj(l,'type','text'),'fontsize',18)
end