%% Parameters

files = 1:10;

window = 15;
slope_fraction = 0.01;
amplitude_fraction = 0.7;

% Minimum number of consecutive samples to accept as a plateau
min_plateau_length = 20;

% Preallocate
RPM_Data_500 = cell(1, length(files));

plateau_start = NaN(length(files),1);
plateau_end = NaN(length(files),1);

plateau_start_raw = NaN(length(files),1);
plateau_end_raw = NaN(length(files),1);

plateau_mean = NaN(length(files),1);


% Preallocate a cell array to store the structure returned by tdmsread
tdmsData = cell(1, length(files));

for k = 1:length(files)
    % Construct filename using string interpolation or sprintf
    fileName = sprintf('efficiency-map-500RPM-%d.tdms', files(k));

    % Check if the file exists before reading to avoid crashing the loop
    if isfile(fileName)
        RPM_Data_500{k} = tdmsread(fileName); % Stores data as cell array
    else
        warning('File %s not found. Skipping.', fileName);

    end
end

rpm_500_1 = RPM_Data_500{1, 1}{1, 1};

rpm_500_2 = RPM_Data_500{1, 2}{1, 1};

rpm_500_3 = RPM_Data_500{1, 3}{1, 1};

rpm_500_4 = RPM_Data_500{1, 4}{1, 1};

rpm_500_5 = RPM_Data_500{1, 5}{1, 1};

rpm_500_6 = RPM_Data_500{1, 6}{1, 1};

rpm_500_7 = RPM_Data_500{1, 7}{1, 1};

rpm_500_8 = RPM_Data_500{1, 8}{1, 1};

rpm_500_9 = RPM_Data_500{1, 9}{1, 1};

rpm_500_10 = RPM_Data_500{1, 10}{1, 1};


torque_500_1_raw = rpm_500_1.("FMI 1");
torque_500_2_raw = rpm_500_2.("FMI 1");
torque_500_3_raw = rpm_500_3.("FMI 1");
torque_500_4_raw = rpm_500_4.("FMI 1");
torque_500_5_raw = rpm_500_5.("FMI 1");
torque_500_6_raw = rpm_500_6.("FMI 1");
torque_500_7_raw = rpm_500_7.("FMI 1");
torque_500_8_raw = rpm_500_8.("FMI 1");
torque_500_9_raw = rpm_500_9.("FMI 1");
torque_500_10_raw = rpm_500_10.("FMI 1");


idx = find(torque_500_1_raw>=5);
torque_500_1 = torque_500_1_raw(idx);
figure;
plot(torque_500_1)
hold off;

idx = find(torque_500_2_raw>=5);
torque_500_2 = torque_500_2_raw(idx);
plot(torque_500_2)
hold off;

idx = find(torque_500_3_raw>=5);
torque_500_3 = torque_500_3_raw(idx);
figure;
plot(torque_500_3)
hold off;

idx = find(torque_500_4_raw>=5);
torque_500_4 = torque_500_4_raw(idx);
figure;
plot(torque_500_4)
hold off;

idx = find(torque_500_5_raw>=5);
torque_500_5 = torque_500_5_raw(idx);
figure;
plot(torque_500_5)
hold off;

idx = find(torque_500_6_raw>=5);
torque_500_6 = torque_500_6_raw(idx);
figure;
plot(torque_500_6)
hold off;

idx = find(torque_500_7_raw>=5);
torque_500_7 = torque_500_7_raw(idx);
figure;
plot(torque_500_7)
hold off;

idx = find(torque_500_8_raw>=5);
torque_500_8 = torque_500_8_raw(idx);
figure;
plot(torque_500_8)
hold off;

idx = find(torque_500_9_raw>=5);
torque_500_9 = torque_500_9_raw(idx);
figure;
plot(torque_500_9)
hold off;

idx = find(torque_500_10_raw>=5);
torque_500_10 = torque_500_10_raw(idx);

figure;
plot(torque_500_10)
hold off;


% Input signal
y = torque_500_1; % Replace with your variable

% Parameters
window = 15;          % Smoothing window (samples)
slope_fraction = 0.01; % Relative gradient threshold

% Smooth the signal
y_smooth = smoothdata(y, 'movmean', window);

% Calculate gradient
dy = gradient(y_smooth);

% Set threshold relative to the signal's range
signal_range = max(y) - min(y);
slope_threshold = slope_fraction * signal_range;

% Identify approximately flat regions
is_flat = abs(dy) < slope_threshold;

% Find consecutive flat regions
edges = diff([false; is_flat; false]);

starts = find(edges == 1);
ends = find(edges == -1) - 1;

% Find the longest flat region
if isempty(starts)
    error('No plateau detected. Adjust the parameters.');
end

[~, idx] = max(ends - starts + 1);

plateau_start = starts(idx);
plateau_end = ends(idx);

% Display results
fprintf('Plateau begins at index: %d\n', plateau_start);
fprintf('Plateau ends at index: %d\n', plateau_end);

% Plot results
figure;
plot(y, 'DisplayName', 'Original signal');
hold on;
plot(y_smooth, 'DisplayName', 'Smoothed signal');

xline(plateau_start, '--g', 'Plateau start');
xline(plateau_end, '--r', 'Plateau end');

legend;
grid on;


