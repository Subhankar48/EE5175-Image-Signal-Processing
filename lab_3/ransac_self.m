function H = ransac_self(points, corresponding_points, epsilon, fraction, n_samples, n_iters)
    % number of points
    n_points = length(points);
    % square now so that we do not have to take square root again and again
    epsilon = epsilon^2;
    % d as defined in the assignment PDF
    d = ceil(fraction*n_points);
    
    % Get the set of 4 points, their correspondence points, and the
    % remaining points and correspondence points
    [pts, corres_pts, rem_pts, rem_corres_pts] = n_rows_sampler(points, corresponding_points, n_samples);
    % Build the A matrix
    A = A_matrix(pts, corres_pts);
    % Compute H from A
    % Initialize the value of H
    H = compute_homography(A);
    
    % Estimate corresponding points using the remaining points (those not
    % used in the calculation of H) and the H estimated
    rem_pts_prime = corresponding_points_2D_multiple(H, rem_pts);
    % Take the squared difference and sum to get the squared errors
    squared_difference = (rem_pts_prime - rem_corres_pts).^2;
    % sum_sq_diff(i) = (x'(i) - x'''(i))^2 + (y'(i) - y'''(i))^2 
    % where x' and x''' are the notation as used in lecture 14
    sum_sq_diff = sum(squared_difference, 2);
    % Consensus set is a logical array with 1 where the sum squared
    % difference is less than epsilon^2
    consensus_set = sum_sq_diff<epsilon;
    % Get the number of elements in the consensus set
    % Initiate the n_consensus set variable
    n_consensus = sum(consensus_set);
    if n_consensus>=d
        % If the condition is met, get all the inlier and outlier points
        % using the consensus set and recompute H using all the inliers
        inlier_pts = points(consensus_set, :);
        inlier_corres_pts = corresponding_points(consensus_set, :);
        A = A_matrix(inlier_pts, inlier_corres_pts);
        H = compute_homography(A);
        % Escape from the function
        return;
    end

    % Go into this for loop only if the first calculated H is not
    % satisfactory
    for nth_iter = 1:n_iters
        % Same set of steps as that in the first computation of H
        [pts, corres_pts, rem_pts, rem_corres_pts] = n_rows_sampler(points, corresponding_points, n_samples);
        A = A_matrix(pts, corres_pts);
        H_ = compute_homography(A);

        rem_pts_prime = corresponding_points_2D_multiple(H_, rem_pts);
        squared_difference = (rem_pts_prime - rem_corres_pts).^2;
        sum_sq_diff = sum(squared_difference, 2);
        consensus_set_ = sum_sq_diff<epsilon;
        n_consensus_ = sum(consensus_set_);
        
        if n_consensus_>=n_consensus
            % If you get a better consensus set, update the consensus set
            % as well as the value of H
            n_consensus = n_consensus_;
            consensus_set = consensus_set_;
            H = H_;
        end
        
        if n_consensus>=d
            % Whenever we have a consensus set as large as we require,
            % recompute H using all the inliers
            inlier_pts = points(consensus_set, :);
            inlier_corres_pts = corresponding_points(consensus_set, :);
            A = A_matrix(inlier_pts, inlier_corres_pts);
            H = compute_homography(A);
            % And break from the for loop
            break;
        end
    end
    
    % If you cannot meet the consensus set, take the case where you got the
    % maximum size of the consensus set and recompute H using all the
    % inliers
    if nth_iter == n_iters
        inlier_pts = points(consensus_set, :);
        inlier_corres_pts = corresponding_points(consensus_set, :);
        A = A_matrix(inlier_pts, inlier_corres_pts);
        H = compute_homography(A);
    end
end