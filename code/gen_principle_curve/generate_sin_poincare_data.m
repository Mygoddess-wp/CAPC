function data = generate_sin_poincare_data(N, amplitude, frequency, noise_level)
    x = linspace(-pi, pi, N); 
    y = amplitude * sin(frequency * x) + normrnd(0, noise_level, 1, N); 
    y = y + abs(min(y)) + 1; 
    data = [x; y];
end