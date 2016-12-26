%输入:uint8灰度图像last_frame,uint8灰度图像this_frame,逻辑值this_frame是否是第一帧is_first_frame,上一帧的边界last_boundary,需要维持的全局变量opticalFlow
%输出:投影变换H,当前帧边界this_contour,需要维持的全局变量opticalFlow
function [H,this_boundary,opticalFlow,this_corner_list,estimated_corner_list,flow] = object_tracking(last_frame,this_frame,is_first_frame,last_boundary,opticalFlow)
    %% 第一帧进行光流初始化
    
    if is_first_frame == true 
        %opticalFlow = opticalFlowLKDoG('NumFrames',3);
        %opticalFlow = opticalFlowFarneback;
        opticalFlow = opticalFlowHS; %opticalFlowLK在很多地方值都为0
        this_corner_list = [];
        estimated_corner_list = [];
        flow = estimateFlow(opticalFlow,this_frame);
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        return
    end
    
    %% 
    
    [img_height,img_width] = size(this_frame);

    %求出上一帧到这一帧的光流
    %opticalFlow = opticalFlowHS;
    %flow = estimateFlow(opticalFlow,last_frame);
    flow = estimateFlow(opticalFlow,this_frame);
    
    last_boundary_list = matrix2list(last_boundary,1);
    [last_boundary_count,~] = size(last_boundary_list);
    
    %膨胀一次，增加candidate数量
    se = ones(8,8);
    candidate_matrix = imdilate(last_boundary,se);
    candidate_list = matrix2list(candidate_matrix,1);
    
    %估计投影变换需要至少4对corner,因此要求harris返回上一帧至少4个corner
    this_corner_list = harris(this_frame,candidate_list,8); %只搜索candidate中是否有交点
    %this_corner_list = harris(this_frame); %所有全局的角点
    
    estimated_corner_list = this_corner_list;%找到的角点根据光流法对应出的这一帧的位置
    [count,~] = size(estimated_corner_list);
    for i = 1:count %计算上一帧的角点按照光流法,这一帧应该到哪了
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

    %'similarity'效果不好
    [tform, ~, ~, status] = estimateGeometricTransform(fliplr(this_corner_list),fliplr(estimated_corner_list),'affine');
    %[tform, ~, ~, status] = estimateGeometricTransform(fliplr(this_corner_list),fliplr(estimated_corner_list),'projective');
    if status == 2 %如果估计投影变换时inlier太少，认为两帧之间没有运动
        warning('inlier not enough');
        H = [1,0,0;0,1,0;0,0,1];
        this_boundary = last_boundary;
        return
    end
    
    %% 使用vision.PointTracker找两帧之间的变换关系
    
    %初始化vision.PointTracker
    imagePoints1 = detectMinEigenFeatures(last_frame, 'MinQuality', 0.1);  
    tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);  
    imagePoints1 = imagePoints1.Location;  
    initialize(tracker, imagePoints1, last_frame);  
   
    %vision.PointTracker
    [imagePoints2, validIdx] = step(tracker, this_frame);  
    matchedPoints1 = imagePoints1(validIdx, :);  
    matchedPoints2 = imagePoints2(validIdx, :);  
    
    [tform, ~, ~, status] = estimateGeometricTransform(matchedPoints1,matchedPoints2,'projective');
    

    %% 根据投影变换H，上一帧的boundary位置，估计这一帧的boundary位置
    
    H = tform.T';%从角点位置变换,得到两帧之间的投影变换关系
    
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
    %this_boundary = imclose(this_boundary,strel('disk',3)); %修整轮廓

end
