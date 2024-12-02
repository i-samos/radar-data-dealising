function outputMatrix = cellToMatrix(cellArray)
    % Convert cell array to matrix
    % If cell is empty, assign 100000 as the default value

    % Initialize output matrix with NaNs, using the same size as cellArray
    outputMatrix = nan(size(cellArray));

    % Loop through each element in the cell array
    for i = 1:numel(cellArray)
        if isempty(cellArray{i})
            % Assign 100000 if the cell is empty
            outputMatrix(i) = nan;
        else
            % Otherwise, assign the cell's value
            outputMatrix(i) = cellArray{i};
        end
    end
end
