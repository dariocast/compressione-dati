function  [Y, Phi] = image_acquisition (X,s,m)
    disp('start image_acquisition...')

    [M , N, colors ] = size(X);

    % prendiamo solo 1 colore
    X = X( : , : , 1 );

    Y = [];

    % valori random 
    %normrnd(mu,sigma, []) generates random numbers from the normal distribution with mean parameter mu and standard deviation parameter sigma. 
    Phi = normrnd(0,1,[m,s*N]);

    for i=0:1:(M/s)-1
        row1 = i*s+1;
        row2 = row1+s-1;

        %crea il vettore x_i (1 stripe) 
        x_i = [];
        for j=row1:row2
            tmp = [x_i X(j,:)];
            x_i = tmp;
        end
        
        %fa la trasposta
        x_i = double( x_i' );
        y_i = Phi * x_i;
        
        % aggiungiamo y_i come nuova colonna in Y
        TMP = [Y y_i];
        Y = TMP;
    end
    
end
