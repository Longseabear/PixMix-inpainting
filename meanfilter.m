function RGB_Average  = meanfilter(img, num)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
 average = fspecial('average',num);
 RGB_Average = imfilter(img, average);
end
