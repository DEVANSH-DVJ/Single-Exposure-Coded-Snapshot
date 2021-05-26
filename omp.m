
function theta = omp(A, y, e)
    % Input:
    %   A : overcomplete dictionary
    %   y : signal
    %   e : error bound
    % Output:
    %   theta : sparse coefficients
    % Brief:
    %   Orthogonal Matching Pursuit for solving y = A*theta where theta is sparse

    %% Constants
    [N, K] = size(A);   % N:dim of signal, K:#atoms in dictionary
    theta = zeros(K,1); % coefficient (output)
    r = y;              % residual of y
    T = [];             % support set
    i = 0;              % iteration
    A_omega = [];       % Sub-matrix of A containing columns which lie in the support set

    %% Iteratively converging
    while(i < N && norm(r)^2 > e)
        i = i + 1;
        x_tmp = zeros(K,1);

        % Iterate all columns except for the chosen ones
        indices = setdiff(1:K, T);
        for ind=indices
            % Solution of min ||a'x-b||
            x_tmp(ind) = A(:,ind)' * r / norm(A(:,ind));
        end

        % Choose the next column
        [~,j] = max(abs(x_tmp));
        T = [T j];
        A_omega = [A_omega A(:,j)];

        % Using pseudo-inverse of A_omega
        theta_s = pinv(A_omega) * y;
        r = y - A_omega * theta_s;
    end

    %% Final output
    for j=1:i
        theta(T(j)) = theta_s(j);
    end
end
