function [vel, dbz] = speed(vel, dbz)
%% SPEED FILTER
% This function filters the velocity (vel) and reflectivity (dbz) data
% based on certain conditions using convolution and logical operations.

% Create a test matrix for positive velocities
velocity_matrix = vel;
velocity_matrix = [velocity_matrix(:, end), velocity_matrix, velocity_matrix(:, 1)]; % Add wrap-around columns
velocity_matrix(velocity_matrix > 0) = 1; % Mark positive values as 1
velocity_matrix(velocity_matrix <= 0) = 0; % Mark non-positive values as 0
velocity_matrix(isnan(velocity_matrix)) = 0; % Treat NaNs as 0

% Define a convolution kernel and apply it to find neighboring positives
conv_kernel = ones(3); 
conv_kernel(2, 2) = 0; % Exclude the center
positive_neighbors = conv2(velocity_matrix, conv_kernel, 'same'); % Count positive neighbors
positive_neighbors(positive_neighbors < 8) = 0; % Threshold: less than 8 neighbors is invalid
positive_neighbors(positive_neighbors > 7) = 1; % Threshold: exactly 8 neighbors is valid
positive_neighbors(:, [1, end]) = []; % Remove wrap-around columns

positive_filter = positive_neighbors; % Store the filter for positive velocities

% Create a test matrix for negative velocities
velocity_matrix = vel;
velocity_matrix = [velocity_matrix(:, end), velocity_matrix, velocity_matrix(:, 1)]; % Add wrap-around columns
velocity_matrix(velocity_matrix >= 0) = 0; % Mark non-negative values as 0
velocity_matrix(velocity_matrix < 0) = 1; % Mark negative values as 1
velocity_matrix(isnan(velocity_matrix)) = 0; % Treat NaNs as 0

% Apply convolution to find neighboring negatives
negative_neighbors = conv2(velocity_matrix, conv_kernel, 'same'); % Count negative neighbors
negative_neighbors(negative_neighbors < 8) = 0; % Threshold: less than 8 neighbors is invalid
negative_neighbors(negative_neighbors > 7) = 1; % Threshold: exactly 8 neighbors is valid
negative_neighbors(:, [1, end]) = []; % Remove wrap-around columns

negative_filter = negative_neighbors; % Store the filter for negative velocities

% Combine the positive and negative filters
combined_filter = positive_filter + negative_filter;

% Mask invalid velocities and reflectivity values
vel(~combined_filter) = 300; % Set invalid velocity to 300
dbz(~combined_filter) = 300; % Set invalid reflectivity to 300

% Additional filtering for negative velocities
negative_mask = vel;
negative_mask(negative_mask > -200) = 1; % Allow only values ≤ -200
negative_mask(negative_mask == 0) = 1; % Convert zero to 1
negative_mask(negative_mask < 0) = 0; % Mark values < 0 as invalid
negative_mask(isnan(negative_mask)) = 0; % Treat NaNs as 0

vel(~negative_mask) = 300; % Mask additional invalid velocities
dbz(~negative_mask) = 300; % Mask corresponding reflectivity values

end