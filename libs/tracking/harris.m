%% yuzhang
%����:uint8�Ҷ�ͼ��img,n��2�о���candidate_list�洢�����ǽǵ�ĵ������[y(height),x(width)],Ҫ���⵽�����ٵĽǵ���min_corner_num
%����img,candidate_list(��ѡ),min_corner_num(��ѡ)
%���:�궨�Ľǵ������б�n��2�е�corner_list,�洢��ʽ[y(height),x(width)]

%% ����
% img = imread('building.jpg');
% img = im2uint8(rgb2gray(img));
% [height,width] = size(img);
% corner_list = harris(img);
% corner_matrix = list2matrix(corner_list,1,height,width);
% imshow(corner_matrix);

%Harris�ǵ���Գ߶�����
function [corner_list] = harris(varargin)
    %% ����䳤����
    input_var_length = length(varargin);
    if input_var_length == 0
        warning('error');
    else %input_var_length >=1
        img = varargin{1};
        candidate_list = []; %candidate_list = []ʱ��Ϊû��candidateԼ��,ȫ�ּ��
        min_corner_num = -1; %min_corner_num = -1ʱ��Ϊû��min_corner_numԼ��,�ж��ٸ�����ǵ�,���ض��ٸ��ǵ�
        if input_var_length >= 2
            candidate_list = varargin{2};
            if input_var_length >=3
                min_corner_num = varargin{3};
            end
        end
    end
    
    %% ���+ƽ��
    
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

    %% ���ݲ�ֽ�����������Ӧ
    
    [img_height, img_width] = size(img);
    Rmax = 0;
    k = 0.06; %��ȡ0.04-0.06
    R = zeros(img_height,img_width); %����ͼ����ÿ����Ľǵ���Ӧ
    for i = 1:img_height
        for j = 1:img_width
            M = [Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)]; %ƫ��������
            R(i,j) = det(M)-k*(trace(M))^2; %�ǵ���Ӧ����
            if R(i,j) > Rmax
                Rmax = R(i,j);
            end
        end
    end

    if isempty(candidate_list) == 0 %���ָ����candidate_list��������С���㷶Χ
        %% ����ÿ����������ж��ٸ��ڵ���Ӧ����

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
            directions = [ -1,-1 ; -1,0 ; -1,1 ; 0,-1 ; 0,1 ; 1,-1 ; 1,0 ; 1,1]; %8����
            for j = 1:length(directions) %����ÿ���ڵ��directions�洢�������ж��ٸ��ڵ����
                dx = directions(j,1);
                dy = directions(j,2);
                biasx = 1;
                biasy = 1;
                if tmp(y+biasy,x+biasx) > tmp(y+biasy+dy,x+biasx+dx)
                    satisfied_condition = satisfied_condition + 1;
                end
            end
            extended_candidate_list(i,4) =  satisfied_condition;
        end

        %% ��������,����Ҫ��ǵ���Ӧǿ�Ⱦ����Ǿֲ���ֵ,���Ҫ��ǵ���Ӧǿ��Խ��Խ��

        extended_candidate_list = sortrows(extended_candidate_list,[4 3]);
        extended_candidate_list = flipud(extended_candidate_list);%ת�ɽ�������

        %��������������һ��ǵ㣬����������min_corner_num��Ҫ��
        if count < min_corner_num %���Ҫ���corner���������п��ܵ�candidate����,�Ͱ����е�candidate����Ϊ�ǵ�
            corner_list = extended_candidate_list(1:count,1:2);
        elseif (extended_candidate_list(min_corner_num,4) == 8) && (extended_candidate_list(min_corner_num,3) > 0.01*Rmax) %���ȷ����������min_corner_num�����ʽǵ�
            sum = 0;
            for i = 1:count
                if (extended_candidate_list(i,4) == 8) && (extended_candidate_list(i,3) > 0.01*Rmax)
                    sum = sum+1;
                end
            end
            corner_list = extended_candidate_list(1:sum,1:2);%��󷵻����е����ʽǵ�
        else %���candidate�ܶ࣬�����ʽǵ㲻�࣬�򷵻�min_corner_num�������õ�candidate
            corner_list = extended_candidate_list(1:min_corner_num,1:2);
        end
    else %û��ָ��candidate_listʱҪ������ͼ�����
        tmp = zeros(img_height+2,img_width+2);
        tmp(2:img_height+1,2:img_width+1) = R;
        img_re = zeros(img_height+2,img_width+2);
        for i = 2:img_height+1
            for j = 2:img_width+1
                if tmp(i,j)>0.01*Rmax &&...
                   tmp(i,j)>tmp(i-1,j-1) && tmp(i,j)>tmp(i-1,j) && tmp(i,j)>tmp(i-1,j+1) &&...
                   tmp(i,j)>tmp(i,j-1) && tmp(i,j)>tmp(i,j+1) &&...
                   tmp(i,j)>tmp(i+1,j-1) && tmp(i,j)>tmp(i+1,j) && tmp(i,j)>tmp(i+1,j+1)
                        img_re(i,j)=1; %3*3������Ӧ,�ұ���ʷ�����Ӧ��0.01����ʱ����Ϊ�ǽǵ�
                end
            end
        end

        corner_matrix=zeros(img_height,img_width);
        corner_matrix(1:img_height,1:img_width)=img_re(2:img_height+1,2:img_width+1);
        
        corner_list = matrix2list(corner_matrix,1);
    end
end
