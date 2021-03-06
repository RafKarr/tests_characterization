function [res,ind] = min(X,Y,dim)
% Maximum of an array or between a pair of arrays (for VPI numbers)
%
% For vectors, MIN(X) is the largest element in X. For matrices,
%    MIN(X) is a row vector containing the minimum element from each
%    column. For N-D arrays, MIN(X) operates along the first
%    non-singleton dimension.
% 
%    [Y,I] = MIN(X) returns the indices of the minimum values in vector I.
%    If the values along the first non-singleton dimension contain more
%    than one minimal element, the index of the first one is returned.
% 
%    MIN(X,Y) returns an array the same size as X and Y with the
%    largest elements taken from X or Y. Either one can be a scalar.
% 
%    [Y,I] = MIN(X,[],dim) operates along the dimension dim. 



% which mode are we in?
if nargin == 0
  error('VPI:MIN:improperarguments','Insufficient input arguments')
elseif nargin > 3
  error('VPI:MIN:improperarguments','No more than 3 input arguments are allowed')
elseif nargin == 2
  if numel(X) == 1
    % scalar expansion for X
    res = vpi(Y);
    res(X < Y) = X;
  elseif numel(Y) == 1
    % scalar expansion for Y
    res = vpi(X);
    res(Y < X) = Y;
  elseif ~isequal(size(X),size(Y))
    % sizes are inconsistent
    error('VPI:MIN:unmatchedsizes','Matrix dimensions must agree')
  else
    % two compatibly sized arrays
    res = vpi(X);
    i = Y < X;
    res(i) = Y(i);
  end
else
  % single argument, or 3 arguments
  
  if nargin ==1
    % determine the dimension to work on, as the first non-singleton
    % dimension
    dim = find(size(X) > 1,1,'first');
    if isempty(dim)
      dim = 1;
    end
  end
  % dim is now defined
  
  % check for problems with dim
  Sx = size(X);
  if (dim < 0) || (dim ~= round(dim))
    error('VPI:MIN:improperdim','dim must be a positive integer')
  elseif (dim > numel(Sx)) || (Sx(dim) == 1)
    % this is a no-op
    res = X;
    ind = ones(Sx);
    return
  else
    % compute the min along dimension dim
    
    % create result and ind as the correct sizes
    Sr = Sx;
    Sr(dim) = 1;
    res = repmat(X(1),Sr);
    ind = ones(Sr);
    
    % permute and reshape X into a 2-d array
    Ix = 1:numel(Sx);
    Ix(dim) = [];
    Ix = [dim,Ix];
    X = permute(X,Ix);
    X = reshape(X,Sx(dim),[]);
    
    % now loop over the columns of X
    ndim = Sx(dim);
    for i = 1:size(X,2)
      res(i) = X(1,i);
      for j = 2:ndim
        if res(i) > X(j,i)
          ind(i) = j;
          res(i) = X(j,i);
        end
      end
    end
  end
end





