%yuzhang
%����:matrix,��ѯĿ��target_value
%���:list(n��2��,�洢matrix������ֵΪtraget_value�ĵ������)
function [list] = matrix2list(matrix,target_value)
    [height,length] = size(matrix);
    count = 0;
    for i = 1:height
        for j = 1:length
            if matrix(i,j) == target_value
                count = count + 1;
            end
        end
    end
    
    list = zeros(count,2);
    index = 1;
    for i = 1:height
        for j = 1:length
            if matrix(i,j) == target_value
                list(index,:) = [i,j];
                index = index +1;
            end
        end
    end
end