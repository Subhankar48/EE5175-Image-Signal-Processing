function [x_, y_] = corresponding_points_2D(H, x)
    % x is of the form [x1, y1, 1], i.e., in homogenous coordinates.
    %  H is the homography matrix 
    x_prime = H*x;
    if x_prime(end) ~= 0
        % return in non homogenous coordinates
        x_prime = x_prime(1:end-1)./x_prime(end);
    else
        % Homognous coordinates of the form [a, b, c] can be  
        % converted to non homogenous only if c!=0. In case that condition is
        % violated, we set the non homogenous coordinates to (0,0) even though
        % in reality such a point does not have a finite representation in
        % non homogenous coordinates
        x_prime = [0;0];
    end
    x_ = x_prime(1);
    y_ = x_prime(2);
end