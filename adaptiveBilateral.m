function smoothImageGroup = adaptiveBilateral(adjImageGroup,adjIntensityMethod,flipImage, bitsPerPixel, adjIntensity)
%  smoothImageGroup = adaptiveBilateral(adjImageGroup,adjIntensityMethod,flipImage, bitsPerPixel, adjIntensity)
%       adjImageGroup       is a matrix of images.
%       adjIntensityMethod  is a method for adjust intensity AFTER applying
%                           adaptive bilateral filter to obtain some detail back
%                           It can be 'linear','nonlinear','histeq','adapthisteq'.
%                           Normally 'linear' produces good results with
%                           simplicity. So if adjIntensityMethod=[],
%                           'linear' will be used.
%       flipImage is 1 if the OCT images are acquired from bottom to top, otherwise is 0.
%       bitsPerPixel is a number of bits used for grayscale. General images
%                           are 8 bps, while HD-OCT images are 16 bps.
%       adjIntensity is an option if intensity is needed to adjust.
%
%  This code requires bilateralFilter.m of <Jiawen Chen, Sylvain Paris, and
%  Fredo Durand>, which is called 'bilateralFilterFast' here.

% v.1 23/02/12 by Pui Anantrasirichai, University of Bristol
% Any use of part of this code, please cite our paper 
% N. Anantrasirichai, L. Nicholson, J. E. Morgan, I. Erchova, and Alin
% Achim, "Adaptive-weighted bilateral filtering for Optical Coherence Tomography". 
% In Proceedings of the IEEE International Conference on Image Processing (ICIP 2013)
% Questions and comments please contact n.anantrasirichai@bris.ac.uk

if nargin < 4
    adjIntensity = 0;
end
if nargin < 5
    adjIntensity = 1;
end
if isempty(adjIntensityMethod)
    adjIntensityMethod = 'linear';
end

numBscan = size(adjImageGroup,3);
smoothImageGroup = zeros(size(adjImageGroup));

for f = 1:numBscan
    adjImage = real(adjImageGroup(:,:,f));
    smoothImage5 = bilateralFilterFast( adjImage, adjImage, 5);
    smoothImage20 = bilateralFilterFast( adjImage, adjImage, 20);
    % finding weight - using entropy
    if bitsPerPixel==16
        J = entropyfilt(uint16(adjImage));
    else
        J = entropyfilt(uint8(adjImage));
    end
    meansmallJ = mean(mean(J(5:20,:)));
    weight1 = (J-meansmallJ)/max((J(:)-meansmallJ));
    weight1(weight1<0) = 0;
    I1 = smoothImage5.*(1-weight1) + weight1.*smoothImage20;
    % put some details back
    weightd = adjust_intensity(adjImage,adjIntensityMethod,~flipImage,bitsPerPixel);
    weightd = weightd./max(weightd(:));
    smoothImage = I1.*(1-weightd) + adjImage.*weightd;
    % final intensity stretching
    if adjIntensity
        if bitsPerPixel==16
            smoothImage = double(imadjust(uint16(smoothImage),max(0,min(1,[min(smoothImage(:)) max(smoothImage(:))]/(2^bitsPerPixel-1))),[]));
        else
            smoothImage = double(imadjust(uint8(smoothImage),max(0,min(1,[min(smoothImage(:)) max(smoothImage(:))]/(2^bitsPerPixel-1))),[]));
        end
    end
    smoothImageGroup(:,:,f) = smoothImage;
end

