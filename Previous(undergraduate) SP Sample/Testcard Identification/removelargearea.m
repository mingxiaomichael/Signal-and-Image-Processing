function bw2 = removelargearea(varargin)

[bw,p,conn] = parse_inputs(varargin{:});

CC = bwconncomp(bw,conn);
area = cellfun(@numel, CC.PixelIdxList);

idxToKeep = CC.PixelIdxList(area <= p);
idxToKeep = vertcat(idxToKeep{:});

bw2 = false(size(bw));
bw2(idxToKeep) = true;

function [bw,p,conn] = parse_inputs(varargin)

narginchk(2,3)

bw = varargin{1};
validateattributes(bw,{'numeric' 'logical'},{'nonsparse'},mfilename,'BW',1);
if ~islogical(bw)
    bw = bw ~= 0;
end

p = varargin{2};
validateattributes(p,{'double'},{'scalar' 'integer' 'nonnegative'},...
    mfilename,'P',2);

if (nargin >= 3)
    conn = varargin{3};
else
    conn = conndef(ndims(bw),'maximal');
end
iptcheckconn(conn,mfilename,'CONN',3)

