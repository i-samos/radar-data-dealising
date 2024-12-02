function corrected_phases = correctPhases(phases)
    %% CORRECTPHASES
    % This function adjusts the input `phases` array to ensure continuity by
    % correcting potential phase jumps. Each phase is modified to be as close
    % as possible to the previous phase, considering periodicity.
    %
    % Input:
    %   - phases: An array of phase values (in degrees)
    % Output:
    %   - corrected_phases: Array of adjusted phase values for continuity

    %% Initialize the corrected phases array
    corrected_phases = phases; % Start with the original phase values

    %% Loop through each phase starting from the second element
    for i = 2:length(phases)
        % Smooth the previous phases to reduce noise in continuity checks
        % (Uses a moving average over the last 6 phases, or fewer if near the start)
        try
            smooth_amplitude = nanmean(corrected_phases(max(1, i-6):i-1));
        catch
            smooth_amplitude = corrected_phases(i-1); % Use the previous phase if smoothing fails
        end

        % Define possible values for the current phase, including periodic shifts
        possible_values = [
            phases(i), ...
            phases(i) - 360, ...
            phases(i) + 360, ...
            phases(i) + 180, ...
            phases(i) - 180
        ];

        % Identify the closest value to the smoothed amplitude
        [~, closest_idx] = min(abs(possible_values - smooth_amplitude));

        % Update the corrected phase to maintain continuity
        corrected_phases(i) = possible_values(closest_idx);
    end
end
