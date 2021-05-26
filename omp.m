function theta = omp(A, y, e)
    [N, K] = size(A); % N:dim of signal, K:#atoms in dictionary

    theta = zeros(K,1);      % coefficient (output)
    r = y;                   % residual of y
    T = [];                  % support set
    i = 0;                   % iteration
    A_omega = [];            % Sub-matrix of A containing columns which lie in the support set

    while(i < N && norm(r)^2 > e)
        i = i + 1;
        x_tmp = zeros(K,1);
        indices = setdiff(1:K, T); % iterate all columns except for the chosen ones
        for ind=indices
            x_tmp(ind) = A(:,ind)' * r / norm(A(:,ind)); % sol of min ||a'x-b||
        end
        [~,j] = max(abs(x_tmp)); % Choose the next column
        T = [T j];
        A_omega = [A_omega A(:,j)];
        theta_s = pinv(A_omega) * y; % Using pseudo-inverse of A_omega
        r = y - A_omega * theta_s;
    end

    for j=1:i
        theta(T(j)) = theta_s(j);
    end
end