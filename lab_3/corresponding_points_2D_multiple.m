function corresponding_points = corresponding_points_2D_multiple(H, points)
    % points is of the shape (n,2) with points(i,:) = [x(i), y(i)]
    % points is not in homogenous coordinates
    n_points = length(points);
    % add a row of 1s to bring points to homogenous coordinates
    % homogenous_points(i, :) = [x(i), y(i), 1]
    homogenous_points = [points, ones(n_points, 1)];
    homogenous_points_prime = homogenous_points*H';
    % Multiply with the H matrix and perform element wise division
    % corresponding_points (i, :) = homogenous_points_prime(i,
    % 1:2)/homogenous_points_prime(i, 3)
    corresponding_points = homogenous_points_prime(:, 1:2)./homogenous_points_prime(:, 3);
end