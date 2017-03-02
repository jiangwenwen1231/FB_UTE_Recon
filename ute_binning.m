function [data, traj, dcf] = ute_binning(gate, N, data, traj, dcf)

gate = gate( 1:floor(length(gate)/N)*N);

%%
[~, idx] = sort(gate);

traj = permute( reshape( traj(:,:,idx), [size(traj,1), size(traj,2), size(traj,3)/N, N] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4] );
data = permute( reshape( data(:,:,idx,:), [size(data,1), size(data,2), size(data,3)/N, N, size(data,4)] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4]);
dcf = permute( reshape( dcf(:,:,idx), [size(dcf,1), size(dcf,2), size(dcf,3)/N, N] ), [1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 4]);
