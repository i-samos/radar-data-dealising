function [amplitudes, phases] = analyzeFFT(vel)
    %% ANALYZEFFT
    % This function performs FFT analysis on horizontal rays (horays) of the `vel` matrix.
    % It computes the dominant frequency's amplitude and phase for each horay.
    %
    % Inputs:
    %   - vel: 2D matrix of velocity data (rows: horays, columns: data points per horay)
    %
    % Outputs:
    %   - amplitudes: Array of amplitudes for the dominant frequency in each horay
    %   - phases: Array of phases (in degrees) for the dominant frequency in each horay

    %% Step 1: Initialization
    num_horays = size(vel, 1); % Number of horays (rows in `vel`)
    sample_rate = 1; % Assumed uniform sampling rate (arbitrary units)

    % Set a threshold for minimum number of non-zero values in a valid horay
    non_zero_threshold = 0.1 * size(vel, 2); % 10% of horay length

    % Initialize output arrays
    amplitudes = zeros(num_horays, 1); % Amplitudes of the dominant frequency
    phases = zeros(num_horays, 1); % Phases of the dominant frequency (in degrees)

    %% Step 2: Loop through each horay
    for i = 1:num_horays
        % Extract the current horay (row from `vel`)
        horay = vel(i, :);

        % Remove NaNs and retain only valid values
        valid_indices = ~isnan(horay);
        horay_valid = horay(valid_indices);

        % Check if the horay has enough valid non-zero values
        if sum(horay_valid ~= 0) < non_zero_threshold
            continue; % Skip processing if horay is mostly zero
        end

        %% Step 3: Perform FFT on valid data
        N = numel(horay_valid); % Number of valid data points
        fft_result = fft(horay_valid); % Compute FFT of the valid horay

        % Frequency values (for reference, not used here)
        freq_values = (0:N-1) * (sample_rate / N); % Frequency axis in Hz

        % Find the dominant frequency component (ignoring DC component at index 1)
        [~, max_index] = max(abs(fft_result(2:floor(N/2)))); % Find max magnitude index
        max_index = max_index + 1; % Adjust index for skipping DC component

        %% Step 4: Extract amplitude and phase at the dominant frequency
        try
            amplitudes(i) = 2 * abs(fft_result(max_index)) / N; % Scale amplitude
        catch
            amplitudes(i) = NaN; % Handle cases where FFT results may fail
        end

        try
            phases(i) = angle(fft_result(max_index)) * (180 / pi); % Convert phase to degrees
        catch
            phases(i) = NaN; % Handle cases where FFT results may fail
        end
    end
end
