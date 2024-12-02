function [vel_algorithm, vel_combined, vel_expansion, amplitudes, phases_alg1, phases] = dealise_velocities(vel, dbz, interactive)
    %% DEALISE_VELOCITIES
    % This function dealiases velocity data (`vel`) using a combination of algorithms.
    % It applies amplitude correction, perimeter expansion, and Fourier analysis.
    %
    % Inputs:
    %   - vel: Matrix of velocity data
    %   - dbz: Reflectivity matrix
    %   - interactive: Flag for interactive mode (used in expansion_algorithm)
    %
    % Outputs:
    %   - vel_algorithm: Dealiased velocity matrix using primary algorithm
    %   - vel_combined: Combined matrix of dealiased and expanded velocities
    %   - vel_expansion: Dealiased velocity matrix using expansion algorithm
    %   - amplitudes: Dominant frequency amplitudes from FFT analysis
    %   - phases_alg1: Corrected phases from algorithm
    %   - phases: Corrected phases from FFT analysis

    %% Initialization
    limit = max(abs(vel(:))); % Determine the velocity limit
    testnan=isnan(vel);
    testnan=sum(testnan);
    [~,idx_shift]=max(testnan);
    vel_shifted=circshift(vel',-idx_shift)'; % Circular shift to align NaN regions

    % Initialize matrices
    vel_algorithm = vel_shifted;
    vel_combined = vel_shifted;
    vel_expansion = vel_shifted;

    %% Step 1: Primary velocity dealiasing algorithm
    [vel_algorithm, ~] = dealise_filter(vel_algorithm);
    vel_algorithm = correctAmplitude360Optimized(vel_algorithm, limit);
    vel_algorithm = make_full(vel_algorithm, vel_shifted);
    vel_algorithm = locate_initial(vel_shifted, vel_algorithm, limit);

    %% Step 2: Expansion algorithm for perimeter dealiasing
    original = vel_shifted;
    check_nan_original = ~isnan(original);
    sum_valid_original = sum(check_nan_original(:));

    % First pass of the expansion algorithm
    expanded_data = expansion_algorithm(vel_expansion, original, dbz, limit, interactive);
    valid_mask = ~isnan(expanded_data);
    sum_valid_expanded = sum(valid_mask(:));
    vel_expansion(valid_mask) = expanded_data(valid_mask);

    % Iteratively expand until no further changes occur
    while sum_valid_expanded < sum_valid_original
        try
            remaining_data = original;
            remaining_data(valid_mask) = NaN;
            additional_expanded_data = expansion_algorithm(remaining_data, original, dbz, limit, interactive);
            additional_valid_mask = ~isnan(additional_expanded_data);
            sum_valid_previous = sum_valid_expanded;
            sum_valid_expanded = sum(valid_mask(:)) + sum(additional_valid_mask(:));
            vel_expansion(additional_valid_mask) = additional_expanded_data(additional_valid_mask);
            if logical(exist('sum_valid_previous', 'var')) && sum_valid_previous == sum_valid_expanded
                break; % Stop if no further progress is made
            end
        catch
            break; % Exit if an error occurs during expansion
        end
    end

    %% Step 3: Combine algorithm and expansion results
    match_mask = vel_algorithm == vel_expansion;
    vel_combined(match_mask) = vel_algorithm(match_mask);
    vel_combined(~match_mask) = NaN;

    %% Step 4: Undo circular shift for output matrices
    vel = circshift(vel', max(sum(isnan(vel))))';
    vel_algorithm = circshift(vel_algorithm', idx_shift)';
    vel_combined = circshift(vel_combined', idx_shift)';
    vel_expansion = circshift(vel_expansion', idx_shift)';

    %% Step 5: Phase and FFT analysis
    [~, phases_alg] = dealise_filter(vel_combined);
    phases_alg1 = correctPhases(-phases_alg(:, 1) + 90); % Correct phases from algorithm

    % Perform FFT analysis on the combined matrix
    [amplitudes, phases] = analyzeFFT(vel_combined);
    phases = correctPhases(-phases); % Correct phases from FFT

    % Apply NaN mask to phases and amplitudes
    nan_mask = isnan(phases_alg1);
    phases(nan_mask) = NaN;
    amplitudes(nan_mask) = NaN;
end
