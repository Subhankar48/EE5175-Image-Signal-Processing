    function [pts, corres_pts, remaining_pts, remaining_corres_pts] = n_rows_sampler(sift_points, corresponding_sift_points, n_samples)
    % Get the number of points
    n_points = length(sift_points);
    % Get all the indices
    all_indices = 1:n_points;
    % sample n_samples indices from all the indices
    sample_indices = randperm(n_points, n_samples);
    % Get the points and corresponding points for those indices
    pts = sift_points(sample_indices, :);
    corres_pts = corresponding_sift_points(sample_indices, :);
    % Get the remaining indices using set differentiation
    % For example, if all_indices is [1, 2, 3, 4, 5] and 
    % sample_indices is [1,3], setdiff(all_indices, sample_indices);
    % gives [2, 5, 5]
    remaining_indices = setdiff(all_indices, sample_indices);
    % return the remaining points too to for the consensus set
    remaining_pts = sift_points(remaining_indices, :);
    remaining_corres_pts = corresponding_sift_points(remaining_indices, :);
end