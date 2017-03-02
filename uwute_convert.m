function uwute_convert(H5fname, outfname, do_soft, hard_Nbins)

% please set the bart/matlab directory
%addpath ~/bart/matlab

H5fname = [H5fname , '.h5'];

%% Get data, traj and dcf
tmp = h5read(H5fname, '/Gating/kdata_gating');
ncoils = size(tmp.real,5);
clear tmp;
 
info = h5info(H5fname,'/Kdata/KData_E0_C0');
ksize = info.Dataspace.Size;

dcf = zeros(1,ksize(1),ksize(2),1);
traj = zeros(3,ksize(1),ksize(2),1);
data = zeros(1,ksize(1),ksize(2),ncoils);

dcf(1,:,:) = h5read(H5fname,'/Kdata/KW_E0');

traj(1,:,:) = h5read(H5fname,'/Kdata/KX_E0') * 2 ;
traj(2,:,:) = h5read(H5fname,'/Kdata/KY_E0') * 2 ;
traj(3,:,:) = h5read(H5fname,'/Kdata/KZ_E0') * 2 ;


for i = 1:ncoils
    kstruct = h5read(H5fname,sprintf('/Kdata/KData_E0_C%d',i-1));
    data(1,:,:,i) = kstruct.real +kstruct.imag*1j;
end

%% estimate the actual FOV based on Low res images 64*64*64
% tmp = traj(:,:,1);
% tmp = sqrt(tmp(1,:).^2+tmp(2,:).^2 + tmp(3,:).^2);
% M = find(tmp>=32,1);
% tmp = hamming(2*M);
% window = tmp((M+1):end)';
% 
% data_lowres = data(:,1:M,1:5:end,:).*repmat(dcf(1,1:M,1:5:end),[1 1 1 ncoils]).*repmat(window,[1 1 size(dcf(1,1:M,1:5:end),3) ncoils]);
% traj_lowres = traj(:,1:M,1:5:end);
% 
% im_calib = bart('bart nufft -a', traj_lowres, data_lowres);
% im_calib =  max(squeeze(abs(im_calib)),[],4);
% 
% mip_x = squeeze(max(max(im_calib, [], 3),[],2));
% mip_y = squeeze(max(max(im_calib, [], 3),[],1));
% mip_z = squeeze(max(max(im_calib, [], 2),[],1));
% 
% tmp = sort([mip_x;mip_y.';mip_z]);
% noise = median(tmp(1:round(length(tmp)/20)));
% 
% indx = find(mip_x > noise*5);
% indy = find(mip_y > noise*5);
% indz = find(mip_z > noise*5);
% 
% FOV = [length(indx),length(indy),length(indz)]./[size(im_calib,1) size(im_calib,2) size(im_calib,3)];
% 
% if FOV(2) > 0.5
% FOV(2) = 0.5;
% end
% 
% fprintf('Estimated  FOV is %d %d %d \n', round(FOV(1)*512),round(FOV(2)*512),round(FOV(3)*512));
% 
% traj(1,:,:) = traj(1,:,:)* FOV(1);
% traj(2,:,:) = traj(2,:,:)* FOV(2);    % y dimension is as the prescribed 256
% traj(3,:,:) = traj(3,:,:)* FOV(3);
% 
% %% Save to cfl files
% writecfl([outfname,'_traj'],traj);
% writecfl([outfname,'_data'],data);
% writecfl([outfname,'_dcf'],dcf);

%% Get order and gate
if (do_soft || hard_Nbins)
    time = h5read(H5fname,'/Gating/time');
    [stime,order] = sort(time);
    
    resp =  double(h5read(H5fname,'/Gating/resp'));
    resp = resp(order);
    resp = -(resp-mean(resp))/std(resp);
    
    k0_ordered = squeeze(double( data(:,1,order,:) ));
    gate_ordered = ute_gate_extract( k0_ordered, resp);
end

figure(10),subplot(211),plot(resp),title('bellow')
subplot(212),plot(gate_ordered),title('self-gating')

if verLesThan('matlab','8.2')
    save(gcf,[outfname,'_Bellow_vs_self-gating.fig'])
else
    save([outfname,'_Bellow_vs_self-gating.fig'])
end
close all;
%% Get soft-weighting
if (do_soft)
    sg_ordered = ute_gui( gate_ordered ,resp);
    sg(order) = sg_ordered;
    sgdcf = dcf .* repmat( reshape( sg, [1, 1, size(data,3), 1, 1] ), [1, size(data,2), 1, 1, 1] );
    writecfl([outfname,'_sg_dcf'],sgdcf)
end

%% Binning
if (hard_Nbins)
    
    gate(order) = gate_ordered;
    [bin_data, bin_traj, bin_dcf] = ute_binning( gate, hard_Nbins, data, traj, dcf );
    
    writecfl([outfname, '_b', int2str(hard_Nbins), '_data'], bin_data);
    writecfl([outfname, '_b', int2str(hard_Nbins) , '_traj'], bin_traj);
    writecfl([outfname, '_b', int2str(hard_Nbins), '_dcf'], bin_dcf);
end

