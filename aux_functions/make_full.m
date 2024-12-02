function vel_filled = make_full(vel_new, vel)
    %% MAKE_FULL
    % This function fills in missing (NaN) values in the `vel_new` matrix
    % using cubic interpolation. It also performs corrections for cases
    % where the edges of `vel_new` have NaN values.

    % Get the size of the input matrix and identify NaN elements in `vel`
    [numRows, numCols] = size(vel);
    original_nan_mask = isnan(vel);

    % Check if corrections are needed for `vel_new`
    if (isnan(vel_new(:, 1)) & isnan(vel_new(:, end))) | isnan(vel_new(:, 1))
        % Correction flag
        correction_needed = true;

        % Extend `vel_new` for circular edge handling
        vel_extended = [vel_new vel_new vel_new];

        % Identify valid columns with non-NaN elements
        column_validity = cell(1, 180);
        for j = 1:180
            [~, valid_columns] = find(~isnan(vel_extended(:, j)) & ~isnan(vel_extended(:, j + 180)));
            column_validity{j} = valid_columns;
        end

        % Find the middle valid column range
        valid_columns = find(~cellfun(@isempty, column_validity));
        start_col = valid_columns(round(length(valid_columns) / 2));
        end_col = start_col + 360;

        % Circularly shift `vel_new` to align valid columns
        vel_new = circshift(vel_new, [0 start_col]);

    else
        correction_needed = false;
    end

    % Get the size of the corrected `vel_new`
    [numRowsNew, numColsNew] = size(vel_new);

    % Create coordinate grids for interpolation
    [X, Y] = meshgrid(1:numColsNew, 1:numRowsNew);

    % Identify valid (non-NaN) and missing (NaN) values
    valid_mask = ~isnan(vel_new);
    x_valid = X(valid_mask);
    y_valid = Y(valid_mask);
    z_valid = vel_new(valid_mask);

    x_nan = X(~valid_mask);
    y_nan = Y(~valid_mask);

    % Perform cubic interpolation to fill missing values
    vel_filled = vel_new;
    vel_filled(~valid_mask) = griddata(x_valid, y_valid, z_valid, x_nan, y_nan, 'cubic');

    % Undo the circular shift if corrections were applied
    if correction_needed
        vel_filled = circshift(vel_filled, [0 -start_col]);
    end

    % Restore original NaN values in the output matrix
    vel_filled(original_nan_mask) = nan;

end
