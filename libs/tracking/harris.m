%yuzhang
%����:uint8�Ҷ�ͼ��img,n��2�о���candidate_list�洢�����ǽǵ�ĵ������,Ҫ���⵽�����ٵĽǵ���min_corner_num
%���:�궨�Ľǵ������б�n��2�е�corner_list

%����:
%img=imread('building.jpg');
%img = im2uint8(rgb2gray(img)); 
%imshow(img);
%corner_matrix = harris(img);
%figure,imshow(mat2gray(corner_matrix));
%Harris�ǵ���Գ߶�����
function [corner_list] = harris(img,candidate_list,min_corner_num)
    [img_height, img_width] = size(img);

    %���Բ���һ�ײ�֣�����Prewitt
    %dx = [-1 0 1;-1 0 1;-1 0 1];  %dx������Prewitt���ģ��  
    dx = [-1,1];
    Ix = filter2(dx,img);
    Iy = filter2(dx',img);
    Ix2 = Ix.^2;     
    Iy2 = Iy.^2;  
    Ixy = Ix.*Iy;

    h = fspecial('gaussian',[7 7],2);%ģ��ߴ�[7,7],sigma=2
    Ix2 = filter2(h,Ix2);
    Iy2 = filter2(h,Iy2);
    Ixy = filter2(h,Ixy);

    Rmax = 0;
    k = 0.06;%��ȡ0.04-0.06
    R = zeros(img_height,img_width);%����ͼ����ÿ����Ľǵ���Ӧ
    for i = 1:img_height
        for j = 1:img_width
            M = [Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)];%ƫ��������
            R(i,j) = det(M)-k*(trace(M))^2;%�ǵ���Ӧ����
            if R(i,j) > Rmax
                Rmax = R(i,j);
            end
        end
    end

    tmp = zeros(img_height+2,img_width+2);
    tmp(2:img_height+1,2:img_width+1) = R;
    
    [count,~] = size(candidate_list);
    extended_candidate_list = zeros(count,4);
    extended_candidate_list(:,1:2) = candidate_list;
    
    for i = 1:count
        y = extended_candidate_list(i,1);
        x = extended_candidate_list(i,2);
        extended_candidate_list(i,3) = R(y,x);
        
        satisfied_condition = 0;
        if tmp(y+1,x+1)>tmp(y,x)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y+1,x)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y+2,x)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y,x+1)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y+2,x+1)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y,x+2)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y+1,x+2)
            satisfied_condition = satisfied_condition +1;
        end
        if tmp(y+1,x+1)>tmp(y+2,x+2)
            satisfied_condition = satisfied_condition +1;
        end
        extended_candidate_list(i,4) =  satisfied_condition;
    end
    
    %��������,����Ҫ��ǵ���Ӧǿ�Ⱦ����Ǿֲ���ֵ,���Ҫ��ǵ���Ӧǿ��Խ��Խ��
    extended_candidate_list = sortrows(extended_candidate_list,[4 3]);
    extended_candidate_list = flipud(extended_candidate_list);%ת�ɽ�������
    
    if (extended_candidate_list(min_corner_num,4) == 8) && (extended_candidate_list(min_corner_num,3) > 0.01*Rmax)
        sum = 0;
        for i = 1:count
            if (extended_candidate_list(i,4) == 8) && (extended_candidate_list(i,3) > 0.01*Rmax)
                sum = sum+1;
            end
        end
        corner_list = extended_candidate_list(1:sum,1:2);
    else
        corner_list = extended_candidate_list(1:min_corner_num,1:2);
    end
end
