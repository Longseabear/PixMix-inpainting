%yuzhang
%����:matrix,��ѯĿ��target_value
%���:list(n��2��,�洢matrix������ֵΪtraget_value�ĵ������[y(height),x(width)])
function [list] = matrix2list(matrix,target_value)
%     [height,width] = size(matrix);
    [row, col] = find(matrix == target_value);
    list = [row, col];
end

% function [list] = matrix2list(matrix,target_value)
%     [height,width] = size(matrix);
%     count = sum(matrix(:)==target_value);
%     list = zeros(count,2);
%     index = 1;
%     for y = 1:height
%         for x = 1:width
%             if matrix(y,x) == target_value
%                 list(index,:) = [y,x];
%                 index = index +1;
%             end
%         end
%     end
% end