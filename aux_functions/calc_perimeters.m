function [perimeterValues, outerValues, outerIndices] = calc_perimeters(data, vel, resultMatrix, limit)
    %% CALC_PERIMETERS
    % This function calculates the average values around the perimeter pixels
    % of a matrix based on a 3x3 neighborhood and adjusts the outer perimeter
    % values in `vel` based on a specified limit.
    %
    % Inputs:
    %   - data: Input matrix containing data for calculating averages
    %   - vel: Matrix containing velocity data to be adjusted
    %   - resultMatrix: Logical matrix identifying the outer perimeter
    %   - limit: Threshold for adjusting the outer values in `vel`
    %
    % Outputs:
    %   - perimeterValues: Averaged 3x3 neighborhood values around the perimeter
    %   - outerValues: Adjusted values of `vel` at the perimeter
    %   - outerIndices: Linear indices of the outer perimeter in `resultMatrix`

    %% Step 1: Initialize and calculate indices
    [numRows, numCols] = size(data); % Get the size of the data matrix
    outerIndices = find(resultMatrix); % Get linear indices of the outer perimeter pixels

    % Initialize the perimeter values array
    perimeterValues = zeros(size(outerIndices));

    %% Step 2: Calculate 3x3 box averages for perimeter pixels
    for i = 1:length(outerIndices)
        % Get the linear index of the current perimeter pixel
        idx = outerIndices(i);

        % Convert the linear index to row and column indices
        [row, col] = ind2sub([numRows, numCols], idx);

        % Define the row and column range for the 3x3 neighborhood
        rowRange = max(1, row-1):min(numRows, row+1);
        colRange = max(1, col-1):min(numCols, col+1);

        % Extract the 3x3 box values and calculate the average, ignoring NaNs
        boxValues = data(rowRange, colRange);
        perimeterValues(i) = nanmean(boxValues(:)); % Average non-NaN values
    end

    %% Step 3: Extract outer perimeter values from `vel`
    outerValues = vel(outerIndices);

    %% Step 4: Adjust outer values based on the difference from perimeter averages
    % Adjust values where the difference exceeds the positive threshold
    exceed_positive = (perimeterValues - outerValues) > 1.0 * limit;
    outerValues(exceed_positive) = outerValues(exceed_positive) + 2 * limit;

    % Adjust values where the difference exceeds the negative threshold
    exceed_negative = (perimeterValues - outerValues) < -1.0 * limit;
    outerValues(exceed_negative) = outerValues(exceed_negative) - 2 * limit;

end
