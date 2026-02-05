function [principal_curve,weights] = RiemannianPrincipalCurve(data, T, sigma, max_iter, hasWeight)
    [D, N] = size(data); 
    assert(D == 2, 'Data must be 2D for the Poincare half-plane.');
    principal_curve = initialize_curve(data, T); % 3D tensor
    
    for iter = 1:max_iter
        prev_curve = principal_curve;
        distances = zeros(N, T);
        for n = 1:N
            for t = 1:T
                distances(n, t) = poincare_dist(principal_curve(:, t)', data(:, n)');
            end
        end
        weights = zeros(N, T);
        for t1=1:T
            for t2=1:T
                distancesT(t1, t2) = poincare_dist(principal_curve(:, t1), principal_curve(:, t2));
            end
        end
        for t = 1:T
            [~, nearest_idx] = min(distances');
            timeindex=(6/T-3):12/T:3;
            timeindex=[timeindex timeindex(end:-1:1)];
            delta_dist = distancesT(nearest_idx, t) / sigma;
            

            if hasWeight == 1
                delta_dist=delta_dist.*(abs(timeindex(t)-data(1, :)))';
            end

            weights(:, t) = quartic_kernel(delta_dist);
        end
        for t = 1:T
            principal_curve(:, t) = update_curve_point(data, weights(:, t))';
        end
        if norm(principal_curve - prev_curve, 'fro') < 1e-6

            break;
        end
    end
end

function new_point = update_curve_point(data, weights)
 
    new_point=RiemannianMean(data',weights,100, 1e-6);

end




 function curve = initialize_curve(data, T)
    [~, N] = size(data);
    index=randi([1 N],1,T);
    curve=data(:,index);
    curve=curve+rand(size(curve));

 end
% Poincaré 距离计算
function dist = poincare_dist(p1, p2)
    x1 = p1(1); y1 = p1(2);
    x2 = p2(1); y2 = p2(2);
    numerator = (x2 - x1).^2 + (y2 - y1).^2;
    denominator = 2 * y1 .* y2;
    cosh_dist = 1 + numerator ./ denominator;
    dist = acosh(cosh_dist);
end

% 四次核函数
function k = quartic_kernel(delta)
    k = (1 - delta.^2).^2 .* (abs(delta) <= 1);
end

function k = psis(delta)
sigma = 1;
    k = (1 - (delta/sigma).^2) .* exp(-(delta/sigma).^2 / 2) .* (abs(delta) <= 1);
end