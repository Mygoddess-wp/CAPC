function principal_curve = RiemannianPrincipalCurve(data, T, sigma, max_iter,hasWeight)
    [~,D, N] = size(data); 
    old_sigma=sigma;
    assert(D == 3, 'Data must be 3D for the SO3.');
    sample_number = 1;
    dataindex=repmat([1:N/sample_number],1,sample_number);

    principal_curve = initialize_curve(data, T,sample_number); % 3D tensor
    cost=0;
    for iter = 1:max_iter
        prev_curve = principal_curve;
        
        distances = zeros(N, T);
            for t = 1:T
                distances(:, t)=SO3_dists(principal_curve(:, :,t),data);
            end
        weights = zeros(N, T);
        for t1=1:T
            
                distancesT(t1, :) = SO3_dists(principal_curve(:,:, t1), principal_curve);
    
        end
        timeindex=ceil((1/T+0.5):N/T:N);
        timeindex=[timeindex timeindex(end:-1:1)];
        for t = 1:T
            [~, nearest_idx] = min(distances');
            delta_dist = distancesT(nearest_idx, t) / sigma;
            if hasWeight == 1
                delta_dist=delta_dist.*(abs(timeindex(t)-dataindex))';
            end
            
            tempcost(t)=mean(delta_dist);
            weights(:, t) = quartic_kernel(delta_dist);
        end
        cost(iter)=mean(tempcost);
        if sum(weights(:))<0.001
           sigma=sigma+0.001;
           continue;
        end
        for t = 1:T
            principal_curve(:,:, t) = update_curve_point(data, weights(:, t));
        end
        sigma=old_sigma;
        % 检查收敛性
        if norm(sum(principal_curve - prev_curve,3), 'fro') < 1e-4
            break;
        end
    end
end

function new_point = update_curve_point(data, weights)
    new_point=RiemannianMean(data,weights,5800, 1e-5);

end




function curve = initialize_curve(data, T,sample_number)
    [~,D, N] = size(data);
    index=randi([1 N],1,T);
    seq=mod(index,N/sample_number);
    [B,I]=sort(seq);
    index=index(I);
    curve=data(:,:,index);
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
    s = sum(k);
    if s > 0
        k = k / s;
    else
        k = zeros(size(k));
    end
end

function k = psis(delta)
sigma = 1;
    k = (1 - (delta/sigma).^2) .* exp(-(delta/sigma).^2 / 2) .* (abs(delta) <= 1);
end