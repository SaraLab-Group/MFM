function [out] = makedistorted_sliced(unitcell,outsize,nslices,nedge,diamp,dcell,na,nim,lambda,deltaz,filenamebase,fileextension)
if(abs (outsize/nslices - round(outsize/nslices)) > 0.0001)
    sprintf('Outsize must be a multiple of nslice')
    return
end
tic
unitcell=logical(unitcell);
[nxcell,nycell]=size(unitcell);
sinalpha=na/nim;
xpixsizeratio=(nxcell*diamp/dcell)/outsize;
ypixsizeratio=(nycell*diamp/dcell)/outsize;  %not currently used?
xfocfact=deltaz*nxcell;
yfocfact=deltaz*nedge*nycell;
% xp will range from -sinalpha to + sinalpha in outsize steps
xpmax=single(sinalpha*(outsize-1)/outsize);
xpstep=single(sinalpha*2/outsize);
xp=[-xpmax:xpstep:xpmax];
xp2_1D=xp.*xp;
xpat_1D=xpixsizeratio*single([0:outsize-1]);
slicewidth=outsize/nslices;
out=repmat(true,slicewidth,outsize);

for islice=1:nslices
    filename = sprintf('%s%d.%s',filenamebase,islice,fileextension);
    for i2=1:slicewidth
        iy=(islice-1)*slicewidth+i2;
        %Here we make an array containing xp^2+yp^2
        kzrow=xp2_1D+repmat(xp2_1D(iy),[1,outsize]);

        % Here we make the spherical focus function, in true wave number units
        % (i.e. inverse microns) as sqrt(1-(xp^2+yp^2)) times the
        % wave number of the light (i.e. the inverse wavelength in the sample)
        % nim/lambda. The inequality
        % kz<sinalpha restricts the square root to the inside of the pupil,where
        % the quantity under the root is >0.
        %    kz=(nim/lambda)*realsqrt((kz<sinalpha).*(1-kz));
        %    If memory allows, make mask separately so we can reuse it later.
        mask=kzrow<sinalpha^2;
        kzrow=(nim/lambda)*(1-realsqrt(mask.*(1-kzrow)));

        % Now we make an array that contains the x and y coordinates from where
        % we want to pick a pixel from the unit cell:
        xpat=int32(mod(round(xpat_1D+xfocfact.*kzrow),nxcell))+1;
        ypat=int32(mod(round(repmat(xpat_1D(iy),[1,outsize])+yfocfact.*kzrow),nycell));
        % Now we convert the 2D indexing (xpat,ypat) to linear indexing, so that we
        % can use the a(b) notation to pick pixels.
        xpat=xpat+nxcell*ypat;
        out(i2,:)=and(mask,unitcell(xpat));
    end
    disp(sprintf('%d rows calculated after %f s',iy,toc));
    imwrite(out,filename)
%    if islice == 1
%     save('C_maskFull.mat','out','-v7.3')
 %   elseif islice == 2
  %      save outSlice2 out
   % end
    
    disp(sprintf('%d rows written after %f s',iy,toc));
end
total_time=toc;
disp(sprintf('File series %s completed after %f s',filenamebase,toc));

