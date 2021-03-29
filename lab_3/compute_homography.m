function H = compute_homography(A_matrix)
    % Perform SVD on the A matrix
    [~, ~, v] = svd(A_matrix);
    % The last column of v is the solution for h
    h = v(:, end);
    % reshape h appropriately to get the (3,3) H matrix
    H = reshape(h, 3, 3)';
end