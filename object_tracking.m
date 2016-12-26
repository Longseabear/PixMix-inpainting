%ʹ��ǰ��Ҫ��addpath(genpath('libs/tracking'));
%����:uint8�Ҷ�ͼ��last_frame,uint8�Ҷ�ͼ��this_frame,�߼�ֵthis_frame�Ƿ��ǵ�һ֡is_first_frame,��һ֡�ı߽�last_boundary,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
%���:ͶӰ�任H,��ǰ֡�߽�this_contour,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
function [H,this_boundary,opticalFlow,last_corner_list,flow] = object_tracking(last_frame,this_frame,is_first_frame,last_boundary,opticalFlow)
    %% ��һ֡���й�����ʼ��
    
    if is_first_frame == true 
        opticalFlow = opticalFlowLK('NoiseThreshold',0.009);
        last_corner_list = [];
        flow = estimateFlow(opticalFlow,this_frame);
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        return
    end
    
    %% 
    
    [img_height,img_width] = size(this_frame);

    %�����һ֡����һ֡�Ĺ���
    opticalFlow = opticalFlowLK('NoiseThreshold',0.009);
    flow = estimateFlow(opticalFlow,last_frame);
    flow = estimateFlow(opticalFlow,this_frame);
    
    %flow = estimateFlow(opticalFlow,this_frame);
    max(max(flow.Vx))
    
    %figure,plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    
    last_boundary_list = matrix2list(last_boundary,1);
    [last_boundary_count,~] = size(last_boundary_list);
    
    %����һ�Σ�����candidate����
    se = ones(4,4);
    candidate_matrix = imdilate(last_boundary,se);
    candidate_list = matrix2list(candidate_matrix,1);
    
    %����ͶӰ�任��Ҫ����4��corner,���Ҫ��harris������һ֡����4��corner
    %last_corner_list = harris(last_frame,candidate_list,4); %ֻ����candidate���Ƿ��н���
    last_corner_list = harris(last_frame); %����ȫ�ֵĽǵ�
    
    matchedpoints_last = last_corner_list;%�ҵ�����һ֡�Ľǵ�λ��
    
    matchedpoints_this = matchedpoints_last;%�ҵ��Ľǵ���ݹ�������Ӧ������һ֡��λ��
    [count,~] = size(matchedpoints_this);
    for i = 1:count %������һ֡�Ľǵ㰴�չ�����,��һ֡Ӧ�õ�����
        last_y = matchedpoints_last(i,1);
        last_x = matchedpoints_last(i,2);
       
        dx = round(flow.Vx(last_y,last_x));
        dy = round(flow.Vy(last_y,last_x));
        
        this_y = last_y+dy;
        this_x = last_x+dx;
        
        this_y = max(min(this_y,img_height),1);
        this_x = max(min(this_x,img_width),1);
        
        matchedpoints_this(i,:) = [this_y,this_x];
    end

    [tform, ~, ~, status] = estimateGeometricTransform(fliplr(matchedpoints_last),fliplr(matchedpoints_this),'projective');
    if status == 2 %�������ͶӰ�任ʱinlier̫�٣���Ϊ��֮֡��û���˶�
        warning('inlier not enough');
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        
        return
    end
    
    H = tform.T%�ӽǵ�λ�ñ任,�õ���֮֡���ͶӰ�任��ϵ

    %% ����ͶӰ�任H����һ֡��boundaryλ�ã�������һ֡��boundaryλ��
    
    this_boundary_list = fliplr(last_boundary_list);
    for i = 1:last_boundary_count
        cur_point = this_boundary_list(i,:);
        extended_cur_point = [cur_point';1];
        transformed_extended_cur_point = H'*extended_cur_point;
        transformed_x = round(transformed_extended_cur_point(1) / transformed_extended_cur_point(3));
        transformed_y = round(transformed_extended_cur_point(2) / transformed_extended_cur_point(3));
        this_boundary_list(i,:) = [transformed_y,transformed_x];
    end

    this_boundary = list2matrix(this_boundary_list,1,img_height,img_width);
    this_boundary = imclose(this_boundary,strel('disk',3)); %��������

end
