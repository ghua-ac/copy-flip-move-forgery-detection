% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');
function [im, num, match, loc] = newmatch2(image)
RGB = imread(image);
RGB=imresize(RGB,1024/size(RGB,1));
[~,size2,ColorChannel] = size(RGB);
if ColorChannel > 1
    YCBCR = rgb2ycbcr(RGB);
    imwrite(YCBCR(:,:,1),'test1.jpg');
end
image='test1.jpg';
% Find SIFT keypoints for each image
[im, des1, loc1] = sift(image);
loc2=loc1;
a=[13;14;15;16;9;10;11;12;5;6;7;8;1;2;3;4];
b=[a*8-7,a*8,a*8-1,a*8-2,a*8-3,a*8-4,a*8-5,a*8-6];
c=reshape(b.',1,128);
des2=des1(:,c);
%% 画关键点
% figure('Position', [100 100 size(im,2) size(im,1)]);
% colormap('gray');
% imagesc(im);
% hold on;
% cols1 = size(im,2);
% plot(loc(:,2),loc(:,1),'.','Color','r','MarkerSize',5);
% title('SIFT keypoints')
% hold off;
%  
% des2=[fliplr(des(:,1:32))  fliplr(des(:,33:64)) fliplr(des(:,65:96)) fliplr(des(:,97:128))];
% des4=[];
% for i=[4 3 2 1]
%     for j=1:4
%         des3=fliplr(des(:,((i-1)*4+j-1)*8+1:((i-1)*4+j-1)*8+8));
%         des4=[des4 des3];
%     end
%     des4=[des4 des3];
% end
% des5=fliplr(des);        
% des=[des;des5];
% loc=[loc;loc];
%[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   
% For each descriptor in the first image, select its match to second image.
%% 组内匹配
dest = des1';                          % Precompute matrix transpose
i=1;
n=size(des1,1);
dotprods = des1(i,:) * dest(:,2:n); 
[vals,indx] = sort(acos(dotprods));   
if (vals(1) < distRatio * vals(2))
    if indx(1)>=i
         indx(1)=indx(1)+1;
    end
   match1(i) = indx(1);
else
   match1(i) = 0;
end
for i = 2 : n-1
dotprods = des1(i,:) * [dest(:,1:i-1) dest(:,i+1:n)];        % Computes vector of dot products
  [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
       if(indx(1)>=i)
           indx(1)=indx(1)+1;
       end
      match1(i) = indx(1);
   else
      match1(i) = 0;
   end
end
i=n;
dotprods = des1(i,:) * dest(:,1:n-1); 
[vals,indx] = sort(acos(dotprods));   
if (vals(1) < distRatio * vals(2))
   match1(i) = indx(1);
else
   match1(i) = 0;
end
%% 镜像匹配
dest = des2';                          % Precompute matrix transpose
for i = 1:n
dotprods = des1(i,:) * dest;        % Computes vector of dot products
  [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
%        if(indx(1)>=i)
%            indx(1)=indx(1)+1;
%        end
      match2(i) = indx(1);
   else
      match2(i) = 0;
   end
end
match2=match2+n;
% Create a new image showing the two images side by side.
%im = appendimages(im,im2);

% Show a figure with lines joining the accepted matches.
match=[match1 match2];
loc=[loc1;loc2];

num = sum((match > 0).*(match~=n));
%% 整理匹配对矩阵
match=[1:n 1:n;match];
match=match';
i=1;
while i<num+1
    if(match(i,2)==0 || match(i,2)==n)
        match(i,:)=[];
    else
        i=i+1;
    end
end %所有的匹配对
match=match(1:num,:);
i=1;
while i<num  %去除重复匹配对
    j=i+1;
    while j<num+1
        if((match(i,1)==match(j,2))&&(match(i,2)==match(j,1)))
            match(j,:)=[];
            num=num-1;
            j=j-1;
        end
        j=j+1;
    end
    i=i+1;
end
%% 匹配结果绘图
% figure('Position', [100 100 size(im,2) size(im,1)]);
% %figure('Position', [100 100 size(im,2)/2 size(im,1)]);
% colormap('gray');
% %imagesc(im(:,1:size(im,2)/2));
% imagesc(im);
% hold on;
% cols1 = size(im,2);
% for i = 1:num1
%   if (match(i) > 0)
%     line([loc(match(i,1),2) loc(match(i,2),2)], ...
%          [loc(match(i,1),1) loc(match(i,2),1)], 'Color', 'c');
%   end
% end
% title('CM matches')
% hold off;
% 
% figure('Position', [100 100 size(im,2) size(im,1)]);
% colormap('gray');
% imagesc(im);
% hold on;
% cols1 = size(im,2);
% for i = num1+1:size(match,1)
%   if (match(i) > 0)
%     line([loc(match(i,1),2) loc(match(i,2),2)], ...
%          [loc(match(i,1),1) loc(match(i,2),1)], 'Color', 'c');
%   end
% end
% title('CFM matches')
% hold off;
% 
% figure('Position', [100 100 size(im,2) size(im,1)]);
% colormap('gray');
% imagesc(im);
% hold on;
% cols1 = size(im,2);
% for i = 1:size(match,1)
%   if (match(i) > 0)
%     line([loc(match(i,1),2) loc(match(i,2),2)], ...
%          [loc(match(i,1),1) loc(match(i,2),1)], 'Color', 'c');
%   end
% end
% title('全部匹配对')
% hold off;
% fprintf('Found %d matches.\n', num);




