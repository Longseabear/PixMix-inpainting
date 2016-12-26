%����:rgbͼ��last_frame,rgbͼ��this_frame,�߼�ֵthis_frame�Ƿ��ǵ�һ֡is_first_frame,��һ֡�ı߽�last_boundary,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
%���:ͶӰ�任H,��ǰ֡�߽�this_contour,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
function [H,this_boundary,opticalFlow,this_corner_list,estimated_corner_list,flow] = object_tracking(last_frame,this_frame,is_first_frame,last_boundary,opticalFlow)

    uint8_this_frame = im2uint8(rgb2gray(this_frame));
    
    %% ��һ֡���й�����ʼ��
    
    if is_first_frame == true 
        %opticalFlow = opticalFlowLKDoG('NumFrames',3);
        %opticalFlow = opticalFlowFarneback;
        opticalFlow = opticalFlowHS; %opticalFlowLK�ںܶ�ط�ֵ��Ϊ0
        this_corner_list = [];
        estimated_corner_list = [];
        flow = estimateFlow(opticalFlow,uint8_this_frame);
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        return
    end
    
    %% 
    
    uint8_last_frame = im2uint8(rgb2gray(last_frame));
    [img_height,img_width] = size(uint8_this_frame);

    %�����һ֡����һ֡�Ĺ���
    %opticalFlow = opticalFlowHS;
    %flow = estimateFlow(opticalFlow,last_frame);
    flow = estimateFlow(opticalFlow,uint8_this_frame);
    
    last_boundary_list = matrix2list(last_boundary,1);
    [last_boundary_count,~] = size(last_boundary_list);
    
    %����һ�Σ�����candidate����
    se = ones(8,8);
    candidate_matrix = imdilate(last_boundary,se);
    candidate_list = matrix2list(candidate_matrix,1);
    
    %����ͶӰ�任��Ҫ����4��corner,���Ҫ��harris������һ֡����4��corner
    this_corner_list = harris(uint8_this_frame,candidate_list,8); %ֻ����candidate���Ƿ��н���
    %this_corner_list = harris(this_frame); %����ȫ�ֵĽǵ�
    
    estimated_corner_list = this_corner_list;%�ҵ��Ľǵ���ݹ�������Ӧ������һ֡��λ��
    [count,~] = size(estimated_corner_list);
    for i = 1:count %������һ֡�Ľǵ㰴�չ�����,��һ֡Ӧ�õ�����
        this_y = this_corner_list(i,1);
        this_x = this_corner_list(i,2);
       
        dx = flow.Vx(this_y,this_x);
        dy = flow.Vy(this_y,this_x);
        
        this_y = round(this_y+30*dy);
        this_x = round(this_x+30*dx);
        
        this_y = max(min(this_y,img_height),1);
        this_x = max(min(this_x,img_width),1);
        
        estimated_corner_list(i,:) = [this_y,this_x];
    end

    %'similarity'Ч������
    [tform, ~, ~, status] = estimateGeometricTransform(fliplr(this_corner_list),fliplr(estimated_corner_list),'affine');
    %[tform, ~, ~, status] = estimateGeometricTransform(fliplr(this_corner_list),fliplr(estimated_corner_list),'projective');
    if status == 2 %�������ͶӰ�任ʱinlier̫�٣���Ϊ��֮֡��û���˶�
        warning('inlier not enough');
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        return
    end
    
    %% ʹ��vision.PointTracker����֮֡��ı任��ϵ
    
    %��ʼ��vision.PointTracker
    imagePoints1 = detectMinEigenFeatures(uint8_last_frame, 'MinQuality', 0.1);  
    tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);  
    imagePoints1 = imagePoints1.Location;  
    initialize(tracker, imagePoints1, uint8_last_frame);  
   
    %vision.PointTracker
    [imagePoints2, validIdx] = step(tracker, uint8_this_frame);  
    matchedPoints1 = imagePoints1(validIdx, :);  
    matchedPoints2 = imagePoints2(validIdx, :);  
    
    [tform, ~, ~, status] = estimateGeometricTransform(matchedPoints1,matchedPoints2,'projective');
    

    %% ����ͶӰ�任H����һ֡��boundaryλ�ã�������һ֡��boundaryλ��
    
    H = tform.T';%�ӽǵ�λ�ñ任,�õ���֮֡���ͶӰ�任��ϵ
    
    this_boundary_list = fliplr(last_boundary_list);
    for i = 1:last_boundary_count
        cur_point = this_boundary_list(i,:);
        extended_cur_point = [cur_point';1];
        transformed_extended_cur_point = H*extended_cur_point;
        transformed_x = round(transformed_extended_cur_point(1) / transformed_extended_cur_point(3));
        transformed_y = round(transformed_extended_cur_point(2) / transformed_extended_cur_point(3));
        this_boundary_list(i,:) = [transformed_y,transformed_x];
    end

    this_boundary = list2matrix(this_boundary_list,1,img_height,img_width);
    
    
    %%
    
    %this_boundary = imclose(this_boundary,strel('disk',3)); %��������
    
%     se = ones(8,8);
%     this_boundary = imdilate(this_boundary,se);
%     this_boundary_list = matrix2list(this_boundary,1);
%     
%     this_boundary_list_y = this_boundary_list(:,1);
%     this_boundary_list_x = this_boundary_list(:,2);
%     
%     K = convhull(this_boundary_list_x,this_boundary_list_y);
%     this_boundary_list = [this_boundary_list_y(K),this_boundary_list_x(K)];
%     
%     [X,Y] = meshgrid(1:img_height,1:img_width);
%     
%     this_boundary = inpolygon(X,Y,this_boundary_list(:,2),this_boundary_list(:,1));
%     this_boundary = edge(this_boundary, 'sobel');
%     this_boundary_list = matrix2list(this_boundary,1);
%     
%     se = strel('disk',4);
%     this_boundary = maxLianTongYu_smallst(imclose(detect_obj_smallst(this_frame, fliplr(this_boundary_list)),se));   
%    
%     this_boundary = edge(this_boundary, 'sobel');

end
