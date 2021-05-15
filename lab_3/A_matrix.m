function A = A_matrix(points, corresponding_points)
    % Get the number of point correspondences
    n_correspondances = length(points);
    % Build a matrix of the size (2n, 9)
    A = zeros(2*n_correspondances, 9);
    for i = 1:n_correspondances
        x = points(i, 1);
        y = points(i, 2);
        x_prime = corresponding_points(i, 1);
        y_prime = corresponding_points(i, 2);
        % Fill the rows of A with the appropriate values
        A(2*i-1, :) = [-x -y -1  0  0  0 x*x_prime y*x_prime x_prime];
        A(2*i, :)   = [ 0  0  0 -x -y -1 x*y_prime y*y_prime y_prime];
    end
end