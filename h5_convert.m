function h5_convert(H5fname, outfname)

% please set the bart/matlab directory

H5fname = [H5fname , '.h5'];

%% Get data, traj and dcf
tmp = h5read(H5fname, '/Kdata/Noise');
ncoils = size(tmp.real,2);
 
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

traj(1,:,:) = h5read(H5fname,'/Kdata/KX_E0') ;
traj(2,:,:) = h5read(H5fname,'/Kdata/KY_E0') ;
traj(3,:,:) = h5read(H5fname,'/Kdata/KZ_E0') ;

%% Save to cfl files
writecfl([outfname,'_traj'],traj)
writecfl([outfname,'_dcf'],dcf);
writecfl([outfname,'_data'],data);
