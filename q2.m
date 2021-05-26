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
T = 3;
% T = 5;
% T = 7;

% video = mmread('../data/flame.avi');
% name = 'flame';
% x_min = 1;
% x_max = 288;
% y_min = 1;
% y_max = 352;
% T = 5;

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

D1 = dctmtx(8);
D2 = kron(D1', D1');
% psi = kron(D2', dctmtx(T)');
psi = D2;

R = zeros(H, W, T, 'double');
avg_mat = zeros(H, W, 'double');

% for i=1:H/8
%     for j=1:W/8
%         y = reshape(E(8*(i-1)+1:8*i,8*(j-1)+1:8*j), [8*8 1]);
% 
%         phi = zeros(8*8, 8*8*T, 'double');
%         for k=1:T
%             phi(:,8*8*(k-1)+1:8*8*k) = diag(reshape(C(i:i+7,j:j+7,k), [8*8 1]));
%         end
%         
%         x = omp(phi*psi, y, noise_std^2);
%         R(8*(i-1)+1:8*i,8*(j-1)+1:8*j,:) = reshape(psi*x, [8 8 T]);
%         
%     end
% end

tic;
for i=1:H-7
    for j=1:W-7
        y = reshape(E(i:i+7,j:j+7), [8*8 1]);

        phi = zeros(8*8, 8*8*T, 'double');
        for k=1:T
            phi(:,8*8*(k-1)+1:8*8*k) = diag(reshape(C(i:i+7,j:j+7,k), [8*8 1]))*psi;
        end
        
        x = omp(phi, y, 9*8*8*noise_std^2);
        for k=1:T
            R(i:i+7,j:j+7,k) = R(i:i+7,j:j+7,k) + reshape(psi*x((k-1)*8*8+1:k*8*8), [8 8]);
        end
        avg_mat(i:i+7,j:j+7) = avg_mat(i:i+7,j:j+7) + ones(8,8);
        % Prints the coordinates, to check for speed and debugging
        fprintf('(%i, %i)\n',i,j);
    end
end

for i=1:T
    R(:,:,i) = R(:,:,i)./avg_mat(:,:);
    figure;
    imshow(cast([R(:,:,i), F(:,:,i)], 'uint8'));
    imwrite(cast([R(:,:,i), F(:,:,i)], 'uint8'), sprintf('results/%s_%i_%i.png',name,T,i));
    fprintf('RMSE for frame %i : %f\n',i,norm(R(:,:,i)-F(:,:,i), 'fro')^2/norm(F(:,:,i), 'fro')^2);
end
fprintf('RMSE of video sequence : %f\n',norm(reshape(R(:,:,:)-F(:,:,:), [H*W*T 1]))^2/norm(reshape(F(:,:,:), [H*W*T 1]))^2);

toc;
