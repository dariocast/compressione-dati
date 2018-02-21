function [X]=image_reconstruction(Y,Phi,s)
    disp('start image_reconstruction')
    [aa,bb] = size(Y);
    
    X = [];
    
    [m,n] = size(Phi);

    Theta = zeros(m,n);
    for ii = 1:n
        ek = zeros(1,n);
        ek(ii) = 1;
        psi = idct(ek)';
        Theta(:,ii) = Phi*psi;
    end

    for iy = 1:bb

        y = Y(:,iy);

        %___l2 NORM SOLUTION___ s2 = Theta\y; %s2 = pinv(Theta)*y
        s2 = pinv(Theta)*y;
        s1 = l1eq_pd(s2,Theta,Theta',y,5e-3,20); % L1-magic toolbox

        x_i = zeros(n,1);
        for ii = 1:n    
            ek = zeros(1,n);
            ek(ii) = 1;
            psi = idct(ek)';
            x_i = x_i+psi*s1(ii);
        end
           
        
        % divide le stripes in righe dell'immagine
        for ss = 1:n/s:n
            s2 = ss+n/s-1;
            imgrow = x_i(ss:s2);
            
            tmpX = [X ; imgrow'];
            X = tmpX;
        end
    end
end