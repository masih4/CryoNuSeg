function [sROI] = ReadImageJROI(cstrFilenames)

% ReadImageJROI - FUNCTION Read an ImageJ ROI into a matlab structure
%
% Usage: [sROI] = ReadImageJROI(strFilename)
%        [cvsROIs] = ReadImageJROI(cstrFilenames)
%        [cvsROIs] = ReadImageJROI(strROIArchiveFilename)
%
% This function reads the ImageJ binary ROI file format.
%
% 'strFilename' is the full path to a '.roi' file.  A list of ROI files can be
% passed as a cell array of filenames, in 'cstrFilenames'.  An ImageJ ROI
% archive can be access by providing a '.zip' filename in
% 'strROIArchiveFilename'.  Single ROIs are returned as matlab structures, with
% variable fields depending on the ROI type.  Multiple ROIs are returned as a
% cell array of ROI structures.
%
% The field '.strName' is guaranteed to exist, and contains the ROI name (the
% filename minus '.roi', or the name set for the ROI).
%
% The field '.strType' is guaranteed to exist, and defines the ROI type:
% {'Rectangle', 'Oval', Line', 'Polygon', 'Freehand', 'Traced', 'PolyLine',
% 'FreeLine', 'Angle', 'Point', 'NoROI'}.
%
% The field '.vnRectBounds' is guaranteed to exist, and defines the rectangular
% bounds of the ROI: ['nTop', 'nLeft', 'nBottom', 'nRight'].
%
% The field '.nVersion' is guaranteed to exist, and defines the version number
% of the ROI format.
%
% The field '.vnPosition' is guaranteed to exist. If the information is
% defined within the ROI, this field will be a three-element vector
% [nCPosition nZPosition nTPosition].
%
% ROI types:
%  Rectangle:
%     .strType = 'Rectangle';
%     .nArcSize         - The arc size of the rectangle's rounded corners
%
%      For a composite, 'shape' ROI:
%     .strSubtype = 'Shape';
%     .vfShapeSegments  - A long, complicated vector of complicated shape
%                          segments.  This vector is in the format passed to the
%                          ImageJ ShapeROI constructor.  I won't decode this for
%                          you! :(
%
%  Oval:
%     .strType = 'Oval';
%
%  Line:
%     .strType = 'Line';
%  	.vnLinePoints     - The end points of the line ['nX1', 'nY1', 'nX2', 'nY2']
%
%     With arrow:
%     .strSubtype = 'Arrow';
%     .bDoubleHeaded    - Does the line have two arrowheads?
%     .bOutlined        - Is the arrow outlined?
%     .nArrowStyle      - The ImageJ style of the arrow (unknown interpretation)
%     .nArrowHeadSize   - The size of the arrowhead (unknown units)
%
%  Polygon:
%     .strType = 'Polygon';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%  Freehand:
%     .strType = 'Freehand';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the polygon vertices.  Each row is [nX nY].
%
%     Ellipse subtype:
%     .strSubtype = 'Ellipse';
%     .vfEllipsePoints  - A vector containing the ellipse control points:
%                          [fX1 fY1 fX2 fY2].
%     .fAspectRatio     - The aspect ratio of the ellipse.
%
%  Traced:
%     .strType = 'Traced';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  PolyLine:
%     .strType = 'PolyLine';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  FreeLine:
%     .strType = 'FreeLine';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the line vertices.  Each row is [nX nY].
%
%  Angle:
%     .strType = 'Angle';
%     .mnCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the angle vertices.  Each row is [nX nY].
%
%  Point:
%     .strType = 'Point';
%     .mfCoordinates    - An [Nx2] matrix, specifying the coordinates of
%                          the points.  Each row is [fX fY].
%     .vnCounters       - An [Nx1] vector, specifying which counter is
%                          associated with each point. May be empty.
%     .vnSlices         - An [Nx1] vector, specifying on which plane each
%                          point is on. These are specified as linear
%                          indices, with the hyperstack arranged as
%                          [Channels Z-slices T-slices]. If empty, then all
%                          points are placed on the first slice.
%
%  NoROI:
%     .strType = 'NoROI';
%
% Additionally, ROIs from later versions (.nVersion >= 218) may have the
% following fields:
%
%     .nStrokeWidth     - The width of the line stroke
%     .nStrokeColor     - The encoded color of the stroke (ImageJ color format)
%     .nFillColor       - The encoded fill color for the ROI (ImageJ color
%                          format)
%
% If the ROI contains text:
%     .strSubtype = 'Text';
%     .nFontSize        - The desired font size
%     .nFontStyle       - The style of the font (unknown format)
%     .strFontName      - The name of the font to render the text with
%     .strText          - A string containing the text

% Author: Dylan Muir <dylan.muir@unibas.ch>
% Created: 9th August, 2011
%
% 20170118 Added code to read slice position for point ROIs
% 20141020 Added code to read 'header 2' fields; thanks to Luca Nocetti
% 20140602 Bug report contributed by Samuel Barnes and Yousef Mazaheri
% 20110810 Bug report contributed by Jean-Yves Tinevez
% 20110829 Bug fix contributed by Benjamin Ricca <ricca@berkeley.edu>
% 20120622 Order of ROIs in a ROI set is now preserved
% 20120703 Different way of reading zip file contents guarantees that ROI order
%           is preserved
%
% Copyright (c) 2011, 2012, 2013, 2014, 2015, 2016 Dylan Muir <dylan.muir@unibas.ch>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% -- Constants

bOpt_SubPixelResolution = 128;


% -- Check arguments

if (nargin < 1)
   disp('*** ReadImageJROI: Incorrect usage');
   help ReadImageJROI;
   return;
end


% -- Check for a cell array of ROI filenames

if (iscell(cstrFilenames))
   % - Read each ROI in turn
   cvsROI = cellfun(@ReadImageJROI, CellFlatten(cstrFilenames), 'UniformOutput', false);
   
   % - Return all ROIs
   sROI = cvsROI;
   return;
   
else
   % - This is not a cell string
   strFilename = cstrFilenames;
   clear cstrFilenames;
end


% -- Check for a zip file

[nul, nul, strExt] = fileparts(strFilename); %#ok<ASGLU>
if (isequal(lower(strExt), '.zip'))
   % - get zp file contents
   cstrFilenames_short = listzipcontents_rois(strFilename);
   
   % - Unzip the file into a temporary directory
   strROIDir = tempname;
   unzip(strFilename, strROIDir);
   
   for (nFileIndex = 1:length(cstrFilenames_short))
      cstrFilenames{1, nFileIndex} = [strROIDir '/' char(cstrFilenames_short(nFileIndex, 1))];
   end
   
   % - Build ROIs for each file
   cvsROIs = ReadImageJROI(cstrFilenames);
   
   % - Clean up temporary directory
   rmdir(strROIDir, 's');
   
   % - Return ROIs
   sROI = cvsROIs;
   return;
end


% -- Read ROI

% -- Check file and open
if (~exist(strFilename, 'file'))
   error('ReadImageJROI:FileNotFound', ...
      '*** ReadImageJROI: The file [%s] was not found.', strFilename);
end

fidROI = fopen(strFilename, 'r', 'ieee-be');

% -- Check file magic code
strMagic = fread(fidROI, [1 4], '*char');

if (~isequal(strMagic, 'Iout'))
   error('ReadImageJROI:FormatError', ...
      '*** ReadImageJROI: The file was not an ImageJ ROI format.');
end

% -- Read version
sROI.nVersion = fread(fidROI, 1, 'int16');

% -- Read ROI type
nTypeID = fread(fidROI, 1, 'uint8');
fseek(fidROI, 1, 'cof'); % Skip a byte

% -- Read rectangular bounds
sROI.vnRectBounds = fread(fidROI, [1 4], 'int16');

% -- Read number of coordinates
nNumCoords = fread(fidROI, 1, 'uint16');

% -- Read the rest of the header
vfLinePoints = fread(fidROI, 4, 'float32');
nStrokeWidth = fread(fidROI, 1, 'int16');
nShapeROISize = fread(fidROI, 1, 'uint32');
nStrokeColor = fread(fidROI, 1, 'uint32');
nFillColor = fread(fidROI, 1, 'uint32');
nROISubtype = fread(fidROI, 1, 'int16');
nOptions = fread(fidROI, 1, 'int16');
nArrowStyle = fread(fidROI, 1, 'uint8');
nArrowHeadSize = fread(fidROI, 1, 'uint8');
nRoundedRectArcSize = fread(fidROI, 1, 'int16');
sROI.nPosition = fread(fidROI, 1, 'uint32');


% -- Read the 'header 2' fields
nHeader2Offset = fread(fidROI, 1, 'uint32');

if (nHeader2Offset > 0) && ~fseek(fidROI, nHeader2Offset+32+4, 'bof') 
   % - Seek to start of header 2
   fseek(fidROI, nHeader2Offset+4, 'bof');
   
   % - Read fields
   sROI.vnPosition = fread(fidROI, 3, 'uint32')';
   vnNameParams = fread(fidROI, 2, 'uint32')';
   nOverlayLabelColor = fread(fidROI, 1, 'uint32'); %#ok<NASGU>
   nOverlayFontSize = fread(fidROI, 1, 'int16'); %#ok<NASGU>
   fseek(fidROI, 1, 'cof');   % Skip a byte
   nOpacity = fread(fidROI, 1, 'uint8'); %#ok<NASGU>
   nImageSize = fread(fidROI, 1, 'uint32'); %#ok<NASGU>
   fStrokeWidth = fread(fidROI, 1, 'float32'); %#ok<NASGU>
   vnROIPropertiesParams = fread(fidROI, 2, 'uint32')'; %#ok<NASGU>
   nCountersOffset = fread(fidROI, 1, 'uint32');
   
else
   sROI.vnPosition = [];
   vnNameParams = [0 0];
   nOverlayLabelColor = []; %#ok<NASGU>
   nOverlayFontSize = []; %#ok<NASGU>
   nOpacity = []; %#ok<NASGU>
   nImageSize = []; %#ok<NASGU>
   fStrokeWidth = []; %#ok<NASGU>
   vnROIPropertiesParams = [0 0]; %#ok<NASGU>
   nCountersOffset = 0;
end


% -- Set ROI name
if (isempty(vnNameParams) || any(vnNameParams == 0) || fseek(fidROI, sum(vnNameParams), 'bof'))
   [nul, sROI.strName] = fileparts(strFilename); %#ok<ASGLU>

else
   % - Try to read ROI name from header
   fseek(fidROI, vnNameParams(1), 'bof');
   sROI.strName = fread(fidROI, vnNameParams(2), 'int16=>char')';
end


% - Seek to get aspect ratio
fseek(fidROI, 52, 'bof');
fAspectRatio = fread(fidROI, 1, 'float32');

% - Seek to after header
fseek(fidROI, 64, 'bof');


% -- Build ROI

switch nTypeID
   case 1
      % - Rectangle
      sROI.strType = 'Rectangle';
      sROI.nArcSize = nRoundedRectArcSize;
      
      if (nShapeROISize > 0)
         % - This is a composite shape ROI
         sROI.strSubtype = 'Shape';
         if (nTypeID ~= 1)
            error('ReadImageJROI:FormatError', ...
               '*** ReadImageJROI: A composite ROI must be a Rectangle type.');
         end
         
         % - Read shapes
         sROI.vfShapes = fread(fidROI, nShapeROISize, 'float32');
      end
      
      
   case 2
      % - Oval
      sROI.strType = 'Oval';
      
   case 3
      % - Line
      sROI.strType = 'Line';
      sROI.vnLinePoints = round(vfLinePoints);
      
      if (nROISubtype == 2)
         % - This is an arrow line
         sROI.strSubtype = 'Arrow';
         sROI.bDoubleHeaded = nOptions & 2;
         sROI.bOutlined = nOptions & 4;
         sROI.nArrowStyle = nArrowStyle;
         sROI.nArrowHeadSize = nArrowHeadSize;
      end
      
      
   case 0
      % - Polygon
      sROI.strType = 'Polygon';
      sROI.mnCoordinates = read_coordinates;
      
   case 7
      % - Freehand
      sROI.strType = 'Freehand';
      sROI.mnCoordinates = read_coordinates;
      
      if (nROISubtype == 3)
         % - This is an ellipse
         sROI.strSubtype = 'Ellipse';
         sROI.vfEllipsePoints = vfLinePoints;
         sROI.fAspectRatio = fAspectRatio;
      end
      
   case 8
      % - Traced
      sROI.strType = 'Traced';
      sROI.mnCoordinates = read_coordinates;
      
   case 5
      % - PolyLine
      sROI.strType = 'PolyLine';
      sROI.mnCoordinates = read_coordinates;
      
   case 4
      % - FreeLine
      sROI.strType = 'FreeLine';
      sROI.mnCoordinates = read_coordinates;
      
   case 9
      % - Angle
      sROI.strType = 'Angle';
      sROI.mnCoordinates = read_coordinates;
      
   case 10
      % - Point
      sROI.strType = 'Point';
      [sROI.mfCoordinates, vnCounters] = read_coordinates;
      
      % - Set counters and [C Z T] positions
      if (isempty(vnCounters))
         sROI.vnCounters = zeros(nNumCoords, 1);
         sROI.vnSlices = ones(nNumCoords, 1);
      else
         sROI.vnCounters = bitand(vnCounters, 255);
         sROI.vnSlices = bitshift(vnCounters, -8, 'uint32');
      end
      
   case 6
      sROI.strType = 'NoROI';
      
   otherwise
      error('ReadImageJROI:FormatError', ...
         '--- ReadImageJROI: The ROI file contains an unknown ROI type.');
end


% -- Handle version >= 218

if (sROI.nVersion >= 218)
   sROI.nStrokeWidth = nStrokeWidth;
   sROI.nStrokeColor = nStrokeColor;
   sROI.nFillColor = nFillColor;
   sROI.bSplineFit = nOptions & 1;
   
   if (nROISubtype == 1)
      % - This is a text ROI
      sROI.strSubtype = 'Text';
      
      % - Seek to after header
      fseek(fidROI, 64, 'bof');
      
      sROI.nFontSize = fread(fidROI, 1, 'uint32');
      sROI.nFontStyle = fread(fidROI, 1, 'uint32');
      nNameLength = fread(fidROI, 1, 'uint32');
      nTextLength = fread(fidROI, 1, 'uint32');
      
      % - Read font name
      sROI.strFontName = fread(fidROI, nNameLength, 'uint16=>char');
      
      % - Read text
      sROI.strText = fread(fidROI, nTextLength, 'uint16=>char');
   end
end

% - Close the file
fclose(fidROI);


% --- END of ReadImageJROI FUNCTION ---

   function [mnCoordinates, vnCounters] = read_coordinates
      
      % - Check for sub-pixel resolution
      if bitand(nOptions, bOpt_SubPixelResolution)
         fseek(fidROI, 64 + 4*nNumCoords, 'bof');
         
         % - Read X and Y coordinates
         vnX = fread(fidROI, [nNumCoords 1], 'single');
         vnY = fread(fidROI, [nNumCoords 1], 'single');
         
      else
         % - Read X and Y coords
         vnX = fread(fidROI, [nNumCoords 1], 'int16');
         vnY = fread(fidROI, [nNumCoords 1], 'int16');
         
         % - Trim at zero
         vnX(vnX < 0) = 0;
         vnY(vnY < 0) = 0;
         
         % - Offset by top left ROI bound
         vnX = vnX + sROI.vnRectBounds(2);
         vnY = vnY + sROI.vnRectBounds(1);
      end
      
      mnCoordinates = [vnX vnY];
      
      % - Read counters, if present
      if (nCountersOffset ~= 0)
         fseek(fidROI, nCountersOffset, 'bof');
         vnCounters = fread(fidROI, [nNumCoords 1], 'uint32');
      else
         vnCounters = [];
      end
   end

   function [filelist] = listzipcontents_rois(zipFilename)
      
      % listzipcontents_rois - FUNCTION Read the file names in a zip file
      %
      % Usage: [filelist] = listzipcontents_rois(zipFilename)
      
      % - Import java libraries
      import java.util.zip.*;
      import java.io.*;
      
      % - Read file list via JAVA object
      filelist={};
      in = ZipInputStream(FileInputStream(zipFilename));
      entry = in.getNextEntry();
      
      % - Filter ROI files
      while (entry~=0)
         name = entry.getName;
         if (name.endsWith('.roi')) && (~name.startsWith('__MACOSX'))
            filelist = cat(1,filelist,char(name));
         end;
         entry = in.getNextEntry();
      end;
      
      % - Close zip file
      in.close();
   end


   function [cellArray] = CellFlatten(varargin)
      
      % CellFlatten - FUNCTION Convert a list of items to a single level cell array
      %
      % Usage: [cellArray] = CellFlatten(arg1, arg2, ...)
      %
      % CellFlatten will convert a list of arguments into a single-level cell array.
      % If any argument is already a cell array, each cell will be concatenated to
      % 'cellArray' in a list.  The result of this function is a single-dimensioned
      % cell array containing a cell for each individual item passed to CellFlatten.
      % The order of cell elements in the argument list is guaranteed to be
      % preserved.
      %
      % This function is useful when dealing with variable-length argument lists,
      % each item of which can also be a cell array of items.
      
      % Author: Dylan Muir <dylan@ini.phys.ethz.ch>
      % Created: 14th May, 2004
      
      % -- Check arguments
      
      if (nargin == 0)
         disp('*** CellFlatten: Incorrect usage');
         help CellFlatten;
         return;
      end
      
      % -- Convert arguments
      
      % - Which elements contain cell subarrays?
      vbIsCellSubarray = cellfun(@iscell, varargin, 'UniformOutput', true);
      
      % - Skip if no cell subarrays
      if ~any(vbIsCellSubarray)
         cellArray = varargin;
         return;
      end
      
      % - Recursively flatten subarrays
      varargin(vbIsCellSubarray) = cellfun(@(c)CellFlatten(c{:}), varargin(vbIsCellSubarray), 'UniformOutput', false);
      
      % - Count the total number of arguments
      vnArgSizes(nargin) = nan;
      vnArgSizes(~vbIsCellSubarray) = 1;
      vnArgSizes(vbIsCellSubarray) = cellfun(@numel, varargin(vbIsCellSubarray), 'UniformOutput', true);
      vnArgEnds = cumsum(vnArgSizes);
      vnArgStarts = [1 vnArgEnds(1:end-1)+1];
      nNumArgs = vnArgEnds(end);
      
      % - Preallocate return array
      cellArray = cell(1, nNumArgs);
      
      % - Deal out non-cell subarray arguments
      cellArray(vnArgEnds(~vbIsCellSubarray)) = varargin(~vbIsCellSubarray);
      
      % - Deal out arguments into return array
      for nIndexArg = find(vbIsCellSubarray)
         cellArray(vnArgStarts(nIndexArg):vnArgEnds(nIndexArg)) = varargin{nIndexArg};
      end
      
      % --- END of CellFlatten.m ---

   end

end
% --- END of ReadImageJROI.m ---
