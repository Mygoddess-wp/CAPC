
function data = generate_poincare_data(N, coefficient)
    x = -3 + 6 * rand(1, N); 
    y = (coefficient) * abs(x) + normrnd(10, 1/4, 1, N); 
    valid_indices = y > 0;
    data = [x(valid_indices); y(valid_indices)];
end


