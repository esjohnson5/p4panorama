function H = calcH(p1, p2)
%
% Calculates the 3 x 3 homography matrix based on matching features points
% in two images, called image1 and image2.
% Pre-conditions:
%     `p1` is an n x 2 matrix containing n feature points, where each row
%     holds the coordinates of a feature point in image1, and
%     `p2` is an n x 2 matrix where each row holds the coordinates of a
%     corresponding point in image2.  
% Post-conditions:
%     H is the 3 x 3 homography matrix, such that 
%     p1_homogeneous = H * [p2 ones(size(p2, 1), 1)]'
%     p1_homogeneous contains the transformed homogeneous coordinates of
%     p2 from image2 to image1.

n = size(p1, 1);
if n < 4
    error('Not enough points');
end
H = zeros(3, 3);  % Homography matrix to be returned

%------------- YOUR CODE STARTS HERE -----------------
% 
% The following code computes an homography matrix, H, using all feature points
% in p1 and p2. Modify it to compute a homography matrix using the inliers
% of p2 and p2 as determined by RANSAC.
% The code solves for H by solving a linear system of equations of the form Ax=b
% where x is a 9 x 1 column vector that is being solved for and which defines
% the desired homography matrix, H.  One way of defining A and b is given in the
% lecture notes in the slides titled "Solving for Homography" where A is 2n x 9
% and b is a 2n x 1 vector of 0's.  Alternatively, but equivalently, in the code 
% below A and b are defined using each pair of corresponding points' homogeneous
% coordinates, and A is a 3n x 9 matrix and b is a 3n x 1 column vector.  

A = zeros(n*3,9);
b = zeros(n*3,1);
max = 0;
for j=1:100
    r = randsample(n,4);
    for i=1:4
        A(3*(i-1)+1,1:3) = [p2(r(i),:),1];
        A(3*(i-1)+2,4:6) = [p2(r(i),:),1];
        A(3*(i-1)+3,7:9) = [p2(r(i),:),1];
        b(3*(i-1)+1:3*(i-1)+3) = [p1(r(i),:),1];    
    end
    x = (A\b)';
    H = [x(1:3); x(4:6); x(7:9)];
    count = 0;
    for k=1:n
        pp = [p2(k,:),1];
        pp = pp(:);
        q = H*pp;
        qx = q(1);
        qy = q(2);
        q1 = [qx,qy];   
        ed = sqrt((qx-p1(k,1).^2+(qy-p1(k,1)).^2));
        if (ed < 3)
            count = count+1;
            index(count) = k;
        end   
    end
    if (count > max)
        max = count;
        H_max = H;
        index_max = index;
    end
end

for i=1:length(index_max)
    A(3*(i-1)+1,1:3) = [p2(index_max(i),:),1];
    A(3*(i-1)+2,4:6) = [p2(index_max(i),:),1];
    A(3*(i-1)+3,7:9) = [p2(index_max(i),:),1];
    b(3*(i-1)+1:3*(i-1)+3) = [p1(index_max(i),:),1];    
end
x = (A\b)';
H = [x(1:3); x(4:6); x(7:9)];
end

%------------- YOUR CODE ENDS HERE -----------------