
% Trying to create pixelflipper to handle general images.

%This program makes a matrix m (random guess) representing a diffractive phase grating
%We optimize m to conform to a target function, defined in "compare to target function",
%We step through the pixels in random order and flipping them if this improves likeness to the target function
w = 1; %8 %5 %4 %1.5 %Weighting for peak evenness. Faster and less even for lower number.
P = 2^7; % Matrix size, even and preferably a power of 2
c = P/2+1; per = 1; %c is zeroth diffractive order, per is how many repeats we simulate (= pixel distance btw diffractive orders)

% Define Target function 
%N = 11; % Diffractive orders that form the image part, uneven number?
%Target = ones(N,N)/(N^2);
tb=imread('Hagstrom121x121_binary.tif');
tb=double(tb)/(2*sum(tb(:)));
Target = tb;
%[N S] = size(Target); 
%To Allow assymetric we must use multiphase optic

N = length(Target);
S = N;

T = zeros(P,P); 
T(c-(S-1)/2:c+(S-1)/2,c-(N-1)/2:c+(N-1)/2) = Target;
%T(c,c) = T(c,c)*0.92; %SUPPRESSING ZERO

%CREATE STARTING GUESST
m = round(rand(P,P)); 
m = m*exp(pi*1i) + abs(m-1);  % phases pi and zero are 1 and -1
l = linspace(0,1,2);
step = 2*pi/length(l);
phases = l*step;
ex = inline('exp(i*phase)');
phaseVals = ex(phases); 

mposition = zeros(P*2, P);  %preallocate array that will contain positions

%Fill empty matrix mposition with all positions:
lin = linspace(1,P,P);
linswitch = lin;
for q = 1:P,
    linswitch(1) = [];
    linswitch = [linswitch q];
    mposition(q*2,:) = lin;
    mposition(q*2+1,:) = linswitch;
end
mposition = mposition(2:end,:); %get rid of the row of zeros

%OPTIMIZATION:
%step through all pixels and flip current pixel if doing so improves likeness to target function and criteria.
%Keep going until no pixels are flipped in an entire round. (Does not guarantee global optimum.)

flips = 1; tic
fliprounds = 0;
while flips >0
    
    matpos = mposition(:);  %read in a temporary array of all positions

    flips = 0;

    for q = 1:(P*P)
        
        %Find a random pixel (position (x,y)):
        pos = round(rand*(length(matpos)/2-1))*2+1; %pick a random (odd) position in matpos array
        x = matpos(pos);
        y = matpos(pos+1);
        matpos(pos:pos+1) = [];  %remove this position from the temporary position array
        
        %Try out the different phase values for the pixel (x,y)
        for p = 1:length(phaseVals)
            
            pixcheck = m(x,y);
            mtest = m; %make a temporary array mtest where the pixel is flipped for comparing
            mtest(x,y) = phaseVals(p);
            
            %COMPARE TO TARGET FUNCTION
            prev = fftshift(abs((ifft2(m)).^2)); % "previous" matrix
            test = fftshift(abs((ifft2(mtest)).^2)); % "test" matrix with flipped pixel
            
            %likeness of test to prev:
            
            testtarval = (abs(test - T)).^w; 
            testtarval = sum(testtarval(:));
            prevtarval = abs(prev - T); 
            prevtarval = sum(prevtarval(:));
            
            if prevtarval > testtarval
                m(x,y) = phaseVals(p);
            end
            
            if pixcheck ~= m(x,y)
                flips = flips+1;
            end
            
        end
        
        
        %plot matrixes to visualize progress:
        %figure(1), imagesc(real(m)), figure(2), imagesc(prev)
    end
    %plot matrixes to visualize progress:
    %figure(1), imagesc(real(m)+0.5*imag(m)), figure(2), imagesc(prev), axis ([c-3 c+3 c-3 c+3])
    flips
    fliprounds = fliprounds + 1;
end
fliprounds
toc
test = fftshift(abs((ifft2(m)).^2)); 
centralOrders = test(c-(N-1)/2:c+(N-1)/2,c-(N-1)/2:c+(N-1)/2);
transmittance = sum(test(:));
efficiency = sum(centralOrders(:))
minOrder = min(centralOrders(:));
maxOrder = max(centralOrders(:));
unevenness = min(centralOrders(:))/max(centralOrders(:))

figure(1), imagesc(real(m)+0.5*imag(m)),  colormap jet
figure(2), imagesc(test)
