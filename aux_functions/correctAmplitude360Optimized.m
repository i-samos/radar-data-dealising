function vel = correctAmplitude360Optimized(vel, limit)
h1 = waitbar(0,'Dealising...');

    [numRows, numCols] = size(vel);
    vel_corr = vel;  % Copy for correction
    [ray_ranking_matrix, horay_ranking_matrix] = identifyBaselineRays(vel);
    
    for i = 1:numCols
            waitbar(i/numCols,h1)

        col = horay_ranking_matrix(i,1);
        amplitude = vel(:, col);
        corrected_amplitude = amplitude;

        % Loop through amplitudes in the column
        for i = 2:numRows
            
            if isnan(amplitude(i))
                continue;
            end

            % Find the last valid value dynamically
            prev_index = find(~isnan(corrected_amplitude(1:i-1)), 1, 'last');
            if isempty(prev_index)
                corrected_amplitude(i) = amplitude(i);
                continue;
            end

            % Dynamic window for smoothing
            try
                smooth_amplitude = nanmean(corrected_amplitude(max(prev_index-9,1):prev_index));
            catch
                smooth_amplitude = corrected_amplitude(prev_index);
            end

            % Define possible values for amplitude
            intermediate_values = amplitude(i) + [-0.5*limit, 0, 0.5*limit];
            possible_values = sort([intermediate_values, amplitude(i) - 2*limit, amplitude(i) + 2*limit]);

            % Evaluate options against smoothed reference
            [~, closest_idx] = nanmin(abs(possible_values - smooth_amplitude));

            % If intermediate is selected, stick to original amplitude
            if closest_idx == 2 || closest_idx == 4
                corrected_amplitude(i) = amplitude(i);
            else
                corrected_amplitude(i) = possible_values(closest_idx);
            end
        end

        vel_corr(:, col) = corrected_amplitude;

    end

    % Perform continuity checks and mask discontinuous rays
    check_matrix_clockwise = continuityCheck(vel_corr, 1);
    check_matrix_counterclockwise = continuityCheck(vel_corr, -1);
    discontinuity_mask = propagateMask(check_matrix_clockwise | check_matrix_counterclockwise);

    % Apply mask to remove discontinuities
%     vel_corr(:, discontinuity_mask) = NaN;
    vel_corr(:, discontinuity_mask) = -999;
    vel = vel_corr;
    vel = eliminate_isolated(vel);


close(h1)

end

function continuity_check = continuityCheck(vel, direction)
    [~, numCols] = size(vel);
    continuity_check = false(1, numCols);

    for col = 1:numCols
        amplitude = vel(:, col);
        next_col = mod(col + direction - 1, numCols) + 1;  % Handle wrap-around
        amplitude_next = vel(:, next_col);

        avg_diff = nanmean(amplitude_next - amplitude);
        continuity_check(col) = abs(avg_diff) > 1;  % Threshold for discontinuity
    end
end

function expanded_mask = propagateMask(mask)
    expanded_mask = mask;
    idx = find(mask);
    if ~isempty(idx)
        expanded_mask(max(idx - 1, 1)) = true;  % Propagate to previous
        expanded_mask(min(idx + 1, length(mask))) = true;  % Propagate to next
    end
end
