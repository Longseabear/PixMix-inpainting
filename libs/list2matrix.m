%yuzhang
%����:list(n��2��),��ԭֵtarget_value,��ԭ�ľ���ĳߴ�[height,width];
%���:matrix(height��width��,��list��ǵ�λ��ȡֵΪtarget_value,����λ��ȡֵΪ0)
function [matrix] = list2matrix(list,target_value,height,width)
    matrix = zeros(height,width);
    [list_height,~] = size(list);
    for i = 1:list_height
        x = list(i,1);
        y = list(i,2);
        matrix(x,y) = target_value;
    end
end