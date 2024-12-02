function [max_count, corresponding_value] = find_best_shift(vel_new, labeled_regions)
    %% FIND_BEST_SHIFT
    % This function identifies the most frequent value in the labeled_regions matrix,
    % excluding NaN values, and returns its count and the corresponding value.
    %
    % Inputs:
    %   - vel_new: Matrix of velocities, used to mask NaN regions
    %   - labeled_regions: Matrix with labeled regions (e.g., region identifiers)
    %
    % Outputs:
    %   - max_count: Maximum occurrence count of a region label
    %   - corresponding_value: The region label with the maximum count

    %% Step 1: Mask `labeled_regions` using NaNs from `vel_new`
    is_nan_mask = isnan(vel_new); % Create a NaN mask from `vel_new`
    masked_regions = labeled_regions; % Copy `labeled_regions` for masking
    masked_regions(is_nan_mask) = NaN; % Apply NaN mask

    %% Step 2: Flatten the matrix and find unique values
    flattened_regions = masked_regions(:); % Flatten to a 1D vector
    unique_values = unique(flattened_regions(~isnan(flattened_regions))); % Get unique non-NaN values

    %% Step 3: Count occurrences of each unique value
    counts = zeros(size(unique_values)); % Initialize counts array
    for i = 1:length(unique_values)
        counts(i) = sum(flattened_regions == unique_values(i)); % Count occurrences
    end

    %% Step 4: Handle NaN counts separately
    nan_count = sum(isnan(flattened_regions)); % Count NaN values
    unique_values_with_nan = [unique_values; NaN]; % Include NaN in unique values
    counts_with_nan = [counts; nan_count]; % Add NaN count to counts

    %% Step 5: Combine results into a matrix and exclude NaN rows
    result_matrix = [unique_values_with_nan, counts_with_nan]; % Combine values and counts
    result_matrix_no_nan = result_matrix(~isnan(result_matrix(:, 1)), :); % Remove rows with NaN

    %% Step 6: Find the maximum count and corresponding value
    [max_count, max_idx] = max(result_matrix_no_nan(:, 2)); % Find the max count
    corresponding_value = result_matrix_no_nan(max_idx, 1); % Get the corresponding value

    %% Outputs
    % max_count: Maximum frequency count
    % corresponding_value: Region label with the maximum count
end
