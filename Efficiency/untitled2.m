
%% Parameters

files = 1:10;

window = 15;
slope_fraction = 0.01;
amplitude_fraction = 0.7;

% Minimum number of consecutive samples to accept as a plateau
min_plateau_length = 20;

% Preallocate
data_500 = cell(1, length(files));

plateau_start = NaN(length(files),1);
plateau_end = NaN(length(files),1);

plateau_start_raw = NaN(length(files),1);
plateau_end_raw = NaN(length(files),1);

plateau_mean = NaN(length(files),1);

%% Read files and detect plateaus

for k = 1:length(files)

    %% Read TDMS file

    fileName = sprintf( ...
        'efficiency-map-500RPM-%d.tdms', files(k));

    if ~isfile(fileName)
        warning('File %s not found. Skipping.', fileName);
        continue;
    end

    data_500{k} = tdmsread(fileName);

    % Extract first group
    raw_data = data_500{k}{1,1};

    % Extract torque signal
    torque_raw = raw_data.("FMI 1");
    mech_power = raw_data.("Mechanical Power");
    dc_power = raw_data.("EV_Phase7_True_Power");
    
    % Convert to column vector
    torque_raw = torque_raw(:);

    %% Filter torque values below 5 Nm

    % Keep original indices
    original_indices = find(torque_raw >= 5);

    % Filtered torque signal
    y = torque_raw(original_indices);

    %% Smooth signal

    y_smooth = smoothdata(y, 'movmean', window);

    %% Calculate gradient

    dy = gradient(y_smooth);

    %% Calculate thresholds

    signal_range = max(y) - min(y);

    slope_threshold = slope_fraction * signal_range;

    amplitude_threshold = min(y) + ...
        amplitude_fraction * signal_range;

    %% Identify plateau samples

    is_flat = abs(dy) < slope_threshold & ...
              y_smooth > amplitude_threshold;

    %% Find consecutive flat regions

    edges = diff([false; is_flat; false]);

    starts = find(edges == 1);
    ends = find(edges == -1) - 1;

    %% Remove plateaus that are too short

    valid = (ends - starts + 1) >= min_plateau_length;

    starts = starts(valid);
    ends = ends(valid);

    %% Check if plateau was found

    if isempty(starts)

        warning('No plateau found in file %d.', files(k));

        continue;

    end

    %% Find longest plateau

    [~, best_idx] = max(ends - starts + 1);

    plateau_start(k) = starts(best_idx);
    plateau_end(k) = ends(best_idx);

    %% Convert filtered indices to original TDMS indices

    plateau_start_raw(k) = ...
        original_indices(plateau_start(k));

    plateau_end_raw(k) = ...
        original_indices(plateau_end(k));

    %% Calculate mean plateau torque

    plateau_mean(k) = mean( ...
        y(plateau_start(k):plateau_end(k)));

    %% Display results

    fprintf('\nFile %d\n', files(k));

    fprintf('Filtered start index: %d\n', ...
        plateau_start(k));

    fprintf('Filtered end index: %d\n', ...
        plateau_end(k));

    fprintf('Original start index: %d\n', ...
        plateau_start_raw(k));

    fprintf('Original end index: %d\n', ...
        plateau_end_raw(k));

    fprintf('Mean plateau torque: %.3f Nm\n', ...
        plateau_mean(k));

    %% Plot for debugging

    figure('Name', sprintf('500 RPM - File %d', files(k)));

    plot(y, 'DisplayName', 'Filtered torque');
    hold on;

    plot(y_smooth, 'DisplayName', 'Smoothed torque');

    xline(plateau_start(k), '--g', 'Plateau start');
    xline(plateau_end(k), '--r', 'Plateau end');

    yline(amplitude_threshold, '--k', ...
        'Amplitude threshold');

    legend;
    grid on;

    xlabel('Filtered sample index');
    ylabel('Torque (Nm)');

    title(sprintf('500 RPM - File %d', files(k)));

end

%% Create results table

results = table( ...
    files(:), ...
    plateau_start, ...
    plateau_end, ...
    plateau_start_raw, ...
    plateau_end_raw, ...
    plateau_mean, ...
    'VariableNames', { ...
        'FileNumber', ...
        'FilteredStartIndex', ...
        'FilteredEndIndex', ...
        'OriginalStartIndex', ...
        'OriginalEndIndex', ...
        'MeanPlateauTorque'});

disp(results);

