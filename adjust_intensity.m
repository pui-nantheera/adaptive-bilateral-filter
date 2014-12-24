function matrixBscan = adjust_intensity(matrixBscan,adjIntensityMethod,flipImage, bitsPerPixel)

numBscans = size(matrixBscan,3);
if strcmp(adjIntensityMethod,'linear')
    for f = 1:numBscans
        temp = matrixBscan(:,:,f);
        
        if flipImage
            minValue = mean(temp(2,:)); % prevent speckles
        else
            minValue = mean(temp(end-1,:));
        end
        maxValue = max(temp(:));
        if bitsPerPixel==16
            matrixBscan(:,:,f) = double(imadjust(uint16(temp),max(0,min(1,[minValue maxValue]/(2^bitsPerPixel-1))),[]));
        else
            matrixBscan(:,:,f) = double(imadjust(uint8(temp),max(0,min(1,[minValue maxValue]/(2^bitsPerPixel-1))),[]));
        end
    end
elseif strcmp(adjIntensityMethod,'nonlinear')
    for f = 1:numBscans
        temp = matrixBscan(:,:,f);
        
        if flipImage
            minValue = mean(temp(2,:)); % prevent speckles
        else
            minValue = mean(temp(end-1,:));
        end
        maxValue = max(temp(:));
        if bitsPerPixel==16
            temp = double(imadjust(uint16(temp),[minValue maxValue]/(2^bitsPerPixel-1),[]));
        else
            temp = double(imadjust(uint8(temp),[minValue maxValue]/(2^bitsPerPixel-1),[]));
        end
        midpoint = mean(temp(:));
        matrixBscan(:,:,f) = adjustIntensityFromROI(temp,midpoint/2,0.5*(2^bitsPerPixel-1+midpoint), 0.8,1.2, midpoint);
    end
elseif strcmp(adjIntensityMethod,'histeq')
    for f = 1:numBscans
        if bitsPerPixel==16
            matrixBscan(:,:,f) = double(histeq(uint16(matrixBscan(:,:,f))));
        else
            matrixBscan(:,:,f) = double(histeq(uint8(matrixBscan(:,:,f))));
        end
    end
elseif strcmp(adjIntensityMethod,'adapthisteq')
    for f = 1:numBscans
        temp = matrixBscan(:,:,f);
        minValue = mean(temp(2,:)); % prevent speckles
        maxValue = max(temp(:));
        if bitsPerPixel==16
            temp = double(imadjust(uint16(temp),[minValue maxValue]/(2^bitsPerPixel-1),[]));
        else
            temp = double(imadjust(uint8(temp),[minValue maxValue]/(2^bitsPerPixel-1),[]));
        end
        matrixBscan(:,:,f) = double(adapthisteq(uint16(temp)));
    end
end
