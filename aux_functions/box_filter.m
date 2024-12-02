function [vv, dbzz] = box_filter(vv, dbzz)
    %% BOX_FILTER
    % This function applies a 3x3 box filter to the velocity (`vv`) and reflectivity (`dbzz`) matrices.
    % Values are filtered based on a threshold of neighbors, and invalid points are updated.
    %
    % Inputs:
    %   - vv: Velocity matrix
    %   - dbzz: Reflectivity matrix
    %
    % Outputs:
    %   - vv: Filtered velocity matrix with invalid points set to 0
    %   - dbzz: Filtered reflectivity matrix with invalid points set to -20

    %% Step 1: Preprocess the velocity matrix
    % Mark invalid values (<= -990) as NaN
    testcase = vv;
    testcase(testcase <= -990) = NaN;

    % Create a binary mask: 1 for valid values, 0 for NaNs
    testcase(~isnan(testcase)) = 1; % Mark valid values as 1
    testcase(isnan(testcase)) = 0; % Mark NaN values as 0

    %% Step 2: Apply convolution to count neighbors
    % Define a 3x3 convolution kernel
    conv_kernel = ones(3); % Includes the center point
    neighbor_count = conv2(testcase, conv_kernel, 'same'); % Count neighbors for each cell

    %% Step 3: Filter based on neighbor count
    % Mark points with <= 5 neighbors as invalid (0)
    % Mark points with > 3 neighbors as valid (1)
    live_mask = neighbor_count;
    live_mask(live_mask <= 5) = 0; % Invalid points
    live_mask(live_mask > 3) = 1; % Valid points

    %% Step 4: Update `vv` and `dbzz` based on the filter
    vv(~live_mask) = 0;    % Set invalid velocity points to 0
    dbzz(~live_mask) = -20; % Set invalid reflectivity points to -20

end
