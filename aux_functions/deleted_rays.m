function vel_del = deleted_rays(vel, vel_original)
    %% DELETED_RAYS
    % This function creates a matrix `vel_del` by marking all valid (non-NaN)
    % values in `vel_original` as NaN, where corresponding entries in `vel` are non-NaN.
    %
    % Inputs:
    %   - vel: A matrix with current velocity data (may include NaNs).
    %   - vel_original: The original velocity matrix to be updated based on `vel`.
    %
    % Output:
    %   - vel_del: Updated velocity matrix where non-NaN values in `vel_original`
    %              are set to NaN wherever `vel` has non-NaN values.

    %% Step 1: Initialize the output matrix with the original velocities
    vel_del = vel_original; % Start with the original velocity matrix

    %% Step 2: Identify NaN entries in `vel`
    nan_mask = isnan(vel); % Create a logical mask where `vel` has NaNs

    %% Step 3: Update `vel_del` to set non-NaN values to NaN based on `nan_mask`
    vel_del(~nan_mask) = NaN; % Set all non-NaN entries in `vel_del` to NaN

end
