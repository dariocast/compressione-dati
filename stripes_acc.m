clear
clc
addpath ('l1magic');
addpath ('l1magic/Optimization');

% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '/toolbox/images/imdata');
info = dir(folder);
pattern = [".jpg",".png",".tif",".tiff",".jpeg"]

for num_file = 1:1:size(info)
    if contains(info(num_file).name,pattern, 'IgnoreCase',true)
        baseFileName = info(num_file).name;
        
        
        
        % baseFileName = 'lena.png';
        % baseFileName = 'peppers.png';
        % baseFileName = 'pillsetc.png';
        % baseFileName = 'airplane.tiff';
        % baseFileName = 'bridge.tiff';
        % baseFileName = 'house.tiff';
        % baseFileName = 'sailboat.tiff';
        
        % Get the full filename, with path prepended.
        fullFileName = fullfile(folder, baseFileName);
        if ~exist(fullFileName, 'file')
            % Didn't find it there.  Check the search path for it.
            fullFileName = baseFileName; % No path this time.
            if ~exist(fullFileName, 'file')
                % Still didn't find it.  Alert user.
                errorMessage = sprintf('Error: %s does not exist.', fullFileName);
                uiwait(warndlg(errorMessage));
                return;
            end
        end
        
        
        disp(['File input: ', baseFileName]);
        
        %imread reads the image from the file specified by filename, inferring the format of the file from its contents. If filename is a multi-image file, then imread reads the first image in the file.
        X = imread(fullFileName);
        X = X(:,:,1);
        [M, N] = size(X);
        
        % numero di righe per ogni stripes (Qui si possono variare i valori per ripetere i casi di test)
        s = [1,2,4,6,8,10];
        disp(['SIZE IMG: M=',num2str(M),'  N=',num2str(N)])
        
        for i=1:1:6
            % size di ogni vettore y_i (colonne di una stripe o lunghezza)
            m = N;
            disp(['NUM STRIPES=',num2str(M/s(i))])
            % STRIPE ACQUISITION
            t0 = cputime;
            [Y,Phi,corr_vector] = image_acquisition_corr( X , s(i) , m, true);
            t1 = cputime;
            
            [rY, cY] = size(Y);
            ACC = sum(corr_vector)/cY;
            
            disp(['ACC Stripes: ',num2str(ACC)])
        end
        
    end
end