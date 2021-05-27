clc;
clear;
close all;

%% Add MMread for reading the video
addpath("MMread");
rng(1);

%% Cars Video
video = mmread('../data/cars.avi');
name = 'cars';
% Co-ordinates of the frame
x_min = 169;
x_max = 288;
y_min = 113;
y_max = 352;

%% Flame Video
% video = mmread('../data/flame.avi');
% name = 'flame';
% % Co-ordinates of the frame
% x_min = 1;
% x_max = 288;
% y_min = 1;
% y_max = 352;

%% Number of frames
T = 3;
% T = 5;
% T = 7;

%% Constants
% Set the Height and Width each frame
H = x_max - x_min + 1;
W = y_max - y_min + 1;
% Set standard deviation of Gaussian Noise
noise_std = 2;
% Set Patch size
ps = 8;

%% Convert the frames to grayscale
F = zeros(H,W,T,'double');
for i=1:T
    F(:,:,i) = rgb2gray(video.frames(i).cdata(x_min:x_max, y_min:y_max, :));
end

%% Define the binary code for coded aperture camera
C = randi([0, 1], H, W, T, 'double');

%% Get the measurement frame using additive gaussian noise
E = sum(C.*F, 3) + noise_std*randn(H,W);

%% Save the single exposure coded snapshot - this is the output of the camera
imwrite(cast(E/T, 'uint8'), sprintf('results/%s_%i_coded_snapshot.jpg',name,T));

%% Reconstruction of the frames
% Define the orthonormal matrix in which each frame is sparse - here, 2D-DCT
D1 = dctmtx(ps);
psi = kron(D1', D1');

% Initialize reconstruction frames
R = zeros(H, W, T, 'double');
avg_mat = zeros(H, W, 'double');

tic;
% For every (overlapping) patch
for i=1:H-ps+1
    for j=1:W-ps+1
        % Get the coded snapshot for the patch
        y = reshape(E(i:i+ps-1,j:j+ps-1), [ps*ps 1]);

        % Construct phi from C and psi as sensing matrix w.r.t. DCT coefficients
        phi = zeros(ps*ps, ps*ps*T, 'double');
        for k=1:T
            phi(:, ps*ps*(k-1)+1 : ps*ps*k) = ...
                diag(reshape(C(i:i+ps-1, j:j+ps-1,k), [ps*ps 1])) * psi;
        end

        % Perform Orthogonal Matching Pursuit to obtain the DCT coefficients
        x = omp(phi, y, 9*ps*ps*noise_std^2);

        % Update the reconstructed patch from the coefficients
        for k=1:T
            R(i:i+ps-1, j:j+ps-1, k) = ...
                R(i:i+ps-1, j:j+ps-1, k) + reshape(psi * x((k-1)*ps*ps+1 : k*ps*ps), [ps ps]);
        end
        avg_mat(i:i+ps-1, j:j+ps-1) = avg_mat(i:i+ps-1, j:j+ps-1) + ones(ps, ps);

        % Print the co-ordinates of the patch, to check for speed and debugging
        fprintf('(%i, %i)\n',i,j);
    end
end

%% Save the result and Compute RMSE (Relative Mean Squared Error)
R = R ./ avg_mat;
R = cast(R, 'uint8');
F = cast(F, 'uint8');

% For every frame
for i=1:T
    % Get the final reconstructed frame
%     R(:,:,i) = R(:,:,i)./avg_mat(:,:);
    % Display and Save the reconstructed frame
    figure;
    imshow([R(:,:,i), F(:,:,i)]);
    imwrite([R(:,:,i), F(:,:,i)], sprintf('results/%s_%i_%i.png',name,T,i));
    % RMSE of the frame
    fprintf('RMSE for frame %i : %f\n', i, ...
        (norm(double(R(:,:,i) - F(:,:,i)), 'fro')^2 / norm(double(F(:,:,i)), 'fro')^2));
end
% RMSE of the entire video
fprintf('RMSE of video sequence : %f\n', ...
    (norm(double(reshape(R(:,:,:) - F(:,:,:), [H*W*T 1])))^2 / norm(double(reshape(F(:,:,:), [H*W*T 1])))^2));

% Evaluate the time taken
toc;
