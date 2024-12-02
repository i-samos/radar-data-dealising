function vel = eliminate_isolated(vel)
    %% ELIMINATE_ISOLATED
    % This function identifies isolated values in the first row of the `vel` matrix,
    % applies convolution-based checks to detect these isolated points, and updates
    % the corresponding columns in `vel` by setting them to -999 or NaN.
    %
    % Input:
    %   - vel: A 2D matrix where the first row is analyzed for isolated values
    % Output:
    %   - vel: Updated matrix with isolated values handled

    %% Step 1: Extract and preprocess the first row
    first_row = vel(1, :); % Extract the first row of `vel`
    % Create a binary mask where -999 values are marked as 1
    binary_mask = first_row;
    binary_mask(binary_mask ~= -999) = 0; % Mark non-isolated values as 0
    binary_mask(binary_mask == -999) = 1; % Mark -999 values as 1

    %% Step 2: Apply convolution to identify isolated points
    % Define a convolution kernel
    conv_kernel = [1 0 1];
    % Perform two passes of convolution
    neighbors_count = conv2(binary_mask, conv_kernel, 'same'); % First pass
    neighbors_count_twice = conv2(neighbors_count, conv_kernel, 'same'); % Second pass

    % Find indices where the count of neighbors is exactly 2
    [~, isolated_indices] = find(neighbors_count_twice == 2);

    %% Step 3: Update the matrix to mark isolated values
    % Set the columns corresponding to isolated indices to -999
    vel(:, isolated_indices) = -999;

    %% Step 4: Replace columns marked as -999 in the first row with NaN
    updated_first_row = vel(1, :);
    nan_mask = updated_first_row == -999; % Identify columns with -999
    vel(:, nan_mask) = NaN; % Set the entire column to NaN

end
