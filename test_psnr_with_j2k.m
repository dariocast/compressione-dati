% Authors: Dario Castellano, Alina Korniychuk
% test of psnr
clear
clc
addpath ('l1magic');
addpath ('l1magic/Optimization');

% numero di righe per ogni stripes

for s = [2 4 8]
    
    % Read in a standard MATLAB gray scale demo image.
    folder = fullfile('./images');
    info = dir(folder);
    pattern = [".jpg",".png",".tif",".tiff",".jpeg",".pgm",".ppm"];
    
    for num_file = 3:1:size(info)
        image_dir = dir(fullfile(info(num_file).folder,'/',info(num_file).name));
        for num_image = 1:1:size(image_dir)
            if contains(image_dir(num_image).name,pattern, 'IgnoreCase',true)
                baseFileName = image_dir(num_image).name;
                % Get the full filename, with path prepended.
                fullFileName = fullfile(image_dir(num_image).folder,'/',image_dir(num_image).name);
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
                
                
                % %INPUTFILE = 'cameraman.tif';
                % INPUTFILE = 'lena.png';
                
                disp(['File input: ', baseFileName]);
                
                %imread reads the image from the file specified by filename, inferring the format of the file from its contents. If filename is a multi-image file, then imread reads the first image in the file.
                X = imread(fullFileName);
                X = im2double(X);
                if ndims(X)<3
                    disp('Immagine non 3d')
                    continue
                end
                
                X = X(:,:,1);
                [M, N] = size(X);
                if (N ~= 512 || M~=N)
                    disp('Immagine non 512x512')
                    continue
                end
                % size di ogni vettore y_i
                m = N;
                
                
                disp([ 'SIZE IMG: M=',num2str(M),'  N=',num2str(N)])
                disp(['NUM STRIPES=',num2str(s)])
                disp(['SIZE m=',num2str(m)])
                
                
                % ACQUISITION
                t0 = cputime;
                [Y,Phi] = image_acquisition( X , s , m );
                
                
                t1 = cputime;
                
                [rY, cY] = size(Y);
                [rPhi, cPhi] = size(Phi);
                disp(['Size Y: ', num2str(rY),'x',num2str(cY)])
                disp(['Size Phi: ', num2str(rPhi),'x',num2str(cPhi)])
                disp(['TIME image_acquisition: ', num2str(t1-t0),' sec'])
                
                % RECONSTRUCTION
                
                % recostruction direttamente dell'img dalla CS
                X_hat = image_reconstruction(Y,Phi,s);
                t2 = cputime;
                disp(['TIME CS image_reconstruction: ',num2str(t2-t1),' sec'])
                
                try
                    peaksnr = psnr(X,X_hat);
                    disp(['Peak Signal-to-Noise Ratio (PSNR)=',num2str(peaksnr)])
                catch ME
                    disp(['Impossibile valutare PSNR CS: ',ME.identifier])
                end
                
                num_compr_bytes = prod(size(Y));
                num_orig_bytes = prod(size(X));
                ratio = num_orig_bytes / num_compr_bytes;
                disp(['Compression Ratio = ',num2str(ratio)])
                
                %compressione jpeg2000 a stesso ratio e valutazione PSNR
                new_X = imread(fullFileName);
                newFullFileName = "/Users/dariocastellano/Downloads/progetto CS_DPCM/"+baseFileName+".j2k";
                try
                    imwrite(new_X,newFullFileName,'CompressionRatio',ratio);
                    X_j2k = imread(newFullFileName);
                    peaksnr_j2k = psnr(new_X,X_j2k);
                    disp(['Peak Signal-to-Noise Ratio (PSNR) JPEG2000=',num2str(peaksnr_j2k)])
                catch ME
                    disp(['Impossibile elaborare immagine: ',ME.identifier])
                end
                delete *.j2k
            end
        end
    end
end
