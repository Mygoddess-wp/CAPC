function mean_R = computeSO3Mean(R_matrices, max_iter, alpha, tol)

    N = length(R_matrices);

    mean_R = R_matrices{1};
    
    for iter = 1:max_iter
        gradient = zeros(3, 3);
        for i = 1:N
            R = R_matrices{i};
            R_rel = relativeRotation(mean_R, R);
            w = logSO3(R_rel);
            gradient = gradient + expSO3(w) - eye(3);
        end
        gradient = (1 / N) * gradient;

        mean_R = mean_R * expSO3(alpha * gradient);
        

        if norm(gradient, 'fro') < tol
            break;
        end
    end
end

function R12 = relativeRotation(R1, R2)
    R12 = R2 * R1';
end

function w = logSO3(R)
    theta = acos((trace(R) - 1) / 2);
    if theta == 0
        w = [0; 0; 0];
    else
        w = theta / (2 * sin(theta)) * [R(3, 2) - R(2, 3); R(1, 3) - R(3, 1); R(2, 1) - R(1, 2)];
    end
end

function R = expSO3(w)
    theta = norm(w);
    if theta == 0
        R = eye(3);
    else
        w_hat = [0, -w(3), w(2); w(3), 0, -w(1); -w(2), w(1), 0];
        R = eye(3) + (sin(theta) / theta) * w_hat + ((1 - cos(theta)) / (theta^2)) * (w_hat * w_hat);
    end
end
