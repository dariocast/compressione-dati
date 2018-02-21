clear
clc
addpath ('l1magic');
addpath ('l1magic/Optimization');

% numero di righe per ogni stripes
s = 2;

% size di ogni vettore y_i
m = 512;

% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
baseFileName = 'lena.png';
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


% %INPUTFILE = 'cameraman.tif';
% INPUTFILE = 'lena.png';

disp(['File input: ', baseFileName]);

%imread reads the image from the file specified by filename, inferring the format of the file from its contents. If filename is a multi-image file, then imread reads the first image in the file.
X = imread(fullFileName);
X = X(:,:,1);
[M, N] = size(X);
num_bytes_original = prod(size(X));

disp([ 'SIZE IMG: M=',num2str(M),'  N=',num2str(N)])
disp(['NUM STRIPES=',num2str(s)])
disp(['SIZE m=',num2str(m)])


% ACQUISITION
t0 = cputime;
[Y,Phi] = image_acquisition( X , s , m );
[encodedx, predictor,codebook,partition] = dpcmenc(Y,m); 
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

% recostruction usando la DPCM
YYD = dpcmdec(encodedx,codebook,predictor,m);
X_hat_D = image_reconstruction(YYD,Phi,s);
t3 = cputime;
num_bytes_dpcm = prod(size(X_hat_D));

disp(['TIME CS image_reconstruction+DPCM: ',num2str(t3-t2)])

figure('name','Compressive sensing image reconstructions')
subplot(1,3,1), imagesc(X), xlabel('original'), axis image
subplot(1,3,2), imagesc(X_hat), xlabel('cs'), axis image
subplot(1,3,3), imagesc(X_hat_D), xlabel('cs dpcm'), axis image
X_hat_image = imagesc(X_hat);
imwrite(X_hat_image,'output.png');