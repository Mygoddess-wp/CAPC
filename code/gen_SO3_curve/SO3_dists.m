
function [ result ] = SO3_dists( A,data )
    [~,D,N]=size(data);
    data1=reshape(data,[D,D*N]);
    D1=A'*data1;
    tra=repmat(eye(D), 1, N).*D1;
    tra=sum(tra);
    group_sums = sum(reshape(tra, D, []), 1);
    result=zeros(size(group_sums));
    result(group_sums>=3)=0;
    result(group_sums<=-1)=sqrt(2)*pi;
    result(group_sums>-1&group_sums<3)=sqrt(2) *acos((group_sums(group_sums>-1&group_sums<3)-1)/2);
end

