function [principal_curve,allweights,initialize_indice] = RiemannianPrincipalCurve_WeightShare(data, T, sigma, max_iter, subject_sets,hasWeight)
    [~,D, N,J] = size(data);
    old_sigma=sigma;
    assert(D == 3, 'Data must be 3D for the SO3.');
    [principal_curve, initialize_indice] = initialize_curve(data, T, subject_sets); % 3D tensor
    initialize_indice = [];
    cost=0;
    tag_updata = 0;
    for iter = 1:max_iter
        prev_curve = principal_curve;
        distances = zeros(N, T);
        for joint=1:J
            for t = 1:T
                distances(:, t,joint)=SO3_dists(principal_curve(:, :,t,joint),data(:,:,:,joint));
            end
        end
        weights = zeros(N, T);
        for joint=1:J
        for t1=1:T
           distancesT(t1, :,joint) = SO3_dists(principal_curve(:,:, t1,joint), principal_curve(:,:,:,joint));
        end
        end
        use_sample_number = length(subject_sets);
        timeindex= (1-0.05:T-0.05) * ((N/use_sample_number)/T);
        dataindex = repmat(1: N/use_sample_number,1,use_sample_number);
        for t = 1:T
            sdistances=sum(distances,3);
            sdistancesT=sum(distancesT,3);
            [~, nearest_idx] = min(sdistances');

            delta_dist = sdistancesT(nearest_idx, t) / sigma;
            if hasWeight == 1
                delta_dist=delta_dist.*(abs(timeindex(t)-dataindex))';
            end
            tempcost(t)=mean(delta_dist);
            weights(:, t) = quartic_kernel(delta_dist);
        end
        cost(iter)=mean(tempcost);
        if sum(weights(:))<0.01
           sigma=sigma+0.01;
           continue;
        end
        
        for joint=1:J
            for t = 1:T
                principal_curve(:,:, t,joint) = update_curve_point(data(:,:,:,joint), weights(:, t));
            end
        end
        tag_updata = tag_updata + 1;
        allweights(:,:,tag_updata) = weights;
        sigma=old_sigma;

        for joint=1:J
            convergences(joint)= norm(sum(principal_curve(:,:,:,joint) - prev_curve(:,:,:,joint),3), 'fro') ;
            sum_conv=sum(convergences<1e-4);

        end
        if sum_conv==19
            break;
        end
    end
end


function new_point = update_curve_point(data, weights)
    new_point=RiemannianMean(data,weights,200, 1e-5);
end




function [curve,index] = initialize_curve(data, T, subject_sets)
    [~,D, N,J] = size(data);
    oneSubjectFrames = N/length(subject_sets);
    maxNumber_subjectValue = mode(subject_sets);
    maxNumber_subject_idxSets= find(subject_sets == maxNumber_subjectValue);
    all_subject_idxs = [];

    for i=1:1
        subject_idxs = (maxNumber_subject_idxSets(i) - 1) * oneSubjectFrames + 1 :  maxNumber_subject_idxSets(i) * oneSubjectFrames;
        all_subject_idxs = [all_subject_idxs subject_idxs];
    end

    len = length(all_subject_idxs);
    
    index=randi([1,len],1,T);
    index = all_subject_idxs(index);

    
    seq = mod(index - 1, oneSubjectFrames) + 1;

    [B,I]=sort(seq);
    index=index(I);
    for i=1:J
        curve(:,:,:,i)=data(:,:,index,i);
    end

end




 function curve = initialize_curve_PGA(data, N_new)
    [~,~, ~,J] = size(data);
    for i=1:J
        curve(:,:,:,i)=generate_SO3_with_geodesics(data(:,:,:,i),N_new);
    end
 end
 
 
function new_ori = generate_SO3_with_geodesics(ori, N_new)

    [eV, ~, ~,oriRef] = PGA(ori);
    R_pos = oriRef * exp_SO3(eV(:, 1)); 
    R_neg = oriRef * exp_SO3(-eV(:, 1));

    theta = acos((trace(R_pos' * R_neg) - 1) / 2);
    v = (1 / (2 * sin(theta))) * ...
        [R_neg(3, 2) - R_neg(2, 3);
         R_neg(1, 3) - R_neg(3, 1);
         R_neg(2, 1) - R_neg(1, 2)];
    new_ori = zeros(3, 3, N_new);
    for i = 1:N_new
        t = i / (N_new + 1); 
        omega = t * theta * v; 
        new_ori(:, :, i) = R_pos * exp_SO3(omega); 
    end

    for i = 1:N_new
        new_ori(:, :, i) = normalize_SO3(new_ori(:, :, i));
    end
end

function R = exp_SO3(omega)

    theta = norm(omega);
    if theta < 1e-10
        R = eye(3);
    else
        axis = omega / theta;
        K = skew(axis);
        R = eye(3) + sin(theta) * K + (1 - cos(theta)) * (K * K); 
    end
end

function S = skew(v)
    S = [0 -v(3) v(2);
         v(3) 0 -v(1);
         -v(2) v(1) 0];
end

function R = normalize_SO3(R)
    [U, ~, V] = svd(R);
    R = U * V';
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