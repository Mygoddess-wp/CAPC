function mu = RiemannianMean(points,W, max_iter, tol)
    sum(W);
    [~,D,N]=size(points);
    WW=W';
    mu = mean(points(:,:,W~=0), 3);
    if sum(W~=0)==0
        mu = mean(points(:,:,:), 3);
    end
    mu=mu/sqrtm(mu'*mu);
    for iter = 1:max_iter
        tangent_vectors = zeros(size(points));
        tangent_vectors=Log(mu, points);
         WW=W';
        WW=kron(WW,ones(3));
        meanss=WW.*tangent_vectors;
         meanss=reshape(meanss,[D,D,N]);
       tangent_mean= mean(meanss,3);
        new_mu = Exp(mu, tangent_mean);
        if isnan(  new_mu)
            fprintf('Wrong in %d iterations.\n', iter);
        end
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

  [~,D,N]=size(x);
  x1=reshape(x,[D,D*N]);

  tempA=mu'*x1;
  tra=repmat(eye(D), 1, N).*tempA;
  tra=sum(tra);
  group_sums = sum(reshape(tra, D, []), 1);
  costhetas=(group_sums-1)/2;
  for i=1:length(costhetas)
    costheta=costhetas(i);
    if (costheta>=1)
        tv=zeros(3);
        tv=mu* tv;
    else
        theta=acos(costheta);
        tv=sin(theta)/2/sin(theta)*(tempA(:,((i-1)*D+1):((i-1)*D+3))-tempA(:,((i-1)*D+1):((i-1)*D+3))');
        tv=mu*tv;
    end
    if i==1
        tangent_vector=tv;
    else
        
    tangent_vector=[tangent_vector tv];
    end
  end

  
end

function exp_map = Exp(mu, tangent_vector)
  
    tempA=mu'*tangent_vector;
    theta=sqrt(tempA(1,2)^2+tempA(1,3)^2+tempA(2,3)^2);
     if(abs(theta) < 1e-7)
         exp_1=eye(3);
         
     else
        exp_1=eye(3)+sin(theta)/theta*tempA +(1-cos(theta))/theta^2*tempA*tempA;
     end
     exp_map=mu*exp_1;
         
end


