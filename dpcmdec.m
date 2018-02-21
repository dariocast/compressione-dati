function [YYd] = dpcmdec(encodedx,codebook,predictor,m)

    decodedx = dpcmdeco(encodedx,codebook,predictor);
    YYd=[];
    % divide in righe il vettore decodedx
    for i=1:m:length(decodedx)
        cc = decodedx(i:i+m-1)';
        tmp = [YYd cc];
        YYd = tmp;
    end
    
end
