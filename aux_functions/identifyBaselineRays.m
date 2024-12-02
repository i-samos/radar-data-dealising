function [ray_ranking_matrix, horay_ranking_matrix] = identifyBaselineRays(vel)
    %% IDENTIFYBASELINERAYS
    % This function analyzes the velocity (`vel`) matrix to rank "rays" and "horays"
    % based on their transitions, valid data points, and longest streaks of non-NaN values.
    %
    % Inputs:
    %   - vel: A 2D matrix of velocities (rays as rows, horays as columns).
    %
    % Outputs:
    %   - ray_ranking_matrix: Ranking of rays based on minimal transitions,
    %                         maximum valid points, and longest streaks.
    %   - horay_ranking_matrix: Ranking of horays based on the same criteria.

    [numRays, numAngles] = size(vel);

    %% Initialize arrays for ray metrics
    transition_counts_rays = zeros(numRays, 1); % Count of transitions per ray
    valid_point_counts_rays = zeros(numRays, 1); % Count of valid (non-NaN) points per ray
    longest_streak_rays = zeros(numRays, 1); % Longest streak of consecutive valid points per ray

    %% Calculate metrics for each ray (row in `vel`)
    for i = 1:numRays
        % Extract valid (non-NaN) values for the current ray
        valid_values = vel(i, ~isnan(vel(i, :)));
        valid_point_counts_rays(i) = numel(valid_values); % Count valid points
        
        % Calculate the number of transitions (differences > 2)
        if valid_point_counts_rays(i) > 1
            diffs = abs(diff(valid_values));
            transition_counts_rays(i) = sum(diffs > 2);
        else
            transition_counts_rays(i) = Inf; % Assign Inf if not enough valid points
        end
        
        % Calculate the longest streak of consecutive valid points
        isnan_vector = isnan(vel(i, :));
        streaks = diff([0, find(isnan_vector), numAngles+1]) - 1; % Streak lengths
        longest_streak_rays(i) = max(streaks);
    end

    %% Rank rays based on the metrics
    [~, ray_rank] = sortrows([transition_counts_rays, -valid_point_counts_rays, -longest_streak_rays]);
    ray_ranking_matrix = [ray_rank, valid_point_counts_rays(ray_rank), longest_streak_rays(ray_rank)];
    
    % Sort by longest streak, valid points, and minimal transitions
    ray_ranking_matrix = sortrows(ray_ranking_matrix, [-3, 2, 1]);

    %% Initialize arrays for horay metrics
    transition_counts_horays = zeros(numAngles, 1); % Count of transitions per horay
    valid_point_counts_horays = zeros(numAngles, 1); % Count of valid (non-NaN) points per horay
    longest_streak_horays = zeros(numAngles, 1); % Longest streak of consecutive valid points per horay

    %% Calculate metrics for each horay (column in `vel`)
    for j = 1:numAngles
        % Extract valid (non-NaN) values for the current horay
        valid_values = vel(~isnan(vel(:, j)), j);
        valid_point_counts_horays(j) = numel(valid_values); % Count valid points
        
        % Calculate the number of transitions (differences > 2)
        if valid_point_counts_horays(j) > 1
            diffs = abs(diff(valid_values));
            transition_counts_horays(j) = sum(diffs > 2);
        else
            transition_counts_horays(j) = Inf; % Assign Inf if not enough valid points
        end
        
        % Calculate the longest streak of consecutive valid points
        isnan_vector = isnan(vel(:, j));
        streaks = diff([0; find(isnan_vector); numRays+1]) - 1; % Streak lengths
        longest_streak_horays(j) = max(streaks);
    end

    %% Rank horays based on the metrics
    [~, horay_rank] = sortrows([transition_counts_horays, -valid_point_counts_horays, -longest_streak_horays]);
    horay_ranking_matrix = [horay_rank, valid_point_counts_horays(horay_rank), longest_streak_horays(horay_rank)];
    
    % Sort by longest streak, valid points, and minimal transitions
    horay_ranking_matrix = sortrows(horay_ranking_matrix, [-3, 2, 1]);

end
