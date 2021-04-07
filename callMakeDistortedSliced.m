

% Create the 3 binary masks (A,B,C) for the multiphase MFG, altered and commented for Laura by Sara, March 2015

% Parameters sent to makeDistorted: (unitcell,outsize,nslices,nedge,diamp,dcell,na,nim,lambda,deltaz,filenamebase,fileextension)
outsize = 93330;    % Size of mask in pixels
nedge = 3;          % 3x3 or 5x5 
diamp = 9333;       % Size of pupil (in microns)
dcell = 12.1282;       % Nomial grating period (microns)
na = 1.4;           % Numerical Aperture of objective
nim = 1.4;          % Immersion meduim refractive index (>=NA)
lambda = 0.59;     % Design wavelength (microns)
deltaz = 2;      % Focus shift between successive planes (microns)
nslices = 3;        % If you get too large files, change to 2 (or larger) Sets number of image files to slice up the masks to, if too big to write to one file. Merge again in beamer when creating the .gds file!           
prefix = 'PhilRed2um';    % Prefix for your generated file names

%Etch depth for 590 is 643.5nm, this was 8 cycels of 120 s zrob as of midsummer
%visit

%Generate file name: (makedistorted also adds mask level letter and slicenumber)
filename = sprintf('%s%d%s%d%s',prefix, lambda*1000,'nm',deltaz*1000,'dz')       
       
% Load your saved grating functions, matrices A, B and C consisting of ones and zeros
A = imread ('MFG3x3binary.bmp');
%load('maskA512.mat') % mask A
%load('maskB512.mat') % mask B
%load('maskC512.mat') % mask C
 
% Call the function makedistorted_sliced_April2014 which generates the files
makeDistortedSlicedSARA(A,outsize,nslices,nedge,diamp,dcell,na,nim,lambda,deltaz,sprintf('%s%s',filename,'A'),'bmp');
%makeDistortedSlicedSARA(B,outsize,nslices,nedge,diamp,dcell,na,nim,lambda,deltaz,sprintf('%s%s',filename,'B'),'bmp');
%makeDistortedSlicedSARA(C,outsize,nslices,nedge,diamp,dcell,na,nim,lambda,deltaz,sprintf('%s%s',filename,'C'),'bmp');


% Binary 5x5 example:
% unitcell5x5 = 
% makedistorted_sliced(unitcell5x5,65000,13,5,6500,38.25,1.3,1.33,0.51,0.5,'dist3x3_eqSimple_13_0p5um_65kpix','tif');

