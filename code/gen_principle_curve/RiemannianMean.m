function mu = RiemannianMean(points,W, max_iter, tol)
    mu = mean(points, 1); 
    for iter = 1:max_iter
        tangent_vectors = zeros(size(points));
        for i = 1:size(points, 1)
            tangent_vectors(i, :) = Log(mu, points(i, :));
        end
         W= W / norm(W);
       tangent_mean= sqrt(W)'*tangent_vectors/length(W);
        new_mu = Exp(mu, tangent_mean);
        if norm(new_mu - mu) < tol
            fprintf('Converged in %d iterations.\n', iter);
            mu = new_mu;
            return;
        end
        mu = new_mu;
    end
    
    warning('Maximum iterations reached without convergence.');
end

function tangent_vector = Log(mu, x)
    x1 = mu(1); y1 = mu(2);
    x2 = x(1); y2 = x(2);
    if y1 <= 0 || y2 <= 0
        error('Coordinates must be in the Poincar¨¦ half-plane with y > 0.');
    end
    dist = acosh(1 + ((x2 - x1)^2 + (y2 - y1)^2) / (y1 * y2) - (1 - (x2 - x1)^2 / (y1 * y2)) / (y1 * y2));
    tangent_vector = [(x2 - x1) / dist, (y2 - y1) / dist] * dist;
end

function exp_map = Exp(mu, tangent_vector)
    x1 = mu(1); y1 = mu(2);
    v1 = tangent_vector(1); v2 = tangent_vector(2);
    exp_map = mu + [v1 * y1, v2 * y1];
    if exp_map(2) <= 0
        error('Resulting point must have y > 0.');
    end
end
