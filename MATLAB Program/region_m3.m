function [im11] = region_m3(image)
tstart = tic;
[im, match_r,loc] = remove_m3(image);
match=match_r;
num=size(match,1);
k=400;%周围距离的平方
l=3;%最小匹配对
r0=[];
im1=zeros(size(im));
while num>5
    count=0;
        [r1,r0,im1]=reg1(match,loc,r0,k,l,count,image,im1);
        match([r1,r0],:)=[];
        if num==size(match,1)
            num=0;
        else
            num=size(match,1);
        end
end
im11=im1(:,1:(size(im,2)/2))+fliplr(im1(:,(size(im,2)/2+1):size(im,2)));
im11=(im11>0);
% %右边标蓝色
% im21=im1(:,1:(size(im,2)/2))*255;
% im22=im1(:,(size(im,2)/2+1):size(im,2))*255;
%  
% im3(:,:,1)=[im21 im22*0];
% im3(:,:,2)=[im21 im22*0];
% im3(:,:,3)=[im21 im22];
% %叠加到左边
% im4(:,:,1)=[im21-im22];
% im4(:,:,2)=[im21-im22];
% im4(:,:,3)=[(im21+im22)>200]*255;
% figure
% imshow(im4);
% title('用蓝色标注右侧定位区域');

% figure
% colormap('gray');
% imagesc(im1);
% title('result');
% figure
% colormap('gray');
% imagesc(im11);
% title('flipped result');

tproc = toc(tstart);
tps = datestr(datenum(0,0,0,0,0,tproc),'HH:MM:SS');
fprintf('\nComputational time: %s\n', tps);
end

function [nr1,r0,im1] = reg1(match,loc,r0,k,l,count,image,im1)
        i=1;
        r=match(i,:);
        num=size(match,1);
        nr1=[];
        for j=2:num
            d1=(loc(match(i,1),1)-loc(match(j,1),1))^2+(loc(match(i,1),2)-loc(match(j,1),2))^2;%
            d2=(loc(match(i,2),1)-loc(match(j,2),1))^2+(loc(match(i,2),2)-loc(match(j,2),2))^2;%
            d3=(loc(match(i,1),1)-loc(match(j,2),1))^2+(loc(match(i,1),2)-loc(match(j,2),2))^2;%
            d4=(loc(match(i,2),1)-loc(match(j,1),1))^2+(loc(match(i,2),2)-loc(match(j,1),2))^2;%
            if ((d1<k)&&(d2<k)) 
                count=count+1;
                r=[r match(j,:)];
            end
            if ((d3<k)&&(d4<k)) 
                    count=count+1;
                    r=[r match(j,2) match(j,1)];
            end
        end
        if count<l
            nr1=i;
            return ;
        end
%% 计算h
    y1=[loc(r(1,2),1) loc(r(1,4),1) loc(r(1,6),1); ...
        loc(r(1,2),2) loc(r(1,4),2) loc(r(1,6),2);1 1 1];
    x1=[loc(r(1,1),1) loc(r(1,3),1) loc(r(1,5),1); ...
       loc(r(1,1),2) loc(r(1,3),2) loc(r(1,5),2);1 1 1];
    h1=y1/x1;%效果好
    H=isnan(h1);
    if sum(sum(H))>0
        nr1=i;
        return ;
    end
        
%% 找出所有符合h的匹配对  
    for i=1:size(match,1)
        l_m=h1*[loc(match(i,1),1);loc(match(i,1),2);1];
        d_l=[loc(match(i,2),1);loc(match(i,2),2);1]-l_m;
        if sum(d_l.*d_l)<k
            nr1=[nr1,i];
        end
    end
if size(nr1,2)<5
    return
end
%% 修正h
match_r=match(nr1,:);
rp=randperm(size(nr1,2));
h=h1;
w=10000;
for i=1:floor(size(nr1,2)/3)
    y2=[loc(match_r(rp(i*3-2),2),1) loc(match_r(rp(i*3-1),2),1) loc(match_r(rp(i*3),2),1); ...
        loc(match_r(rp(i*3-2),2),2) loc(match_r(rp(i*3-1),2),2) loc(match_r(rp(i*3),2),2);1 1 1];
    x2=[loc(match_r(rp(i*3-2),1),1) loc(match_r(rp(i*3-1),1),1) loc(match_r(rp(i*3),1),1); ...
        loc(match_r(rp(i*3-2),1),2) loc(match_r(rp(i*3-1),1),2) loc(match_r(rp(i*3),1),2);1 1 1];
    h2=y2/x2;
    w1=0;
    for j=1:size(nr1,2)
        k1=loc(match_r(j,2),1:2);
        k2=h*[loc(match_r(j,1),1:2),1]';
        w2=(k1(1)-k2(1))^2+(k1(2)-k2(2))^2;
        w1=w1+w2;
    end
    if w1<w
        h=h2;
        w=w1;
    end
end
% 
% figure
% colormap('gray');
% imagesc(im);
% hold on;
% title(['单应性相似匹配对' int2str(size(nr1,2))]);
for i = 1: size(match_r,1)
%     line([loc(match_r(i,1),2) loc(match_r(i,2),2)], ...
%          [loc(match_r(i,1),1) loc(match_r(i,2),1)], 'Color', 'c');%横坐标，纵坐标
%      每个匹配对周围定位篡改
     im1=reg2(im1,image,match_r(i,:),loc,h);
end
% figure
% colormap('gray');
% imagesc(im11);
% title('篡改检测结果');
end   

function [im1] = reg2(im1,image,match,loc,h)
l=50;
t=3;
I=imread(image);
I=imresize(I,1024/size(I,1));
I=[I fliplr(I)];
[m,n,k]=size(I);
for y=loc(match(1),1)-l:loc(match(1),1)+l
    for x=loc(match(1),2)-l:loc(match(1),2)+l
        xyz=h*[y,x,1]';
        xyz=round(xyz);
        if (xyz(1)<m)&&(xyz(2)<n)&&(y<m)&&(x<n)&&(xyz(1)>0)&&(xyz(2)>0)&&(y>1)&&(x>1)
        r=abs(I(round(y),round(x),1)-I(xyz(1),xyz(2),1));
        g=abs(I(round(y),round(x),2)-I(xyz(1),xyz(2),2));
        b=abs(I(round(y),round(x),3)-I(xyz(1),xyz(2),3));
        if max([r,b,g])<t
            im1(round(y),round(x))=1;
            im1(xyz(1),xyz(2))=1;
        end
        end
    end
end

for y=loc(match(2),1)-l:loc(match(2),1)+l
    for x=loc(match(2),2)-l:loc(match(2),2)+l
        xyz=[y,x,1]'\h;
        xyz=round(xyz);
        if (xyz(1)>0)&&(xyz(2)>0)&&(xyz(3)>0)&&(y<m)&&(x<n)
        r=abs(I(round(y),round(x),1)-I(xyz(1),xyz(2),1));
        g=abs(I(round(y),round(x),2)-I(xyz(1),xyz(2),2));
        b=abs(I(round(y),round(x),3)-I(xyz(1),xyz(2),3));
        if max([r,b,g])<t
            im1(round(y),round(x))=1;
            im1(xyz(1),xyz(2))=1;
        end
        end
    end
end
end