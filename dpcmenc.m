function [encodedx, predictor,codebook,partition] = dpcmenc(YY,m)

    xx = [];
    % crea il vettore xx dalla matrice di YY
    [a,b] = size(YY);
    for i= 1:b
        tmp =[xx YY(:,i)'];
        xx = tmp;
    end

    % Optimize parameters, using initial codebook and order 1.
    [predictor,codebook,partition] = dpcmopt(xx,m-1,128);

    % Quantize x using DPCM.
    [encodedx,qs] = dpcmenco(xx,codebook,partition,predictor);

end
