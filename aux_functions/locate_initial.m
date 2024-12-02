function vel_new = locate_initial(vel, vel_new, limit)
    %% LOCATE_INITIAL
    % Adjusts the `vel_new` matrix based on its proximity to three test cases
    % derived from the `vel` matrix. The closest test case is selected for
    % each element in `vel_new`.
    %
    % Inputs:
    %   - vel: Original velocity matrix
    %   - vel_new: Simulated velocity matrix to be adjusted
    %   - limit: Nyquist velocity limit for creating test cases
    %
    % Output:
    %   - vel_new: Adjusted velocity matrix

    % Generate test cases based on `vel` and `limit`
    test_case1 = vel;                 % Original velocity
    test_case2 = vel + 2 * limit;     % Positive alias adjustment
    test_case3 = vel - 2 * limit;     % Negative alias adjustment

    % Compute absolute differences between simulation and test cases
    diff_case1 = abs(vel_new - test_case1);
    diff_case2 = abs(vel_new - test_case2);
    diff_case3 = abs(vel_new - test_case3);

    % Stack differences into a 3D matrix for comparison
    all_differences = cat(3, diff_case1, diff_case2, diff_case3);

    % Find the index of the test case with the minimum difference
    [~, min_diff_index] = min(all_differences, [], 3);

    % Initialize the adjusted velocity matrix
    adjusted_vel_new = vel_new; % Copy the initial matrix for updates

    % Update `adjusted_vel_new` based on the minimum difference index
    for row = 1:size(vel_new, 1)
        for col = 1:size(vel_new, 2)
            switch min_diff_index(row, col)
                case 1
                    adjusted_vel_new(row, col) = test_case1(row, col); % Closest to `test_case1`
                case 2
                    adjusted_vel_new(row, col) = test_case2(row, col); % Closest to `test_case2`
                case 3
                    adjusted_vel_new(row, col) = test_case3(row, col); % Closest to `test_case3`
            end
        end
    end

    % Output the adjusted velocity matrix
    vel_new = adjusted_vel_new;

end
