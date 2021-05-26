clc;
clear;
close all;

addpath("MMread");
rng(1);

video = mmread('../data/cars.avi');
name = 'cars';
x_min = 169;
x_max = 288;
y_min = 113;
y_max = 352;

% video = mmread('../data/flame.avi');
% name = 'flame';
% x_min = 1;
% x_max = 288;
% y_min = 1;
% y_max = 352;
T = 3;
% T = 5;
% T = 7;

H = x_max - x_min + 1;
W = y_max - y_min + 1;
noise_std = 2;

F = zeros(H,W,T,'double');
for i=1:T
    F(:,:,i) = rgb2gray(video.frames(i).cdata(x_min:x_max, y_min:y_max, :));
end

C = randi([0, 1], H, W, T, 'double');

E = sum(C.*F, 3) + noise_std*randn(H,W);

imwrite(cast(E/T, 'uint8'), sprintf('results/%s_%i_coded_snapshot.jpg',name,T));

D1 = dctmtx(ps);
psi = kron(D1', D1');

R = zeros(H, W, T, 'double');
avg_mat = zeros(H, W, 'double');

tic;
for i=1:H-ps+1
    for j=1:W-ps+1
        y = reshape(E(i:i+ps-1,j:j+ps-1), [ps*ps 1]);

        phi = zeros(ps*ps, ps*ps*T, 'double');
        for k=1:T
            phi(:, ps*ps*(k-1)+1 : ps*ps*k) = ...
                diag(reshape(C(i:i+ps-1, j:j+ps-1,k), [ps*ps 1])) * psi;
        end

        x = omp(phi, y, 9*ps*ps*noise_std^2);
        for k=1:T
            R(i:i+ps-1, j:j+ps-1, k) = ...
                R(i:i+ps-1, j:j+ps-1, k) + reshape(psi * x((k-1)*ps*ps+1 : k*ps*ps), [ps ps]);
        end
        avg_mat(i:i+ps-1, j:j+ps-1) = avg_mat(i:i+ps-1, j:j+ps-1) + ones(ps, ps);

        % Prints the coordinates, to check for speed and debugging
        fprintf('(%i, %i)\n',i,j);
    end
end

for i=1:T
    R(:,:,i) = R(:,:,i)./avg_mat(:,:);
    figure;
    imshow(cast([R(:,:,i), F(:,:,i)], 'uint8'));
    imwrite(cast([R(:,:,i), F(:,:,i)], 'uint8'), sprintf('results/%s_%i_%i.png',name,T,i));
    fprintf('RMSE for frame %i : %f\n', i, ...
        (norm(R(:,:,i) - F(:,:,i), 'fro')^2 / norm(F(:,:,i), 'fro')^2));
end
fprintf('RMSE of video sequence : %f\n', ...
    (norm(reshape(R(:,:,:) - F(:,:,:), [H*W*T 1]))^2 / norm(reshape(F(:,:,:), [H*W*T 1]))^2));

toc;
