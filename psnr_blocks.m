clear
clc
% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '\toolbox\images\imdemos');
baseFileName = 'lena.png';
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

grayImage = imread(fullFileName);
grayImage = grayImage(:,:,1);
% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows columns numberOfColorBands] = size(grayImage);
blockSizeR = [23,32,45,55,64,72]; % Rows in block.
blockSizeC = [23,32,45,55,64,72]; % Columns in block.
for index=1:1:6
    % Figure out the size of each block in rows.
    % Most will be blockSizeR but there may be a remainder amount of less than that.
    wholeBlockRows = floor(rows / blockSizeR(index));
    blockVectorR = [blockSizeR(index) * ones(1, wholeBlockRows), rem(rows, blockSizeR(index))];
    % Figure out the size of each block in columns.
    wholeBlockCols = floor(columns / blockSizeC(index));
    blockVectorC = [blockSizeC(index) * ones(1, wholeBlockCols), rem(columns, blockSizeC(index))];
    % Create the cell array, ca.
    % Each cell (except for the remainder cells at the end of the image)
    % in the array contains a blockSizeR by blockSizeC by 3 color array.
    % This line is where the image is actually divided up into blocks.
    ca = mat2cell(grayImage, blockVectorR, blockVectorC);
    pre_image = [];
    post_image = [];
    
    Phi = normrnd(0,1,[250,blockSizeR(index)*blockSizeC(index)]);
    
    maxRIteration =  size(ca,1)-1;
    maxCIteration =  size(ca,2)-1;
    
    for r = 1 : maxRIteration
        for c = 1 : maxCIteration
            % Extract the numerical array out of the cell
            % just for tutorial purposes.
            block = ca{r,c};
            [rowsB, columnsB, numberOfColorBandsB] = size(block);
            block_vector_x = double(block(:));
            block_vector_y = Phi*block_vector_x;
            [m,n] = size(Phi);
            Theta = zeros(m,n);
            for ii = 1:n
                ek = zeros(1,n);
                ek(ii) = 1;
                psi = idct(ek)';
                Theta(:,ii) = Phi*psi;
            end
            
            %___l2 NORM SOLUTION___ s2 = Theta\y; %s2 = pinv(Theta)*y
            s2 = pinv(Theta)*block_vector_y;
            
            %___IMAGE RECONSTRUCTIONS___
            x2 = zeros(n,1);
            for ii = 1:n
                ek = zeros(1,n);
                ek(ii) = 1;
                psi = idct(ek)';
                x2 = x2+psi*s2(ii);
            end
            pre_image = [pre_image, block_vector_x];        
            post_image = [post_image, x2];
        end
    end
    peaksnr = psnr(pre_image,post_image);
    disp(['Peak Signal-to-Noise Ratio (PSNR)=',num2str(peaksnr)])
    fprintf('Block dimension: %d x %d\n',blockSizeR(index),blockSizeC(index));
end