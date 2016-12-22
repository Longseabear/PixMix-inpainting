%����:
%img=imread('building.jpg');
%img = im2uint8(rgb2gray(img)); 
%imshow(img);
%corner_matrix = harris_old(img);
%figure,imshow(mat2gray(corner_matrix));

%����:uint8�Ҷ�ͼ��img
%���:�궨�Ľǵ㣬������Ϊ1�ĵط��ǽǵ㣬Ϊ0�ĵط��ǽǵ�
%Harris�ǵ���Գ߶�����
function [corner_matrix] = harris_old(img)

    [m, n]=size(img);

    tmp=zeros(m+2,n+2);
    tmp(2:m+1,2:n+1)=img;
    Ix=zeros(m+2,n+2);
    Iy=zeros(m+2,n+2);

    Ix(:,2:n)=tmp(:,3:n+1)-tmp(:,1:n-1);%x������
    Iy(2:m,:)=tmp(3:m+1,:)-tmp(1:m-1,:);%y������

    %���Բ���һ�ײ�֣�����Prewitt
    %dx = [-1 0 1;-1 0 1;-1 0 1];  %dx������Prewitt���ģ��  
    %Ix2 = filter2(dx,Image).^2;     
    %Iy2 = filter2(dx',Image).^2;  

    Ix2=Ix(2:m+1,2:n+1).^2;
    Iy2=Iy(2:m+1,2:n+1).^2;
    Ixy=Ix(2:m+1,2:n+1).*Iy(2:m+1,2:n+1);

    h=fspecial('gaussian',[7 7],2);%ģ��ߴ�[7,7],sigma=2
    Ix2=filter2(h,Ix2);
    Iy2=filter2(h,Iy2);
    Ixy=filter2(h,Ixy);

    Rmax=0;
    k=0.06;%��ȡ0.04-0.06
    R=zeros(m,n);%����ͼ����ÿ����Ľǵ���Ӧ
    for i=1:m
        for j=1:n
            M=[Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)];%ƫ��������
            R(i,j)=det(M)-k*(trace(M))^2;%�ǵ���Ӧ����

            if R(i,j)>Rmax
                Rmax=R(i,j);
            end
        end
    end

    tmp(2:m+1,2:n+1)=R;
    img_re=zeros(m+2,n+2);
    for i=2:m+1
        for j=2:n+1
            if tmp(i,j)>0.01*Rmax &&...
               tmp(i,j)>tmp(i-1,j-1) && tmp(i,j)>tmp(i-1,j) && tmp(i,j)>tmp(i-1,j+1) &&...
               tmp(i,j)>tmp(i,j-1) && tmp(i,j)>tmp(i,j+1) &&...
               tmp(i,j)>tmp(i+1,j-1) && tmp(i,j)>tmp(i+1,j) && tmp(i,j)>tmp(i+1,j+1)
                    img_re(i,j)=1; %3*3������Ӧ,�ұ���ʷ�����Ӧ��0.01����ʱ����Ϊ�ǽǵ�
            end
        end
    end

    corner_matrix=zeros(m,n);
    corner_matrix(1:m,1:n)=img_re(2:m+1,2:n+1);
end
