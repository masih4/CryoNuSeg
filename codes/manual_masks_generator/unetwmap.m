%% U-Net Weight Map implementation
% written by Fidel A. Guerrero Pena


function [weight]=unetwmap(gt,w0,sigma)
if nargin<2
    w0=10;
end
if nargin<3
    sigma=25; %5^2
end

% class balance weights w_c(x)
uvals=unique(gt);
wmp=zeros(1,length(uvals));
for uv=1:length(uvals)
    wmp(uv)=1/sum(gt(:)==uvals(uv));
end
% this normalization is important!
%background pixels must have weight 1
wmp=wmp/max(wmp);

wc=double(gt);
for uv=1:length(uvals)
    wc(gt==uvals(uv))=wmp(uv);
end

% cells instances for distance computation
cells=bwlabel(gt==255, 8);
A = unique(cells);

% cells distance map
bwgt=zeros(size(gt));
maps=zeros(size(gt,1),size(gt,2),max(cells(:)));
if max(cells(:))>=2
    for ci=1:max(cells(:))
        maps(:,:,ci)=bwdist(cells==ci);
    end
    maps=sort(maps,3);
    d1=maps(:,:,1);
    d2=maps(:,:,2);
    bwgt=w0*exp(-((d1+d2).^2)./(2*sigma) ).*(cells==0);
end

% unet weights
weight=wc + bwgt;


% visualization
% figure
% subplot(1,2,1),imagesc(gt); colormap gray;
% subplot(1,2,2),imagesc(weight); colormap jet;
end



%     
% gt = test(300:499,300:499);%border not removed gt
% gt = test2(300:499,300:499);% border removed gt
% gt(gt==255)=1;
% SE = strel('disk',1,0)
% %SE = strel('square',2)
% J = imerode(gt,SE);
% J = bwareaopen(J,40);
% subplot(1,2,1);imagesc(gt);cells=bwlabel(gt==1, 8);title(length(unique(cells)));
% subplot(1,2,2);imagesc(J);cells=bwlabel(J==1, 8);title(length(unique(cells)));
% 
% gt = J;
% 
% 
% 
