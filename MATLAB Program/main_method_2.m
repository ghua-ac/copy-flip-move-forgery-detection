im_file = 'demo.jpg';
RGB = imread(im_file);
imwrite([RGB(:,:,:) fliplr(RGB(:,:,:))],'test.jpg');%构建双倍对称图像并保存
image='test.jpg';
map = region_m2(image);%对双倍对称图像进行CM检测
[m,n,channel]=size(RGB);
map=map(:,1:n)+fliplr(map(:,size(map,2)-n+1:size(map,2)));%将检测结果翻转合并
map=(map>0);
imshow(map);