%ʹ��ǰ��Ҫ��addpath(genpath('libs/tracking'));
%����:uint8�Ҷ�ͼ��last_frame,uint8�Ҷ�ͼ��this_frame,�߼�ֵthis_frame�Ƿ��ǵ�һ֡is_first_frame,��һ֡�ı߽�last_contour,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
%���:ͶӰ�任H,��ǰ֡�߽�this_contour,��Ҫά�ֵ�ȫ�ֱ���opticalFlow
function [H,this_contour,opticalFlow] = object_tracking(last_frame,this_frame,is_first_frame,last_contour,opticalFlow)
    if is_first_frame == true
        opticalFlow = opticalFlowLK('NoiseThreshold',0.009);
        estimateFlow(opticalFlow,this_frame);
        H = [1,0,0;0,1,0;0,0,1];
        this_contour = last_contour;
        return
    end

    %�����һ֡����һ֡�Ĺ���
    flow = estimateFlow(opticalFlow,this_frame);
    %figure,plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)

    %����ͶӰ�任��Ҫ����4��corner,���Ҫ��harris������һ֡����4��corner
    last_contour_list = matrix2list(last_contour);
    last_corner_list = harris(last_frame,last_contour_list,4);

    matchedpoints_last = last_corner_list;%�ҵ�����һ֡�Ľǵ�λ��
    matchedpoints_this = matchedpoints_last;%�ҵ��Ľǵ���ݹ�������Ӧ������һ֡��λ��

    [count,~] = size(matchedpoints_this);
    for i = 1:count %������һ֡�Ľǵ㰴�չ�����,��һ֡Ӧ�õ�����
        x = matchedpoints_this(i,1);
        y = matchedpoints_this(i,2);
        vx = round(flow.Vx(x,y));
        vy = round(flow.Vy(x,y));
        matchedpoints_this(i,:) = [x+vx,y+vy];
    end

    tform = estimateGeometricTransform(matchedpoints_last,matchedpoints_this,'projective');
    H = tform.T;%�ӽǵ�λ�ñ任,�õ���֮֡���ͶӰ�任��ϵ

    last_contour_list = matrix2list(last_contour,1);
    [last_contour_height,~] = size(last_contour_list);

    this_contour_list = last_contour_list;
    for i = 1:last_contour_height
        cur_point = last_contour_list(i,:);
        extended_cur_point = [cur_point';1];
        transformed_extended_cur_point = H*extended_cur_point;
        transformed_x = transformed_extended_cur_point(1) / transformed_extended_cur_point(3);
        transformed_y = transformed_extended_cur_point(2) / transformed_extended_cur_point(3);
        this_contour_list(i,:) = [transformed_x,transformed_y];
    end

    this_contour = list2matrix(this_contour_list,1,height,width);

end
