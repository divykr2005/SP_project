function severity = compute_severity_index(cfg, featureTable)
%COMPUTE_SEVERITY_INDEX Estimate relative abnormality, not true damage size.

X = table2array(featureTable(:, cfg.severityFeatureNames));
healthyMask = featureTable.health_index == 1;
healthyX = X(healthyMask, :);

mu = mean(healthyX, 1);
sigma = std(healthyX, 0, 1);
sigma(sigma == 0) = 1;

z = (X - mu) ./ sigma;
windowScore = mean(max(z, 0), 2);

files = unique(featureTable.file, 'stable');
fileScore = zeros(numel(files), 1);
fileCol = strings(numel(files), 1);
healthNameCol = strings(numel(files), 1);
speedNameCol = strings(numel(files), 1);
caseNameCol = strings(numel(files), 1);
levelCol = strings(numel(files), 1);
healthIndexCol = zeros(numel(files), 1);
trialCol = zeros(numel(files), 1);

for i = 1:numel(files)
    mask = featureTable.file == files(i);
    first = find(mask, 1);
    fileScore(i) = mean(windowScore(mask));
    fileCol(i) = files(i);
    healthNameCol(i) = featureTable.health_name(first);
    speedNameCol(i) = featureTable.speed_name(first);
    caseNameCol(i) = featureTable.case_name(first);
    healthIndexCol(i) = featureTable.health_index(first);
    trialCol(i) = featureTable.trial(first);
end

healthyFileScores = fileScore(healthIndexCol == 1);
faultFileScores = fileScore(healthIndexCol ~= 1);
goodThreshold = percentile_plain(healthyFileScores, 95);
severeThreshold = median(faultFileScores);
if severeThreshold <= goodThreshold
    severeThreshold = goodThreshold + max(std(faultFileScores), eps);
end

for i = 1:numel(files)
    if fileScore(i) <= goodThreshold
        levelCol(i) = "Good/normal";
    elseif fileScore(i) <= severeThreshold
        levelCol(i) = "Mild abnormal";
    else
        levelCol(i) = "Severe abnormal";
    end
end

windowSeverityTable = featureTable(:, { ...
    'file', ...
    'health_name', ...
    'speed_name', ...
    'case_name', ...
    'trial', ...
    'window_index'});
windowSeverityTable.severity_score = windowScore;

fileSeverityTable = table( ...
    fileCol, ...
    healthIndexCol, ...
    healthNameCol, ...
    speedNameCol, ...
    caseNameCol, ...
    trialCol, ...
    fileScore, ...
    levelCol, ...
    'VariableNames', { ...
    'file', ...
    'health_index', ...
    'health_name', ...
    'speed_name', ...
    'case_name', ...
    'trial', ...
    'severity_score', ...
    'estimated_level'});

severity = struct();
severity.featureNames = cfg.severityFeatureNames;
severity.windowTable = windowSeverityTable;
severity.fileTable = fileSeverityTable;
severity.baselineMu = mu;
severity.baselineSigma = sigma;
severity.goodThreshold = goodThreshold;
severity.severeThreshold = severeThreshold;
severity.note = "Severity levels are estimated from vibration abnormality and are not ground-truth defect sizes.";
end

function q = percentile_plain(x, pct)
x = sort(x(:));
if isempty(x)
    q = NaN;
    return;
end
pos = 1 + (numel(x) - 1) * pct / 100;
low = floor(pos);
high = ceil(pos);
if low == high
    q = x(low);
else
    q = x(low) + (x(high) - x(low)) * (pos - low);
end
end
