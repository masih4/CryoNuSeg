function [sRegions] = ROIs2Regions(cvsROIs, vnImageSize)

% ROIs2Regions - FUNCTION Convert a set of imported ImageJ ROIs into a Matlab regions structure
%
% Usage: [sRegions] = ROIs2Regions(cvsROIs, vnImageSize)
%
% 'cvsROIs' is a cell array of ImageJ ROI structures, as imported by
% ReadImageJROI. 'vnImageSize' is a vector [M N] containing the size of the
% image in pixels.
%
% 'sRegions' will be a structure compatible with the Matlab regions
% structure format, as returned by bwconncomp. It will contain one region
% for each compatible ROI in 'cvsROIs'.
%
% Only a subset of ImageJ ROI types is supported for conversion:
% 'rectangle', oval', 'polygon' and 'freehand'.

% Author: Dylan Muir <muir@hifo.uzh.ch>
% Created: 2011

% - Check arguments

if (nargin < 2)
   disp('*** ROIs2Regions: Incorrect usage.');
   help ROIs2Regions;
   return;
end

% - Build a regions structure
sRegions.Connectivity = 8;
sRegions.ImageSize = vnImageSize;
sRegions.NumObjects = numel(cvsROIs);
sRegions.PixelIdxList = {};

for (nROIIndex = numel(cvsROIs):-1:1)
   sThisROI = cvsROIs{nROIIndex};
   
   switch (lower(sThisROI.strType))
      case 'rectangle'
         if (isfield(sThisROI, 'strSubtype') && isequal(lower(sThisROI.strSubtype), 'shape'))
            % - Skip this one
            continue;
            
         else
            % - Make a rectangular mask
            mbThisMask = false(vnImageSize);
            sThisROI.vnRectBounds = sThisROI.vnRectBounds + 1;
            mbThisMask(sThisROI.vnRectBounds(1):sThisROI.vnRectBounds(3), sThisROI.vnRectBounds(2):sThisROI.vnRectBounds(4)) = true;
            sRegions.PixelIdxList{nROIIndex} = find(mbThisMask');
         end
         
      case 'oval'
         % - Draw an oval inside the bounding box
         mbThisMask = ellipse2mask('bounds', vnImageSize, sThisROI.vnRectBounds+1);
         sRegions.PixelIdxList{nROIIndex} = find(mbThisMask');
         
      case {'polygon'; 'freehand'}
         % - Draw a polygonal mask
         mbThisMask = poly2mask(sThisROI.mnCoordinates(:, 1)+1, sThisROI.mnCoordinates(:, 2)+1, vnImageSize(1), vnImageSize(2));
         sRegions.PixelIdxList{nROIIndex} = find(mbThisMask');
         
      otherwise
         warning( 'ROIs2Regions:unsupported', ...
                  '--- ROIs2Regions: Warning: Unsupported ROI type.');
   end
end

% --- END of ROIs2Regions.m ---
