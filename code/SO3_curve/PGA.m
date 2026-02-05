function [eV, mags, T,oriRef] = PGA(ori)
    [~, ~, N] = size(ori);
    ori = reshape(ori, [3, 3, N]);

    oriRef = mean(ori, 3);
    W = ones(N,1);
    oriRef = RiemannianMean(ori,W, 200, 1e-5);

    t = Log(oriRef, ori);
    T = (t * t') / size(t,2);

    [eV, D] = eig(T);
    [mags, ind] = sort(diag(D), 'descend');
    eV = eV(:, ind);
    
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