function im_gating(H5fname, outfname)

% please set the bart/matlab directory
addpath ~/bart/matlab

H5fname = [H5fname , '.h5'];

%% Get data, traj and dcf
tmp = h5read(H5fname, '/Gating/kdata_gating');
ncoils = size(tmp.real,5);
clear tmp;
 
info = h5info(H5fname,'/Kdata/KData_E0_C0');
ksize = info.Dataspace.Size;

data = zeros(1,ksize(1),ksize(2),ncoils);
traj = zeros(3,ksize(1),ksize(2),1);
dcf = zeros(1,ksize(1),ksize(2),1);

for i = 1:ncoils
    kstruct = h5read(H5fname,sprintf('/Kdata/KData_E0_C%d',i-1));
    data(1,:,:,i) = kstruct.real +kstruct.imag*1j;
end

dcf(1,:,:) = h5read(H5fname,'/Kdata/KW_E0');

traj(1,:,:) = h5read(H5fname,'/Kdata/KX_E0')*2 ;
traj(2,:,:) = h5read(H5fname,'/Kdata/KY_E0') ;
traj(3,:,:) = h5read(H5fname,'/Kdata/KZ_E0')*1.2 ;


time = h5read(H5fname,'/Gating/time');
[stime,order] = sort(time);

data = data(:,:,order,:);
traj = traj(:,:,order);
dcf = dcf(:,:,order);

M = 100;
res = [];

for ind = 1:ceil(size(data,3)/10000)
    if(ind*10000) > size(data,3)
        last = floor(size(data,3)/100)*100;
    else
        last = ind*10000;
    end
    range = (ind-1)*10000+1:last;
    
    data_lowres = data(:,1:M,range,:);
    traj_lowres = traj(:,1:M,range);
    dcf_lowres = dcf(:,1:M,range);

    im_calib = bart('bart nufft -a -t -d 24:24:24', traj_lowres, data_lowres.*repmat(dcf_lowres,[1 1 1 ncoils]));
    kcalib =  bart('bart fft 7 ',im_calib);
    kcalib_zpad =  bart('bart resize -c 0 80 1 80 2 80',kcalib);
    maps = bart('bart ecalib -S -m 1 -r 24', kcalib_zpad);

    traj_tmp = permute( reshape( traj_lowres, [size(traj_lowres,1), size(traj_lowres,2), 100, size(traj_lowres,3)/100] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4] );
    data_tmp =  permute( reshape( data_lowres, [size(data_lowres,1), size(data_lowres,2), 100,size(data_lowres,3)/100, size(data_lowres,4)] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4]);
    dcf_tmp = permute( reshape( dcf_lowres, [size(dcf_lowres,1), size(dcf_lowres,2), 100, size(dcf_lowres,3)/100] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4]);

    tmp = dcf_lowres(:,:,1);
    %% Save to cfl files
    writecfl('uwute_lowres_traj',traj_tmp)
    writecfl('uwute_lowres_dcf',dcf_tmp/max(tmp(:))*8);
    writecfl('uwute_lowres_data',data_tmp);
     writecfl('uwute_lowres_maps',maps);

    !bart pics -i 200 -R L:7:7:0.0005 -H -s 0.001 -p uwute_lowres_dcf -t uwute_lowres_traj uwute_lowres_data uwute_lowres_maps uwute_lowres_rec
    im = readcfl('uwute_lowres_rec');
    res = cat(4,res,im);
    writecfl([H5fname,'_lowres_rec'],res);
end
   
end


