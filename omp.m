
function theta = omp(A, y, e)
    % Input:
    %   A : Overcomplete dictionary
    %   y : Signal
    %   e : Error bound
    % Output:
    %   theta : Sparse coefficients
    % Brief:
    %   Orthogonal Matching Pursuit for solving y = A*theta where theta is sparse

    %% Constants
    [N, K] = size(A);    % N:dim of signal, K:#atoms in dictionary
    theta = zeros(K, 1); % coefficient (output)
    r = y;               % residual of y
    T = zeros(K, 1);     % support set
    i = 0;               % iteration
    A_omega = [];        % Sub-matrix of A containing columns which lie in the support set

    AN = A;
    for j=1:K
        AN(:,j) = AN(:,j) / norm(AN(:,j));
    end

    %% Iteratively converge
    while(i <= N && norm(r)^2 > e)
        i = i + 1;

        % Choose the next column
        x_tmp = AN' * r;
        [~, j] = max(abs(x_tmp));
        T(i) = j;
        A_omega = [A_omega A(:,j)];

        % Using pseudo-inverse of A_omega
        % theta_s = pinv(A_omega) * y;
        % Using optimized way - works same here
        theta_s = A_omega \ y;

        % Updated residual
        r = y - A_omega * theta_s;
    end

    %% Final output
    theta(T(1:i)) = theta_s;

end
