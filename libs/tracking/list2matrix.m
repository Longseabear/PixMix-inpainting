%yuzhang
%����:list(n��2��),��ԭֵtarget_value,��ԭ�ľ���ĳߴ�[height,width];
%���:matrix(height��width��,��list��ǵ�λ��ȡֵΪtarget_value,����λ��ȡֵΪ0)
function [matrix] = list2matrix(list,target_value,height,width)
    matrix = zeros(height,width);
    [count,~] = size(list);
    for i = 1:count
        y = list(i,1);
        x = list(i,2);
        if (y <= height) && (y >= 1) && (x <= width) && (x >= 1)
            matrix(y,x) = target_value;
        end
    end
end