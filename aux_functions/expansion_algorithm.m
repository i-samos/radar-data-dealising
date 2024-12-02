function data = expansion_algorithm(vel_new3, vel, dbz, limit, interactive)
    %% EXPANSION_ALGORITHM
    % This function performs iterative expansion of valid velocity values into
    % surrounding NaN regions, using labeled regions and perimeter-based updates.
    %
    % Inputs:
    %   - vel_new3: Initial velocity matrix for expansion
    %   - vel: Original velocity matrix
    %   - dbz: Reflectivity matrix
    %   - limit: Threshold for velocity corrections
    %   - interactive: Flag for interactive visualization
    %
    % Output:
    %   - data: Expanded velocity matrix after iterative processing

    %% Step 1: Preprocess velocity data
    data = vel_new3; % Initialize data for expansion
    [~, numCols] = size(data);

    % Apply initial smoothing and filtering
    [data, ~] = speed(data, dbz); % Use `speed` filter
    data(data == 300) = NaN; % Mark invalid points as NaN

    % Extend matrix for convolution handling
    data(isnan(data)) = -999; % Temporary marker for NaNs
    data = [data, data, data]; % Extend horizontally
    data(data == -999) = NaN; % Restore NaNs
    data = data(:, numCols + 1:end - numCols); % Trim to original size

    %% Step 2: Identify largest labeled region
    labeled_regions = bwlabel(~isnan(data), 8); % Label connected regions
    [~, region_value] = find_best_shift(data, labeled_regions); % Find largest region
    labeled_regions(labeled_regions ~= region_value) = NaN; % Keep only the largest region

    % Create a mask for the identified region
    valid_region_mask = ~isnan(labeled_regions);
    data(~valid_region_mask) = NaN; % Mask out invalid regions

    %% Step 3: Iterative expansion
    if interactive == 1
        figure; maximize;
    end

    outerPerimeterMaskOld = []; % Track the previous perimeter mask
    running = true; % Iteration control
    iteration = 1; % Iteration counter

    while running
        % Calculate the initial cost (sum of non-NaN values)
        cost_initial = nansum(data(:));

        % Identify perimeter and outer perimeter masks
        nonNaNIndices = ~isnan(data);
        kernel = [1, 1, 1; 1, 0, 1; 1, 1, 1]; % Convolution kernel
        perimeterMask = nonNaNIndices & (conv2(double(isnan(data)), kernel, 'same') > 0);
        outerPerimeterMask = isnan(data) & (conv2(double(perimeterMask), kernel, 'same') > 0);

        % Exclude repeated elements from the outer perimeter
        if ~isempty(outerPerimeterMaskOld)
            matchingElements = outerPerimeterMask & outerPerimeterMaskOld;
            resultMatrix = outerPerimeterMask;
            resultMatrix(matchingElements) = false;
        else
            resultMatrix = outerPerimeterMask;
        end

        % Calculate perimeter and outer values
        [~, outerValues, outerIndices] = calc_perimeters(data, vel, resultMatrix, limit);

        % Update the data matrix with outer values
        data(outerIndices) = outerValues;

        % Visualize progress if interactive mode is enabled
        if interactive == 1
            pcolor(data);
            shading flat;
            axis square;
            caxis([-limit, limit]);
            drawnow;
        end

        % Check for convergence
        cost = nansum(data(:));
        if cost == cost_initial
            running = false; % Stop if no changes occur
        end

        % Update the previous perimeter mask
        outerPerimeterMaskOld = outerPerimeterMask;
        iteration = iteration + 1;
    end
end
