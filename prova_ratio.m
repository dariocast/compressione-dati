clc
clear
rgb = imread('lena.png');
imshow(rgb)
title('Original image')
imwrite(rgb,'lena.j2k','CompressionRatio',64);
imshow('lena.j2k')
title('Target compression ratio: 10')
num_mem_bytes = prod(size(rgb))
s = dir('lena.j2k');
num_file_bytes = s.bytes
r = num_mem_bytes / num_file_bytes