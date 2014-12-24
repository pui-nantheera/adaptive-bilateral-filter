function refFrameInt_adjust = adjustIntensityFromROI(refFrameInt,min_in,max_in, gammadark,gammabright, midpoint)

if nargin < 6
    midpoint = (max_in - min_in)/2;
end
maxvalue = 255;
if max(refFrameInt(:))>maxvalue
    maxvalue = 2^16.0-1;
end
% adjust darkarea
darkarea = (refFrameInt<min_in+midpoint).*(refFrameInt>(min_in-midpoint/2));
ROIcontrast_dark = imadjust(double(refFrameInt)/maxvalue,[max(1,min_in-midpoint/2) min_in+midpoint]/maxvalue,[max(1,min_in-midpoint/2) min_in+midpoint]/maxvalue,gammadark)*maxvalue;
% adjust brightarea
brightarea = (refFrameInt>min_in+midpoint).*(refFrameInt<(max_in+midpoint/2));
ROIcontrast_bright = imadjust(double(refFrameInt)/maxvalue,[min_in+midpoint min(maxvalue,max_in+midpoint/2)]/maxvalue,[min_in+midpoint min(maxvalue,max_in+midpoint/2)]/maxvalue,gammabright)*maxvalue;

refFrameInt_adjust = double(ROIcontrast_dark).*darkarea + double(ROIcontrast_bright).*brightarea + double(refFrameInt).*~(darkarea + brightarea);


