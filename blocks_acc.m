clear
clc
% Read in a standard MATLAB gray scale demo image.
folder = fullfile(matlabroot, '/toolbox/images/imdata');
info = dir(folder);
pattern = [".jpg",".png",".tif",".tiff",".jpeg"]

for num_file = 1:1:size(info)
    if contains(info(num_file).name,pattern, 'IgnoreCase',true)
        baseFileName = info(num_file).name;
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
        % decomment the following line to test image by column
        grayImage = grayImage';
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
            
            Phi = normrnd(0,1,[250,blockSizeR(index)*blockSizeC(index)]);
            y_prev = [];
            y_curr = [];
            corr = 0;
            corr_vector = [];
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
                    y_curr = block_vector_y;
                    if c > 1
                        corr = corr2(y_prev,y_curr);
                        corr_vector = [corr_vector, corr];
                    end
                    y_prev = y_curr;
                end
            end
            
            [rY, cY] = size(corr_vector);
            ACC = sum(corr_vector)/cY;
            
            fprintf('Block dimension: %d x %d\t ACC Blocks: %f\n',blockSizeR(index),blockSizeC(index),ACC);
            %disp(['ACC Blocks: ',num2str(ACC)])
        end
    end
end


% % Let's assume we know the block size and that all blocks will be the same size.
% blockSizeR = 16; % Rows in block.
% blockSizeC = 16; % Columns in block.
% % Figure out the size of each block.
% wholeBlockRows = floor(rows / blockSizeR);
% wholeBlockCols = floor(columns / blockSizeC);
% % valori random
% %normrnd(mu,sigma, []) generates random numbers from the normal distribution with mean parameter mu and standard deviation parameter sigma.
% Phi = normrnd(0,1,[250,blockSizeR*blockSizeC]);
% y_prev = [];
% y_curr = [];
% corr = 0;
% corr_vector = [];
%
% for row = 1 : blockSizeR : rows
% 	for col = 1 : blockSizeC : columns
% 		% Let's be a little explicit here in our variables
% 		% to make it easier to see what's going on.
% 		row1 = row;
% 		row2 = row1 + blockSizeR - 1;
% 		col1 = col;
% 		col2 = col1 + blockSizeC - 1;
% 		% Extract out the block into a single subimage.
% 		oneBlock = grayImage(row1:row2, col1:col2);
%         block_vector_x = double(oneBlock(:));
%         block_vector_y = Phi*block_vector_x;
%         y_curr = block_vector_y;
%         if col > 1
%             corr = corr2(y_prev,y_curr);
%             corr_vector = [corr_vector, corr];
%         end
%         y_prev = y_curr;
% 	end
% end
%
% [rY, cY] = size(corr_vector);
% ACC = sum(corr_vector)/cY;
%
% disp(['ACC Blocks: ',num2str(ACC)])
%
% % INPUTFILE = 'lena.png';
% % X = imread(INPUTFILE);
% % X = X(:,:,1);
% % [M, N] = size(X);
% % BLOCK_DIM = [16, 16];
% % block_x = BLOCK_DIM(1);
% % block_y = BLOCK_DIM(2);
% % Block = [];
% % % valori random
% % %normrnd(mu,sigma, []) generates random numbers from the normal distribution with mean parameter mu and standard deviation parameter sigma.
% % Phi = normrnd(0,1,[block_x,block_y]);
% %
% %
% % for i=0:1:(M/block_x)-1
% %   for j=0:1:(N/block_y)-1
% %     Block = X(i*block_x+1:i*block_x,j*block_y+1:j*block_y+block_y);
% %     y_curr = Block;
% %     if i>0 || j>0
% %         corr = corr2(y_prev,y_curr);
% %         corr_vector(i+j) = corr;
% %     end
% %     y_prev = y_curr;
% %   end
% % end
